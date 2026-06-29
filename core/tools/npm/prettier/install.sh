#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_prettier_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_prettier_npm() {
  loading "Installing Prettier" _install_prettier_npm_impl
}

_install_prettier_npm_impl() {
  if ! npm install -g prettier &>>"$LOG_FILE"; then
    log_error "Failed to install Prettier"
    return 1
  fi
  return 0
}

install_prettier() {
  if command -v prettier &>/dev/null; then
    return 0
  fi
  log_info "Installing Prettier..."

  _prettier_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_prettier_npm || return 1
  log_success "Prettier installed"
  return 0
}

_uninstall_prettier_npm() {
  loading "Uninstalling Prettier" _uninstall_prettier_npm_impl
}

_uninstall_prettier_npm_impl() {
  if ! npm uninstall -g prettier &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Prettier"
    return 1
  fi
  return 0
}

uninstall_prettier() {
  if ! command -v prettier &>/dev/null; then
    log_info "Prettier is not installed"
    return 0
  fi
  log_info "Uninstalling Prettier..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_prettier_npm || return 1
  log_success "Prettier uninstalled"
  return 0
}

_update_prettier_npm() {
  loading "Updating Prettier" _update_prettier_npm_impl
}

_update_prettier_npm_impl() {
  if ! npm update -g prettier &>>"$LOG_FILE"; then
    log_error "Failed to update Prettier"
    return 1
  fi
  return 0
}

update_prettier() {
  log_info "Updating Prettier..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_prettier_npm || return 1
  log_success "Prettier updated"
  return 0
}

reinstall_prettier() {
  uninstall_prettier
  install_prettier
}
