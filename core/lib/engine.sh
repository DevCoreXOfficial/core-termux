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
    # Node.js reuses the canonical per-platform nodejs tool installers
    # (NodeSource LTS on Ubuntu/WSL, nodejs-lts + corepack on Termux)
    # instead of the distro package.
    if [[ "$dep" == "nodejs" ]]; then
      loading "Installing dependency: Node.js LTS" _engine_install_nodejs || {
        log_error "Failed to install dependency Node.js LTS"
        return 1
      }
      installed_by_core+=("$dep")
      continue
    fi

    pkg="$(_deps_pkg_for_platform "$pkg_t" "$pkg_a")"
    if [[ -z "$pkg" ]]; then
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

# _engine_install_nodejs : delegate to the canonical nodejs tool installer.
_engine_install_nodejs() {
  local dir script
  dir="$(manifest_tool_dir "nodejs")" || { log_error "nodejs tool not found"; return 1; }
  script="$(engine_script_for "$dir")" || { log_error "no ${CORE_PLATFORM} installer for nodejs"; return 1; }
  LOG_FILE="$CORE_CACHE/install_languages.log"
  bash "$script" install
}

# _script_is_interactive <script> : prompts require a visible terminal,
# so interactive scripts never get wrapped in the loading animation.
_script_is_interactive() {
  grep -qE 'read_(confirm|select|input|secret|multiline)' "$1"
}

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

