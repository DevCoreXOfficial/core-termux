#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_fx_install_binary() {
  loading "Installing fx" _fx_install_binary_impl
}

_fx_install_binary_impl() {
  if ! curl -fsSL https://fx.sh/setup.sh | bash &>>"$LOG_FILE"; then
    log_error "Failed to install fx"
    return 1
  fi
  return 0
}

install_fx() {
  if command -v fx &>/dev/null; then
    log_info "fx is already installed"
    return 2
  fi
  separator
  box_large "Installing fx"
  separator
  echo
  log_info "Installing fx..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _fx_install_binary || return 1

  log_success "fx installed"
  return 0
}

uninstall_fx() {
  _walkie_remove_wrapper fx
  if ! command -v fx &>/dev/null; then
    log_info "fx is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling fx"
  separator
  echo

  confirm_remove_configs "fx" \
    "$HOME/.fx" \
    "$HOME/.config/fx"

  log_info "Uninstalling fx..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing fx" _uninstall_fx_impl

  log_success "fx uninstalled"
  return 0
}

_uninstall_fx_impl() {
  local fx_bin
  fx_bin="$(command -v fx 2>/dev/null)"
  if [ -n "$fx_bin" ] && [ -f "$fx_bin" ]; then
    rm -f "$fx_bin"
  fi
  rm -f "$HOME/.local/bin/fx" 2>/dev/null
  return 0
}

update_fx() {
  _check_update_needed "fx" "$(_get_installed_version fx)" "$(_get_remote_github_version vercel-labs/fx)" _update_fx
}

_update_fx() {
  _update_fx_impl
}

_update_fx_impl() {
  loading "Updating fx" _update_fx_binary
}

_update_fx_binary() {
  if ! curl -fsSL https://fx.sh/setup.sh | bash &>>"$LOG_FILE"; then
    log_error "Failed to update fx"
    return 1
  fi
  return 0
}

reinstall_fx() {
  uninstall_fx
  install_fx
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_fx; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_fx; fi
if [[ "${1:-}" == "update" ]]; then update_fx; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_fx; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version fx; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version vercel-labs/fx; fi
