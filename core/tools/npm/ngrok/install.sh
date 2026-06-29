#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

_ngrok_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_ngrok_npm() {
  loading "Installing Ngrok" _install_ngrok_npm_impl
}

_install_ngrok_npm_impl() {
  if ! npm install -g ngrok &>>"$LOG_FILE"; then
    log_error "Failed to install Ngrok"
    return 1
  fi
  return 0
}

install_ngrok() {
  if command -v ngrok &>/dev/null; then
    return 0
  fi
  log_info "Installing Ngrok..."

  _ngrok_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_ngrok_npm || return 1
  log_success "Ngrok installed"
  return 0
}

_uninstall_ngrok_npm() {
  loading "Uninstalling Ngrok" _uninstall_ngrok_npm_impl
}

_uninstall_ngrok_npm_impl() {
  if ! npm uninstall -g ngrok &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Ngrok"
    return 1
  fi
  return 0
}

uninstall_ngrok() {
  if ! command -v ngrok &>/dev/null; then
    log_info "Ngrok is not installed"
    return 0
  fi
  log_info "Uninstalling Ngrok..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_ngrok_npm || return 1
  log_success "Ngrok uninstalled"
  return 0
}

_update_ngrok_npm() {
  loading "Updating Ngrok" _update_ngrok_npm_impl
}

_update_ngrok_npm_impl() {
  if ! npm update -g ngrok &>>"$LOG_FILE"; then
    log_error "Failed to update Ngrok"
    return 1
  fi
  return 0
}

update_ngrok() {
  log_info "Updating Ngrok..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_ngrok_npm || return 1
  log_success "Ngrok updated"
  return 0
}

reinstall_ngrok() {
  uninstall_ngrok
  install_ngrok
}
