#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_npm.log"

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
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."

  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_localtunnel_npm() {
  loading "Installing Localtunnel" _install_localtunnel_npm_impl
}

_install_localtunnel_npm_impl() {
  if ! npm install -g localtunnel &>>"$LOG_FILE"; then
    log_error "Failed to install Localtunnel"
    return 1
  fi
  log_info "Applying localtunnel fix for Android..."
  _localtunnel_fix_openurl &>>"$LOG_FILE"
  return 0
}

install_localtunnel() {
  if command -v lt &>/dev/null; then
    return 0
  fi
  log_info "Installing Localtunnel..."

  _localtunnel_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_localtunnel_npm || return 1
  log_success "Localtunnel installed"
  return 0
}

_uninstall_localtunnel_npm() {
  loading "Uninstalling Localtunnel" _uninstall_localtunnel_npm_impl
}

_uninstall_localtunnel_npm_impl() {
  if ! npm uninstall -g localtunnel &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Localtunnel"
    return 1
  fi
  return 0
}

uninstall_localtunnel() {
  if ! command -v lt &>/dev/null; then
    log_info "Localtunnel is not installed"
    return 0
  fi
  log_info "Uninstalling Localtunnel..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_localtunnel_npm || return 1
  log_success "Localtunnel uninstalled"
  return 0
}

_update_localtunnel_npm() {
  loading "Updating Localtunnel" _update_localtunnel_npm_impl
}

_update_localtunnel_npm_impl() {
  if ! npm update -g localtunnel &>>"$LOG_FILE"; then
    log_error "Failed to update Localtunnel"
    return 1
  fi
  return 0
}

update_localtunnel() {
  log_info "Updating Localtunnel..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _update_localtunnel_npm || return 1
  log_success "Localtunnel updated"
  return 0
}

reinstall_localtunnel() {
  uninstall_localtunnel
  install_localtunnel
}
