#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

_vercel_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_success "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  pkg install nodejs-lts -y &>>"$LOG_FILE"
}

install_vercel() {
  if command -v vercel &>/dev/null; then
    return 0
  fi
  log_info "Installing Vercel CLI..."

  _vercel_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if npm install -g vercel &>>"$LOG_FILE"; then
    log_success "Vercel CLI installed"
    return 0
  else
    log_error "Failed to install Vercel CLI"
    return 1
  fi
}

uninstall_vercel() {
  log_info "Uninstalling Vercel CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g vercel &>>"$LOG_FILE"; then
    log_success "Vercel CLI uninstalled"
    return 0
  else
    log_error "Failed to uninstall Vercel CLI"
    return 1
  fi
}

update_vercel() {
  log_info "Updating Vercel CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g vercel &>>"$LOG_FILE"; then
    log_success "Vercel CLI updated"
    return 0
  else
    log_error "Failed to update Vercel CLI"
    return 1
  fi
}

reinstall_vercel() {
  uninstall_vercel
  install_vercel
}

