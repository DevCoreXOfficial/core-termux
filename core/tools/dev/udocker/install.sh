#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_udocker_pkg() {
	loading "Installing Udocker" _install_udocker_pkg_impl
}

_install_udocker_pkg_impl() {
	if ! yes | pkg install udocker &>>"$LOG_FILE"; then
		log_error "Failed to install Udocker"
		return 1
	fi
	return 0
}

_uninstall_udocker_pkg() {
	loading "Uninstalling Udocker" _uninstall_udocker_pkg_impl
}

_uninstall_udocker_pkg_impl() {
	if ! pkg uninstall udocker -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Udocker"
		return 1
	fi
	return 0
}

_update_udocker_pkg() {
  loading "Updating Udocker" _do_udocker_update
}

_do_udocker_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade udocker -y &>>"$LOG_FILE"
}

install_udocker() {
	if command -v udocker &>/dev/null; then
		log_info "Udocker is already installed"
		return 2
	fi
	log_info "Installing Udocker..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_udocker_pkg || return 1
	log_success "Udocker installed"
	return 0
}

uninstall_udocker() {
	if ! command -v udocker &>/dev/null; then
		log_info "Udocker is not installed"
		return 2
	fi
	log_info "Uninstalling Udocker..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_udocker_pkg || return 1
	log_success "Udocker uninstalled"
	return 0
}

update_udocker() {
	_check_update_needed "Udocker" "$(_get_installed_pkg_version udocker "Udocker")" "$(_get_remote_pkg_version udocker)" _update_udocker_pkg
}

reinstall_udocker() {
	uninstall_udocker
	install_udocker
}
