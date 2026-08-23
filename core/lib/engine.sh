#!/usr/bin/env bash

# Core - Tool engine.
#
# Discovery, installation, update and uninstall orchestration. Tools are
# resolved by name through their manifests; platform scripts are executed as
# isolated child processes with a verb argument:
#
#   install/<platform>.sh install|uninstall|update
#
# Script resolution order per tool:
#   1. install/$CORE_PLATFORM.sh   (termux | ubuntu | wsl)
#   2. install/linux.sh            (distro-agnostic Linux fallback)
#
# Exit code convention (kept from Core-Termux):
#   0 = success, 1 = failure, 2 = already installed / nothing to do

[[ -n "${__CORE_ENGINE_LOADED:-}" ]] && return
__CORE_ENGINE_LOADED=1

import "@/lib/platform"
import "@/lib/manifest"
import "@/lib/registry"
import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

# ---------------------------------------------------------------------------
# Dependency handling
# ---------------------------------------------------------------------------

_deps_pkg_for_platform() {
  local pkg_termux="$1" pkg_apt="$2"
  case "$CORE_PKG_MGR" in
    pkg) echo "$pkg_termux" ;;
    apt|dnf|pacman) echo "$pkg_apt" ;;
    *) echo "" ;;
  esac
}

_dep_present() {
  local check="$1"
  if [[ -z "$check" ]]; then
    return 1
  fi
  eval "command -v ${check%% *}" &>/dev/null && return 0
  return 1
}

# engine_ensure_deps <tool-dir> <tool-name>
# Installs missing dependencies declared by the manifest and remembers which
# ones Core installed so orphan detection can offer them later.
engine_ensure_deps() {
  local dir="$1" name="$2"
  local installed_by_core=()
  local line dep check pkg_t pkg_a pkg

  while IFS='|' read -r dep check pkg_t pkg_a; do
    [[ -z "$dep" ]] && continue
    if _dep_present "$check"; then
      continue
    fi
    pkg="$(_deps_pkg_for_platform "$pkg_t" "$pkg_a")"
    if [[ -z "$pkg" ]]; then
      log_warn "Dependency '$dep' missing and no package mapping for $CORE_PKG_MGR"
      continue
    fi
    loading "Installing dependency: $dep" pm_install "$pkg" || {
      log_error "Failed to install dependency $dep"
      return 1
    }
    installed_by_core+=("$dep")
  done < <(manifest_deps "$dir")

  registry_record "$name" "${installed_by_core[@]}"
  return 0
}

# ---------------------------------------------------------------------------
# Script resolution
# ---------------------------------------------------------------------------

# engine_platform_dir : subfolder holding the current platform's installer.
#   termux            -> termux/
#   ubuntu | wsl      -> ubuntu/  (WSL uses the Ubuntu installers)
#   future distros    -> add a mapping here + their folder per tool
engine_platform_dir() {
  case "$CORE_PLATFORM" in
    termux) echo "termux" ;;
    *) echo "ubuntu" ;;
  esac
}

engine_script_for() {
  local dir="$1"
  local script="$dir/$(engine_platform_dir)/install.sh"
  [[ -f "$script" ]] && {
    echo "$script"
    return 0
  }
  return 1
}

_engine_run() {
  local script="$1" verb="$2"
  mkdir -p "$(dirname "${LOG_FILE:-$CORE_CACHE/engine.log}")"
  export LOG_FILE
  bash "$script" "$verb"
}

# ---------------------------------------------------------------------------
# Public engine API
# ---------------------------------------------------------------------------

# engine_resolve <tool-name> : echoes tool directory or fails.
engine_resolve() {
  local dir
  dir="$(manifest_tool_dir "$1")"
  if [[ -z "$dir" ]]; then
    log_error "Unknown tool: $1"
    list_item "Run ${D_CYAN}core search${D_NC} to see available tools"
    return 1
  fi
  echo "$dir"
}

# engine_check_installed <tool-dir> : 0 when the tool binary is present.
engine_check_installed() {
  local check
  check="$(manifest_check_cmd "$1")"
  [[ -z "$check" ]] && return 1
  command -v "$check" &>/dev/null
}

