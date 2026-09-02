#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

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

  separator
  box_large "Installing NestJS"
  separator
  echo

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

  separator
  box_large "Uninstalling NestJS"
  separator
  echo

  log_info "Uninstalling NestJS CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_nestjs_npm || return 1
  log_success "NestJS CLI uninstalled"
  return 0
}

update_nestjs() {
  _check_update_needed "NestJS CLI" "$(_get_installed_npm_version @nestjs/cli NestJS CLI)" "$(_get_remote_npm_version @nestjs/cli)" _update_nestjs_impl
}

_update_nestjs_impl() {
  loading "Updating NestJS CLI" _do_nestjs_update
}

_do_nestjs_update() {
  npm update -g @nestjs/cli &>>"$LOG_FILE"
}

reinstall_nestjs() {
  uninstall_nestjs
  install_nestjs
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_nestjs; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_nestjs; fi
if [[ "${1:-}" == "update" ]]; then update_nestjs; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_nestjs; fi
