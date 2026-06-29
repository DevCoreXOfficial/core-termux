#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_vercel_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_vercel_npm() {
  loading "Installing Vercel CLI" _install_vercel_npm_impl
}

_install_vercel_npm_impl() {
  if ! npm install -g vercel &>>"$LOG_FILE"; then
    log_error "Failed to install Vercel CLI"
    return 1
  fi
  return 0
}

install_vercel() {
  if command -v vercel &>/dev/null; then
    return 0
  fi
  log_info "Installing Vercel CLI..."

  _vercel_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_vercel_npm || return 1
  log_success "Vercel CLI installed"
  return 0
}

_uninstall_vercel_npm() {
  loading "Uninstalling Vercel CLI" _uninstall_vercel_npm_impl
}

_uninstall_vercel_npm_impl() {
  if ! npm uninstall -g vercel &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Vercel CLI"
    return 1
  fi
  return 0
}

uninstall_vercel() {
  if ! command -v vercel &>/dev/null; then
    log_info "Vercel CLI is not installed"
    return 0
  fi
  log_info "Uninstalling Vercel CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_vercel_npm || return 1
  log_success "Vercel CLI uninstalled"
  return 0
}

_update_vercel_npm() {
  loading "Updating Vercel CLI" _update_vercel_npm_impl
}

_update_vercel_npm_impl() {
  if ! npm update -g vercel &>>"$LOG_FILE"; then
    log_error "Failed to update Vercel CLI"
    return 1
  fi
  return 0
}

update_vercel() {
  log_info "Updating Vercel CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_vercel_npm || return 1
  log_success "Vercel CLI updated"
  return 0
}

reinstall_vercel() {
  uninstall_vercel
  install_vercel
}
