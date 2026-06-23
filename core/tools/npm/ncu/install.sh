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
  pkg install nodejs-lts -y &>>"$LOG_FILE"
}

install_ncu() {
  if command -v ncu &>/dev/null; then
    return 0
  fi
  log_info "Installing NPM Check Updates..."

  _ncu_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if npm install -g npm-check-updates &>>"$LOG_FILE"; then
    log_success "NPM Check Updates installed"
    return 0
  else
    log_error "Failed to install NPM Check Updates"
    return 1
  fi
}

uninstall_ncu() {
  if ! command -v ncu &>/dev/null; then
    log_info "NPM Check Updates is not installed"
    return 0
  fi
  log_info "Uninstalling NPM Check Updates..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g npm-check-updates &>>"$LOG_FILE"; then
    log_success "NPM Check Updates uninstalled"
    return 0
  else
    log_error "Failed to uninstall NPM Check Updates"
    return 1
  fi
}

update_ncu() {
  log_info "Updating NPM Check Updates..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g npm-check-updates &>>"$LOG_FILE"; then
    log_success "NPM Check Updates updated"
    return 0
  else
    log_error "Failed to update NPM Check Updates"
    return 1
  fi
}

reinstall_ncu() {
  uninstall_ncu
  install_ncu
}

