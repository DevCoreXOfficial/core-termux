#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
source "$CORE_PATH/tools/bun/termux/lib.sh"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_supercode_dependencies() {
  loading "Installing dependencies" _supercode_dependencies_impl
}

_supercode_dependencies_impl() {
  _ensure_bun || return 1
  return 0
}

_install_supercode_bun() {
  loading "Installing SuperCode" _install_supercode_bun_impl
}

_install_supercode_bun_impl() {
  if ! _install_pkg_fallback "supercode-cli"; then
    log_error "Failed to install SuperCode"
    return 1
  fi
  return 0
}

install_supercode() {
  if command -v supercode &>/dev/null; then
    log_info "SuperCode is already installed"
    return 2
  fi

  log_info "Installing SuperCode..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _supercode_dependencies || return 1
  _install_supercode_bun || return 1

  log_success "SuperCode installed successfully"
  return 0
}

uninstall_supercode() {
  _walkie_remove_wrapper supercode
  if ! command -v supercode &>/dev/null; then
    log_info "SuperCode is not installed"
    return 2
  fi

  confirm_remove_configs "SuperCode" \
    "$HOME/.config/supercode" \
    "$HOME/.config/Code"

  log_info "Uninstalling SuperCode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing SuperCode" _uninstall_supercode_impl

  log_success "SuperCode uninstalled"
  return 0
}

_uninstall_supercode_impl() {
  _uninstall_pkg_fallback "supercode-cli"
  return 0
}

update_supercode() {
  _check_update_needed "SuperCode" "$(_get_installed_version supercode)" "$(_get_remote_npm_version supercode-cli)" _update_supercode
}

_update_supercode() {
  loading "Updating SuperCode" _update_supercode_impl
}

_update_supercode_impl() {
  if ! _install_pkg_fallback "supercode-cli@latest"; then
    log_error "Failed to update SuperCode"
    return 1
  fi
  return 0
}

reinstall_supercode() {
  uninstall_supercode
  install_supercode
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_supercode; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_supercode; fi
if [[ "${1:-}" == "update" ]]; then update_supercode; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_supercode; fi
