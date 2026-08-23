#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_proot_pkg() {
	loading "Installing Proot" _install_proot_pkg_impl
}

_install_proot_pkg_impl() {
	if ! yes | pkg install proot &>>"$LOG_FILE"; then
		log_error "Failed to install Proot"
		return 1
	fi
	return 0
}

_uninstall_proot_pkg() {
	loading "Uninstalling Proot" _uninstall_proot_pkg_impl
}

_uninstall_proot_pkg_impl() {
	if ! pkg uninstall proot -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Proot"
		return 1
	fi
	return 0
}

_update_proot_pkg() {
  loading "Updating Proot" _do_proot_update
}

_do_proot_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade proot -y &>>"$LOG_FILE"
}

install_proot() {
	if command -v proot &>/dev/null; then
		log_info "Proot is already installed"
		return 2
	fi
	log_info "Installing Proot..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_proot_pkg || return 1
	log_success "Proot installed"
	return 0
}

uninstall_proot() {
	if ! command -v proot &>/dev/null; then
		log_info "Proot is not installed"
		return 2
	fi
	log_info "Uninstalling Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_proot_pkg || return 1
	log_success "Proot uninstalled"
	return 0
}

update_proot() {
	_check_update_needed "Proot" "$(_get_installed_pkg_version proot Proot)" "$(_get_remote_pkg_version proot)" _update_proot_pkg
}

reinstall_proot() {
	uninstall_proot
	install_proot
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_proot; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_proot; fi
if [[ "${1:-}" == "update" ]]; then update_proot; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_proot; fi
