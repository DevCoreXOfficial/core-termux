#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_markserv_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_markserv_npm() {
  loading "Installing Markserv" _install_markserv_npm_impl
}

_install_markserv_npm_impl() {
  if ! npm install -g markserv &>>"$LOG_FILE"; then
    log_error "Failed to install Markserv"
    return 1
  fi
  return 0
}

install_markserv() {
  if command -v markserv &>/dev/null; then
    return 0
  fi
  log_info "Installing Markserv..."

  _markserv_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_markserv_npm || return 1
  log_success "Markserv installed"
  return 0
}

_uninstall_markserv_npm() {
  loading "Uninstalling Markserv" _uninstall_markserv_npm_impl
}

_uninstall_markserv_npm_impl() {
  if ! npm uninstall -g markserv &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Markserv"
    return 1
  fi
  return 0
}

uninstall_markserv() {
  if ! command -v markserv &>/dev/null; then
    log_info "Markserv is not installed"
    return 0
  fi
  log_info "Uninstalling Markserv..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_markserv_npm || return 1
  log_success "Markserv uninstalled"
  return 0
}

_update_markserv_npm() {
  loading "Updating Markserv" _update_markserv_npm_impl
}

_update_markserv_npm_impl() {
  if ! npm update -g markserv &>>"$LOG_FILE"; then
    log_error "Failed to update Markserv"
    return 1
  fi
  return 0
}

update_markserv() {
  log_info "Updating Markserv..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_markserv_npm || return 1
  log_success "Markserv updated"
  return 0
}

reinstall_markserv() {
  uninstall_markserv
  install_markserv
}
