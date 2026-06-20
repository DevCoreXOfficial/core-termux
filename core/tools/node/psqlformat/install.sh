#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

_psqlformat_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs and Perl..."
  mkdir -p "$(dirname "$LOG_FILE")"
  pkg install nodejs-lts perl -y &>>"$LOG_FILE"
}

install_psqlformat() {
  if command -v psqlformat &>/dev/null; then
    return 0
  fi
  log_info "Installing PSQL Format..."

  _psqlformat_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if npm install -g psqlformat &>>"$LOG_FILE"; then
    log_success "PSQL Format installed"
    return 0
  else
    log_error "Failed to install PSQL Format"
    return 1
  fi
}

uninstall_psqlformat() {
  if ! command -v psqlformat &>/dev/null; then
    log_info "PSQL Format is not installed"
    return 0
  fi
  log_info "Uninstalling PSQL Format..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g psqlformat &>>"$LOG_FILE"; then
    log_success "PSQL Format uninstalled"
    return 0
  else
    log_error "Failed to uninstall PSQL Format"
    return 1
  fi
}

update_psqlformat() {
  log_info "Updating PSQL Format..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g psqlformat &>>"$LOG_FILE"; then
    log_success "PSQL Format updated"
    return 0
  else
    log_error "Failed to update PSQL Format"
    return 1
  fi
}

reinstall_psqlformat() {
  uninstall_psqlformat
  install_psqlformat
}

