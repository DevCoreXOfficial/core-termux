#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_npm.log"

_ncu_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_ncu_npm() {
  loading "Installing NPM Check Updates" _install_ncu_npm_impl
}

_install_ncu_npm_impl() {
  if ! npm install -g npm-check-updates &>>"$LOG_FILE"; then
    log_error "Failed to install NPM Check Updates"
    return 1
  fi
  return 0
}

install_ncu() {
  if command -v ncu &>/dev/null; then
    return 0
  fi
  log_info "Installing NPM Check Updates..."

  _ncu_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_ncu_npm || return 1
  log_success "NPM Check Updates installed"
  return 0
}

_uninstall_ncu_npm() {
  loading "Uninstalling NPM Check Updates" _uninstall_ncu_npm_impl
}

_uninstall_ncu_npm_impl() {
  if ! npm uninstall -g npm-check-updates &>>"$LOG_FILE"; then
    log_error "Failed to uninstall NPM Check Updates"
    return 1
  fi
  return 0
}

uninstall_ncu() {
  if ! command -v ncu &>/dev/null; then
    log_info "NPM Check Updates is not installed"
    return 0
  fi

  confirm_remove_configs "NPM Check Updates" \
    "$HOME/.config/configstore"

  log_info "Uninstalling NPM Check Updates..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_ncu_npm || return 1
  log_success "NPM Check Updates uninstalled"
  return 0
}

update_ncu() {
  _check_update_needed "NPM Check Updates" "$(_get_installed_npm_version npm-check-updates NPM Check Updates)" "$(_get_remote_npm_version npm-check-updates)" _update_ncu_impl
}

_update_ncu_impl() {
  loading "Updating NPM Check Updates" _do_ncu_update
}

_do_ncu_update() {
  npm update -g npm-check-updates &>>"$LOG_FILE"
}

reinstall_ncu() {
  uninstall_ncu
  install_ncu
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_ncu; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_ncu; fi
if [[ "${1:-}" == "update" ]]; then update_ncu; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_ncu; fi