# engine_install <tool-name>
engine_install() {
  local name="$1"
  local dir
  dir="$(engine_resolve "$name")" || return 1
  local display script rc

  display="$(manifest_display "$dir")"

  if ! manifest_supports_platform "$dir"; then
    log_warn "$display is not supported on $(core_platform_label)"
    return 1
  fi

  script="$(engine_script_for "$dir")" || {
    log_warn "No installer for $(core_platform_label) yet ($name)"
    return 1
  }

  if engine_check_installed "$dir"; then
    log_info "$display is already installed"
    return 2
  fi

  LOG_FILE="$CORE_CACHE/install_$name.log"
  engine_ensure_deps "$dir" "$name" || return 1

  loading "Installing $display" _engine_run "$script" install
  rc=$?

  case $rc in
    0)
      registry_record "$name"
      log_success "$display installed"
      ;;
    2) log_info "$display is already installed" ;;
    *) log_error "Failed to install $display (see $LOG_FILE)" ;;
  esac
  return $rc
}

# engine_uninstall <tool-name> : uninstalls a tool and offers removal of
# orphaned exclusive dependencies.
engine_uninstall() {
  local name="$1"
  local dir
  dir="$(engine_resolve "$name")" || return 1
  local display script rc orphan line dep pkg

  display="$(manifest_display "$dir")"

  if ! engine_check_installed "$dir" && ! registry_is_installed "$name"; then
    log_info "$display is not installed"
    return 2
  fi

  confirm_remove_configs "$(manifest_display "$dir")" $(manifest_field "$dir" '.config_paths // [] | .[]' "")

  script="$(engine_script_for "$dir")"
  if [[ -n "$script" ]]; then
    LOG_FILE="$CORE_CACHE/install_$name.log"
    _engine_run "$script" uninstall
    rc=$?
  else
    rc=0
  fi

  if [[ $rc -eq 0 ]]; then
    log_success "$display uninstalled"
    registry_remove "$name"

    # Orphan dependency cleanup — ask only for truly exclusive deps.
    # Loop input uses fd 3 so interactive prompts keep stdin free.
    while IFS='|' read -r -u 3 dep check pkg_t pkg_a; do
      [[ -z "$dep" ]] && continue
      pkg="$(_deps_pkg_for_platform "$pkg_t" "$pkg_a")"
      [[ -z "$pkg" ]] && continue
      echo
      local answer
      read_confirm_default "Remove orphaned dependency '$dep'? (no other Core tool uses it)" "n" answer
      if [[ "$answer" == "y" ]]; then
        loading "Removing $dep" pm_remove "$pkg" &&
          log_success "$dep removed" ||
          log_warn "Could not remove $dep"
      else
        log_info "Keeping $dep"
      fi
    done 3< <(deps_orphans "$dir")
  else
    log_error "Failed to uninstall $display"
  fi
  return $rc
}

# engine_update <tool-name> : local vs remote version comparison flow.
engine_update() {
  local name="$1"
  local dir
  dir="$(engine_resolve "$name")" || return 1
  local display script

  display="$(manifest_display "$dir")"

  if ! engine_check_installed "$dir"; then
    log_info "$display is not installed"
    return 2
  fi

  script="$(engine_script_for "$dir")" || {
    log_warn "No updater for $(core_platform_label) ($name)"
    return 1
  }

  LOG_FILE="$CORE_CACHE/install_$name.log"

  # Version flow: local -> remote -> compare -> suggest.
  local local_ver remote_ver
  local_ver=$(bash "$script" version-local 2>/dev/null)
  remote_ver=$(bash "$script" version-remote 2>/dev/null)

  if [[ -z "$local_ver" || -z "$remote_ver" ]]; then
    local answer
    read_confirm_default "Could not compare versions. Update $display anyway?" "y" answer
    [[ "$answer" == "y" ]] && _engine_run "$script" update
    return $?
  fi

  if _compare_versions "$local_ver" "$remote_ver"; then
    log_success "$display is already up to date ${D_NC}(${D_GREEN}v$local_ver${D_NC})"
    return 0
  fi

  log_info "$display: ${D_GREEN}v$local_ver${D_NC} → ${D_CYAN}v$remote_ver${D_NC}"
  local answer
  read_confirm_default "Update $display to v$remote_ver?" "y" answer
  if [[ "$answer" == "y" ]]; then
    _engine_run "$script" update
  else
    log_info "Skipped $display"
  fi
}

# engine_reinstall <tool-name>
engine_reinstall() {
  local name="$1"
  engine_uninstall "$name" >/dev/null 2>&1
  engine_install "$name"
}

# ---------------------------------------------------------------------------
# Discovery helpers
# ---------------------------------------------------------------------------

# engine_all_tools : every tool name in the flat tools/ directory.
engine_all_tools() {
  local tool_dir
  for tool_dir in "$CORE_PATH/tools/"*/; do
    [[ -f "$tool_dir/manifest.json" ]] || continue
    basename "$tool_dir"
  done
}
