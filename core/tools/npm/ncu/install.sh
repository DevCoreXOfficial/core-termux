#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
  log_info "Uninstalling NPM Check Updates..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_ncu_npm || return 1
  log_success "NPM Check Updates uninstalled"
  return 0
}

_update_ncu_npm() {
  loading "Updating NPM Check Updates" _update_ncu_npm_impl
}

_update_ncu_npm_impl() {
  if ! npm update -g npm-check-updates &>>"$LOG_FILE"; then
    log_error "Failed to update NPM Check Updates"
    return 1
  fi
  return 0
}

update_ncu() {
  log_info "Updating NPM Check Updates..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_ncu_npm || return 1
  log_success "NPM Check Updates updated"
  return 0
}

reinstall_ncu() {
  uninstall_ncu
  install_ncu
}
