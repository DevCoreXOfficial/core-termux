#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/tools/lang/bun/install"

LOG_FILE="$CORE_CACHE/install_ai.log"

_supercode_dependencies() {
  loading "Installing dependencies" _supercode_dependencies_impl
}

_supercode_dependencies_impl() {
  _ensure_bun || return 1
  return 0
}

_install_supercode_bun() {
  loading "Installing SuperCode" _install_supercode_bun_impl
}

_install_supercode_bun_impl() {
  if ! bun install -g supercode-cli &>>"$LOG_FILE"; then
    log_error "Failed to install SuperCode"
    return 1
  fi
  return 0
}

install_supercode() {
  if command -v supercode &>/dev/null; then
    log_info "SuperCode is already installed"
    return 2
  fi

  log_info "Installing SuperCode..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _supercode_dependencies || return 1
  _install_supercode_bun || return 1

  log_success "SuperCode installed successfully"
  return 0
}

uninstall_supercode() {
  if ! command -v supercode &>/dev/null; then
    log_info "SuperCode is not installed"
    return 2
  fi
  log_info "Uninstalling SuperCode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing SuperCode" _uninstall_supercode_impl

  log_success "SuperCode uninstalled"
  return 0
}

_uninstall_supercode_impl() {
  if ! bun uninstall -g supercode-cli &>>"$LOG_FILE"; then
    log_error "Failed to uninstall SuperCode"
    return 1
  fi
  return 0
}

update_supercode() {
  _check_update_needed "SuperCode" "$(_get_installed_version supercode)" "$(_get_remote_npm_version supercode-cli)" _update_supercode
}

_update_supercode() {
  loading "Updating SuperCode" _update_supercode_impl
}

_update_supercode_impl() {
  if ! bun install -g supercode-cli@latest &>>"$LOG_FILE"; then
    log_error "Failed to update SuperCode"
    return 1
  fi
  return 0
}

reinstall_supercode() {
  uninstall_supercode
  install_supercode
}
