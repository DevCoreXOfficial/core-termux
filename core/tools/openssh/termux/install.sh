#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_openssh_pkg() {
  loading "Installing OpenSSH" _install_openssh_pkg_impl
}

_install_openssh_pkg_impl() {
  if ! yes | pkg install openssh &>>"$LOG_FILE"; then
    log_error "Failed to install OpenSSH"
    return 1
  fi
  return 0
}

install_openssh() {
  if command -v sshd &>/dev/null; then
    log_info "OpenSSH is already installed"
    return 2
  fi

  separator
  box_large "Installing OpenSSH"
  separator
  echo

  log_info "Installing OpenSSH..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_openssh_pkg || return 1
  log_success "OpenSSH installed"
  return 0
}

_uninstall_openssh_pkg() {
  loading "Uninstalling OpenSSH" _uninstall_openssh_pkg_impl
}

_uninstall_openssh_pkg_impl() {
  if ! pkg uninstall openssh -y &>>"$LOG_FILE"; then
    log_error "Failed to uninstall OpenSSH"
    return 1
  fi
  return 0
}

uninstall_openssh() {
  if ! command -v sshd &>/dev/null; then
    log_info "OpenSSH is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling OpenSSH"
  separator
  echo

  confirm_remove_configs "OpenSSH" \
    "$HOME/.ssh"

  log_info "Uninstalling OpenSSH..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _uninstall_openssh_pkg || return 1
  log_success "OpenSSH uninstalled"
  return 0
}

_update_openssh_pkg() {
  loading "Updating OpenSSH" _do_openssh_update
}

_do_openssh_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade openssh -y &>>"$LOG_FILE"
}

update_openssh() {
  _check_update_needed "OpenSSH" "$(_get_installed_pkg_version openssh OpenSSH)" "$(_get_remote_pkg_version openssh)" _update_openssh_pkg
}

reinstall_openssh() {
  uninstall_openssh
  install_openssh
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_openssh; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_openssh; fi
if [[ "${1:-}" == "update" ]]; then update_openssh; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_openssh; fi
