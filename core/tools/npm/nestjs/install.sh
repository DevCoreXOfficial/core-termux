#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_nestjs_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_nestjs_npm() {
  loading "Installing NestJS CLI" _install_nestjs_npm_impl
}

_install_nestjs_npm_impl() {
  if ! npm install -g @nestjs/cli &>>"$LOG_FILE"; then
    log_error "Failed to install NestJS CLI"
    return 1
  fi
  return 0
}

install_nestjs() {
  if command -v nest &>/dev/null; then
    return 0
  fi
  log_info "Installing NestJS CLI..."

  _nestjs_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_nestjs_npm || return 1
  log_success "NestJS CLI installed"
  return 0
}

_uninstall_nestjs_npm() {
  loading "Uninstalling NestJS CLI" _uninstall_nestjs_npm_impl
}

_uninstall_nestjs_npm_impl() {
  if ! npm uninstall -g @nestjs/cli &>>"$LOG_FILE"; then
    log_error "Failed to uninstall NestJS CLI"
    return 1
  fi
  return 0
}

uninstall_nestjs() {
  if ! command -v nest &>/dev/null; then
    log_info "NestJS CLI is not installed"
    return 0
  fi
  log_info "Uninstalling NestJS CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_nestjs_npm || return 1
  log_success "NestJS CLI uninstalled"
  return 0
}

_update_nestjs_npm() {
  loading "Updating NestJS CLI" _update_nestjs_npm_impl
}

_update_nestjs_npm_impl() {
  if ! npm update -g @nestjs/cli &>>"$LOG_FILE"; then
    log_error "Failed to update NestJS CLI"
    return 1
  fi
  return 0
}

update_nestjs() {
  log_info "Updating NestJS CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_nestjs_npm || return 1
  log_success "NestJS CLI updated"
  return 0
}

reinstall_nestjs() {
  uninstall_nestjs
  install_nestjs
}
