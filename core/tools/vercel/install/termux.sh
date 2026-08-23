#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

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

  confirm_remove_configs "Vercel CLI" \
    "$HOME/.local/share/com.vercel.cli" \
    "$HOME/.cache/com.vercel.cli" \
    "$HOME/.config/com.vercel.cli"

  log_info "Uninstalling Vercel CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_vercel_npm || return 1
  log_success "Vercel CLI uninstalled"
  return 0
}

update_vercel() {
  _check_update_needed "Vercel CLI" "$(_get_installed_npm_version vercel Vercel CLI)" "$(_get_remote_npm_version vercel)" _update_vercel_impl
}

_update_vercel_impl() {
  loading "Updating Vercel CLI" _do_vercel_update
}

_do_vercel_update() {
  npm update -g vercel &>>"$LOG_FILE"
}

reinstall_vercel() {
  uninstall_vercel
  install_vercel
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_vercel; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_vercel; fi
if [[ "${1:-}" == "update" ]]; then update_vercel; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_vercel; fi
