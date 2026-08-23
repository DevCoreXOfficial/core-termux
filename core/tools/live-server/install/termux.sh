#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_npm.log"

_live_server_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_live_server_npm() {
  loading "Installing Live Server" _install_live_server_npm_impl
}

_install_live_server_npm_impl() {
  if ! npm install -g live-server &>>"$LOG_FILE"; then
    log_error "Failed to install Live Server"
    return 1
  fi
  return 0
}

install_live_server() {
  if command -v live-server &>/dev/null; then
    return 0
  fi

  log_info "Installing Live Server..."

  _live_server_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_live_server_npm || return 1
  log_success "Live Server installed"
  return 0
}

_uninstall_live_server_npm() {
  loading "Uninstalling Live Server" _uninstall_live_server_npm_impl
}

_uninstall_live_server_npm_impl() {
  if ! npm uninstall -g live-server &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Live Server"
    return 1
  fi
  return 0
}

uninstall_live_server() {
  if ! command -v live-server &>/dev/null; then
    log_info "Live Server is not installed"
    return 0
  fi
  log_info "Uninstalling Live Server..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_live_server_npm || return 1
  log_success "Live Server uninstalled"
  return 0
}

update_live_server() {
  _check_update_needed "Live Server" "$(_get_installed_npm_version live-server Live Server)" "$(_get_remote_npm_version live-server)" _update_live_server_impl
}

_update_live_server_impl() {
  loading "Updating Live Server" _do_live_server_update
}

_do_live_server_update() {
  npm update -g live-server &>>"$LOG_FILE"
}

reinstall_live_server() {
  uninstall_live_server
  install_live_server
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_live_server; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_live_server; fi
if [[ "${1:-}" == "update" ]]; then update_live_server; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_live_server; fi