# Link newly-installed binaries that landed in non-PATH directories.
  _engine_link_new_bins() {
    local hit=0 b cur d
    while IFS= read -r b; do
      [[ -z "$b" ]] && continue
      # Already the canonical link? nothing to do.
      [[ "$(command -v "$b")" == "$HOME/.local/bin/$b" ]] && continue
      local npmbin
      npmbin="$(npm config get prefix 2>/dev/null)/bin"
      for d in "$HOME/.opencode/bin" "$HOME/.bun/bin" "$HOME/.cargo/bin" \
               "$HOME/go/bin" "$HOME/.factory/bin" "$HOME/.antigravity/bin" \
               "$npmbin" "$HOME/.${name}"*/bin "$HOME/bin"; do
        if [[ -x "$d/$b" ]]; then
          ln -sf "$d/$b" "$HOME/.local/bin/$b"
          hit=1
          break
        fi
      done
      # Generic vendor pattern: ~/.<tool>*/bin/<bin>
      if ! [[ -e "$HOME/.local/bin/$b" ]]; then
        for d in "$HOME/.${name}"*/bin; do
          [[ -x "$d/$b" ]] && { ln -sf "$d/$b" "$HOME/.local/bin/$b"; hit=1; break; }
        done
      fi
    done < <(manifest_check_list "$dir")
    [[ $hit -eq 1 ]] && log_success "Binaries linked into ~/.local/bin"
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
  elif _script_is_interactive "$script"; then
    _engine_run "$script" install
    rc=$?
  else
    if [[ "$CORE_ENV" != "termux" ]]; then
      mkdir -p "$HOME/.local/bin"
      export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.factory/bin:$HOME/.antigravity/bin:$HOME/bin:$PATH"
      local rc_file
      case "${SHELL:-}" in
        *zsh*)  rc_file="$HOME/.zshrc" ;;
        *)      rc_file="$HOME/.bashrc" ;;
      esac
      local path_line='export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.factory/bin:$HOME/.antigravity/bin:$HOME/bin:$PATH"'
      if ! grep -qs 'Added by Core' "$rc_file"; then
        printf '\n# Added by Core\n%s\n' "$path_line" >>"$rc_file"
        log_success "Added tool binary paths to $rc_file"
        export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.factory/bin:$HOME/.antigravity/bin:$HOME/bin:$PATH"
      fi
    fi
    ENGINE_RAW_RC=0
    _engine_run_capture() {
      _engine_run "$script" install
      ENGINE_RAW_RC=$?
    }
    loading "Installing $display" _engine_run_capture

    if [[ "$CORE_ENV" != "termux" ]]; then
      _engine_link_new_bins
    fi
    hash -r 2>/dev/null || true
    if manifest_is_installed "$dir"; then
      rc=0
      [[ "${CORE_DEBUG:-0}" == "1" && $ENGINE_RAW_RC -ne 0 ]] &&
        log_debug "$display installer exited with $ENGINE_RAW_RC (non-critical; binary verified)"
    else
      rc=${ENGINE_RAW_RC:-1}
    fi
  fi

    case $rc in
    0)
      registry_record "$name"
      hash -r 2>/dev/null || true
      [[ "$CORE_ENV" != "termux" ]] && _engine_link_new_bins

      rc_snapshot_after=$(cat "$HOME/.zshrc" "$HOME/.bashrc" 2>/dev/null | cksum)
      if [[ "$rc_snapshot_after" != "$rc_snapshot_before" ]]; then
        local rc_file="$HOME/.zshrc"
        [[ -f "$HOME/.zshrc" ]] || rc_file="$HOME/.bashrc"
        log_info "$display updated your shell config ($rc_file)"
        list_item "Apply now: ${GRAY_19}source $rc_file${NC}   or open a new terminal."
      fi

      hash -r 2>/dev/null || true
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
    elif _script_is_interactive "$script"; then
      _engine_run "$script" uninstall
      rc=$?
    else
      loading "Removing $display" _engine_run "$script" uninstall
      rc=$?
    fi
    # Some upstream uninstallers exit non-zero even when they succeed;
    # absence of the binary is the ground truth.
    # Safety net: remove user-owned leftovers; system
    # packages (e.g. /usr/bin/nvim from apt) are reported instead.
    if manifest_is_installed "$dir"; then
      log_warn "Uninstall incomplete - cleaning user-owned leftovers"
      local leftover=0 b bpath
      while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        command -v "$b" >/dev/null 2>&1 || continue
        bpath="$(command -v "$b")"
        case "$bpath" in
          "$HOME"/*)
            rm -f "$bpath"
            ;;
          *)
            leftover=1
            list_item "System binary kept: $bpath (remove with your package manager)"
            ;;
        esac
      done < <(manifest_check_list "$dir")
      manifest_is_installed "$dir" || rc=0
      [[ $leftover -eq 1 ]] && rc=0   # nothing more we can do; not an error
    fi
  else
    rc=0
  fi

  # Generic configuration cleanup (Ubuntu/WSL): tools follow the
  # ~/.tool / ~/.config/tool / ~/.cache/tool / ~/.local/share/tool
  # conventions - offer removal when anything exists.
  if [[ "$CORE_ENV" != "termux" && $rc -eq 0 ]]; then
    local found=()
    local cand
    for cand in "$HOME/.$name" "$HOME/.config/$name" "$HOME/.cache/$name" "$HOME/.local/share/$name"; do
      [[ -e "$cand" ]] && found+=("$cand")
    done
    if [[ ${#found[@]} -gt 0 ]]; then
      echo
      log_info "Configuration folders found for $display:"
      local f
      for f in "${found[@]}"; do
        list_item "$f"
      done
      local answer
      read_confirm_default "Delete these configuration files?" "n" answer
      if [[ "$answer" == "y" ]]; then
        for f in "${found[@]}"; do
          rm -rf "$f"
        done
        log_success "Configuration files removed"
      else
        log_info "Keeping configuration files"
      fi
      echo
    fi
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

# _engine_check_versions : runs in subprocess via loading.
# Writes results to _ECV_OUTFILE so parent can read them.
_engine_check_versions() {
  {
    echo "LOCAL=$(bash "$_ECV_SCRIPT" version-local 2>/dev/null)"
    echo "REMOTE=$(bash "$_ECV_SCRIPT" version-remote 2>/dev/null)"
  } > "$_ECV_OUTFILE"
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
    # Pre-load every directory official installers commonly use, so
    # freshly-installed binaries resolve inside THIS session too.
    export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.factory/bin:$HOME/.antigravity/bin:$HOME/bin:$PATH"
  fi

  # Version flow: local -> remote -> compare -> suggest.
  local local_ver remote_ver
  export CORE_PATH
  export _ECV_SCRIPT="$script"
  local _ecv_tmp
  _ecv_tmp="$(mktemp)"
  export _ECV_OUTFILE="$_ecv_tmp"
  if [[ "$CORE_ENV" == "termux" ]]; then
    loading "Checking versions" _engine_check_versions
  else
    _engine_check_versions
  fi
  eval "$(cat "$_ecv_tmp")"
  rm -f "$_ecv_tmp"

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
