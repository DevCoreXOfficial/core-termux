#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_bat_pkg() {
	loading "Installing Bat" _install_bat_pkg_impl
}

_install_bat_pkg_impl() {
	if ! yes | pkg install bat &>>"$LOG_FILE"; then
		log_error "Failed to install Bat"
		return 1
	fi
	return 0
}

_uninstall_bat_pkg() {
	loading "Uninstalling Bat" _uninstall_bat_pkg_impl
}

_uninstall_bat_pkg_impl() {
	if ! pkg uninstall bat -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Bat"
		return 1
	fi
	return 0
}

_update_bat_pkg() {
  loading "Updating Bat" _do_bat_update
}

_do_bat_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade bat -y &>>"$LOG_FILE"
}

install_bat() {
	if command -v bat &>/dev/null; then
		log_info "Bat is already installed"
		return 2
	fi

	separator
	box_large "Installing Bat"
	separator
	echo

	log_info "Installing Bat..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_bat_pkg || return 1
	log_success "Bat installed"
	return 0
}

uninstall_bat() {
	if ! command -v bat &>/dev/null; then
		log_info "Bat is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Bat"
	separator
	echo

	log_info "Uninstalling Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_bat_pkg || return 1
	log_success "Bat uninstalled"
	return 0
}

update_bat() {
	_check_update_needed "Bat" "$(_get_installed_pkg_version bat "Bat")" "$(_get_remote_pkg_version bat)" _update_bat_pkg
}

reinstall_bat() {
	uninstall_bat
	install_bat
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_bat; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_bat; fi
if [[ "${1:-}" == "update" ]]; then update_bat; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_bat; fi
