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

# engine_check_installed <tool-dir> : 0 when any declared binary is present.
engine_check_installed() {
  manifest_is_installed "$1"
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

  # Termux installers own their full UX (menus, loadings). Generated Linux
  # installers are quiet, so the engine provides feedback there.
  # Snapshot shell configs to detect installer-side modifications
  # (PATH exports etc.). Child processes cannot alter the parent shell,
  # so we detect the change and tell the user exactly what to run.
  local rc_snapshot_before rc_snapshot_after
  rc_snapshot_before=$(cat "$HOME/.zshrc" "$HOME/.bashrc" 2>/dev/null | cksum)

  if [[ "$CORE_ENV" == "termux" ]]; then
    _engine_run "$script" install
    rc=$?
  else
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    loading "Installing $display" _engine_run "$script" install
    rc=$?

    # Official installers sometimes exit non-zero on non-critical errors
    # (telemetry, logging init, optional steps). Trust the binary over the
    # exit code before declaring failure.
    if [[ $rc -ne 0 ]] && manifest_is_installed "$dir"; then
      log_warn "$display installer exited with $rc but the tool is present - OK"
      rc=0
    fi
  fi

  case $rc in
    0)
      registry_record "$name"

      rc_snapshot_after=$(cat "$HOME/.zshrc" "$HOME/.bashrc" 2>/dev/null | cksum)
      if [[ "$rc_snapshot_after" != "$rc_snapshot_before" ]]; then
        local rc_file="$HOME/.zshrc"
        [[ -f "$HOME/.zshrc" ]] || rc_file="$HOME/.bashrc"
        log_info "$display updated your shell config ($rc_file)"
        list_item "Apply now: ${D_CYAN}source $rc_file${D_NC}   or open a new terminal."
      fi

      if ! manifest_is_installed "$dir"; then
        log_warn "$display finished but its binary was not found on PATH"
        list_item "Open a NEW terminal (or run: hash -r) and retry."
        list_item "Tool binaries live in: \$HOME/.local/bin"
      fi
      ;;
    2) : ;;
    *) log_error "$display: installer exited with $rc (log: $LOG_FILE)" ;;
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

    if [[ "$CORE_ENV" == "termux" ]]; then
      _engine_run "$script" uninstall
      rc=$?
    else
      loading "Removing $display" _engine_run "$script" uninstall
      rc=$?
    fi
    # Some upstream uninstallers exit non-zero even when they succeed;
    # absence of the binary is the ground truth.
    if [[ "$CORE_ENV" != "termux" ]] && manifest_is_installed "$dir"; then
      log_warn "Binary still present - removing it directly"
      while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        command -v "$b" >/dev/null 2>&1 && rm -f "$(command -v "$b")"
      done < <(manifest_check_list "$dir")
      ! manifest_is_installed "$dir" && rc=0
    fi
  else
    rc=0
  fi

  local recorded
  recorded="$(registry_deps_installed_by_core "$name")"

  if [[ $rc -eq 0 ]]; then
    registry_remove "$name"

    # Orphan dependency cleanup — ask only for truly exclusive deps.
    # Loop input uses fd 3 so interactive prompts keep stdin free.
    local BASE_PROTECTED=" git curl wget jq unzip bat lsd fzf glow python pip nodejs npm ripgrep make cmake clang rust go tar "
    while IFS='|' read -r -u 3 dep check pkg_t pkg_a; do
      [[ -z "$dep" ]] && continue
      [[ "$BASE_PROTECTED" == *" $dep "* ]] && continue
      grep -qx "$dep" <<<"$recorded" || continue
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
  if [[ "$CORE_ENV" != "termux" ]]; then
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Version flow: local -> remote -> compare -> suggest.
  local local_ver remote_ver
  local_ver=$(bash "$script" version-local 2>/dev/null)
  remote_ver=$(bash "$script" version-remote 2>/dev/null)

  if [[ -z "$local_ver" || -z "$remote_ver" ]]; then
    local answer
    read_confirm_default "Could not compare versions. Update $display anyway?" "y" answer
    if [[ "$CORE_ENV" == "termux" ]]; then
      [[ "$answer" == "y" ]] && _engine_run "$script" update
    else
      [[ "$answer" == "y" ]] && loading "Updating $display" _engine_run "$script" update
    fi
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
    if [[ "$CORE_ENV" == "termux" ]]; then
      _engine_run "$script" update
    else
      loading "Updating $display" _engine_run "$script" update
    fi
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
