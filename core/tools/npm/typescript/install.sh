#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_typescript_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_typescript_npm() {
  loading "Installing TypeScript" _install_typescript_npm_impl
}

_install_typescript_npm_impl() {
  if ! npm install -g typescript &>>"$LOG_FILE"; then
    log_error "Failed to install TypeScript"
    return 1
  fi
  return 0
}

install_typescript() {
  if command -v tsc &>/dev/null; then
    return 0
  fi
  log_info "Installing TypeScript..."

  _typescript_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_typescript_npm || return 1
  log_success "TypeScript installed"
  return 0
}

_uninstall_typescript_npm() {
  loading "Uninstalling TypeScript" _uninstall_typescript_npm_impl
}

_uninstall_typescript_npm_impl() {
  if ! npm uninstall -g typescript &>>"$LOG_FILE"; then
    log_error "Failed to uninstall TypeScript"
    return 1
  fi
  return 0
}

uninstall_typescript() {
  if ! command -v tsc &>/dev/null; then
    log_info "TypeScript is not installed"
    return 0
  fi
  log_info "Uninstalling TypeScript..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_typescript_npm || return 1
  log_success "TypeScript uninstalled"
  return 0
}

_update_typescript_npm() {
  loading "Updating TypeScript" _update_typescript_npm_impl
}

_update_typescript_npm_impl() {
  if ! npm update -g typescript &>>"$LOG_FILE"; then
    log_error "Failed to update TypeScript"
    return 1
  fi
  return 0
}

update_typescript() {
  log_info "Updating TypeScript..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_typescript_npm || return 1
  log_success "TypeScript updated"
  return 0
}

reinstall_typescript() {
  uninstall_typescript
  install_typescript
}
