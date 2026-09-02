#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_tmux_pkg() {
  loading "Installing Tmux" _install_tmux_pkg_impl
}

_install_tmux_pkg_impl() {
  if ! yes | pkg install tmux &>>"$LOG_FILE"; then
    log_error "Failed to install Tmux"
    return 1
  fi
  return 0
}

install_tmux() {
  if command -v tmux &>/dev/null; then
    log_info "Tmux is already installed"
    return 2
  fi

  separator
  box_large "Installing tmux"
  separator
  echo

  log_info "Installing Tmux..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_tmux_pkg || return 1
  log_success "Tmux installed"
  return 0
}

_uninstall_tmux_pkg() {
  loading "Uninstalling Tmux" _uninstall_tmux_pkg_impl
}

_uninstall_tmux_pkg_impl() {
  if ! pkg uninstall tmux -y &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Tmux"
    return 1
  fi
  return 0
}

uninstall_tmux() {
  if ! command -v tmux &>/dev/null; then
    log_info "Tmux is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling tmux"
  separator
  echo

  log_info "Uninstalling Tmux..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_tmux_pkg || return 1
  log_success "Tmux uninstalled"
  return 0
}

_update_tmux_pkg() {
  loading "Updating Tmux" _do_tmux_update
}

_do_tmux_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade tmux -y &>>"$LOG_FILE"
}

update_tmux() {
  _check_update_needed "Tmux" "$(_get_installed_pkg_version tmux Tmux)" "$(_get_remote_pkg_version tmux)" _update_tmux_pkg
}

reinstall_tmux() {
  uninstall_tmux
  install_tmux
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_tmux; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_tmux; fi
if [[ "${1:-}" == "update" ]]; then update_tmux; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_tmux; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version tmux; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_pkg_version tmux; fi
