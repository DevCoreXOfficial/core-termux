#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
source "$CORE_PATH/tools/bun/termux/lib.sh"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openspec_dependencies() {
  loading "Installing dependencies" _openspec_dependencies_impl
}

_openspec_dependencies_impl() {
  declare -A DEPS=()

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  _ensure_bun || return 1

  return 0
}

_install_openspec_bun() {
  loading "Installing OpenSpec" _install_openspec_bun_impl
}

_install_openspec_bun_impl() {
  if ! _install_pkg_fallback "@fission-ai/openspec@latest"; then
    log_error "Failed to install OpenSpec"
    return 1
  fi

  return 0
}

install_openspec() {
  if command -v openspec &>/dev/null; then
    log_info "OpenSpec is already installed"
    return 2
  fi

  separator
  box_large "Installing OpenSpec"
  separator
  echo

  log_info "Installing OpenSpec..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _openspec_dependencies || return 1
  _install_openspec_bun || return 1

  log_success "OpenSpec installed successfully"
  return 0
}

uninstall_openspec() {
  if ! command -v openspec &>/dev/null; then
    log_info "OpenSpec is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling OpenSpec"
  separator
  echo

  confirm_remove_configs "OpenSpec" \
    "$HOME/.config/openspec"

  log_info "Uninstalling OpenSpec..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing OpenSpec" _uninstall_openspec_impl

  log_success "OpenSpec uninstalled"
  return 0
}

_uninstall_openspec_impl() {
  _uninstall_pkg_fallback "@fission-ai/openspec"
  return 0
}

update_openspec() {
  _check_update_needed "OpenSpec" "$(_get_installed_version openspec)" "$(_get_remote_npm_version @fission-ai/openspec)" _update_openspec
}

_update_openspec() {
  loading "Updating OpenSpec" _update_openspec_impl
}

_update_openspec_impl() {
  if ! _install_pkg_fallback "@fission-ai/openspec@latest"; then
    log_error "Failed to update OpenSpec"
    return 1
  fi
  return 0
}

reinstall_openspec() {
  uninstall_openspec
  install_openspec
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_openspec; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_openspec; fi
if [[ "${1:-}" == "update" ]]; then update_openspec; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_openspec; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version openspec; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_npm_version @fission-ai/openspec; fi
