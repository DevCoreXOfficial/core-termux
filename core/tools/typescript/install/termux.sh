#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_npm.log"

_typescript_dependencies() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_info "Node.js and npm are already installed"
    return 0
  fi

  log_info "Installing Nodejs..."
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install nodejs-lts &>>"$LOG_FILE"
}

_install_typescript_npm() {
  loading "Installing TypeScript" _install_typescript_npm_impl
}

_install_typescript_npm_impl() {
  if ! npm install -g typescript &>>"$LOG_FILE"; then
    log_error "Failed to install TypeScript"
    return 1
  fi
  return 0
}

install_typescript() {
  if command -v tsc &>/dev/null; then
    return 0
  fi
  log_info "Installing TypeScript..."

  _typescript_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_typescript_npm || return 1
  log_success "TypeScript installed"
  return 0
}

_uninstall_typescript_npm() {
  loading "Uninstalling TypeScript" _uninstall_typescript_npm_impl
}

_uninstall_typescript_npm_impl() {
  if ! npm uninstall -g typescript &>>"$LOG_FILE"; then
    log_error "Failed to uninstall TypeScript"
    return 1
  fi
  return 0
}

uninstall_typescript() {
  if ! command -v tsc &>/dev/null; then
    log_info "TypeScript is not installed"
    return 0
  fi

  confirm_remove_configs "TypeScript" \
    "$HOME/.cache/typescript"

  log_info "Uninstalling TypeScript..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_typescript_npm || return 1
  log_success "TypeScript uninstalled"
  return 0
}

update_typescript() {
  _check_update_needed "TypeScript" "$(_get_installed_npm_version typescript TypeScript)" "$(_get_remote_npm_version typescript)" _update_typescript_impl
}

_update_typescript_impl() {
  loading "Updating TypeScript" _do_typescript_update
}

_do_typescript_update() {
  npm update -g typescript &>>"$LOG_FILE"
}

reinstall_typescript() {
  uninstall_typescript
  install_typescript
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_typescript; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_typescript; fi
if [[ "${1:-}" == "update" ]]; then update_typescript; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_typescript; fi
