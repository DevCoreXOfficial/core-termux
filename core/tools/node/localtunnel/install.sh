#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

_localtunnel_fix_openurl() {
  local openurl_js
  openurl_js="$(npm root -g)/localtunnel/node_modules/openurl/openurl.js"
  if [[ ! -f "$openurl_js" ]]; then
    openurl_js="$(npm root -g)/openurl/openurl.js"
  fi
  if [[ -f "$openurl_js" ]]; then
    sed -i "/default:/i\\
    case 'android':\\
        command = 'termux-open-url';\\
        break;" "$openurl_js"
  fi
}

_localtunnel_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_success "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."

  mkdir -p "$(dirname "$LOG_FILE")"
  pkg install nodejs-lts -y &>>"$LOG_FILE"
}

install_localtunnel() {
  if command -v lt &>/dev/null; then
    return 0
  fi
  log_info "Installing Localtunnel..."

  _localtunnel_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if npm install -g localtunnel &>>"$LOG_FILE"; then
    log_success "Localtunnel installed"
    log_info "Applying localtunnel fix for Android..."
    _localtunnel_fix_openurl &>>"$LOG_FILE"
    return 0
  else
    log_error "Failed to install Localtunnel"
    return 1
  fi
}

uninstall_localtunnel() {
  log_info "Uninstalling Localtunnel..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g localtunnel &>>"$LOG_FILE"; then
    log_success "Localtunnel uninstalled"
    return 0
  else
    log_error "Failed to uninstall Localtunnel"
    return 1
  fi
}

update_localtunnel() {
  log_info "Updating Localtunnel..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g localtunnel &>>"$LOG_FILE"; then
    log_success "Localtunnel updated"
    return 0
  else
    log_error "Failed to update Localtunnel"
    return 1
  fi
}

reinstall_localtunnel() {
  uninstall_localtunnel
  install_localtunnel
}

