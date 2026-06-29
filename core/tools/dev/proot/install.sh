#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
	loading "Updating Proot" _update_proot_pkg_impl
}

_update_proot_pkg_impl() {
	if ! pkg upgrade proot -y &>>"$LOG_FILE"; then
		log_error "Failed to update Proot"
		return 1
	fi
	return 0
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
	log_info "Updating Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_proot_pkg || return 1
	log_success "Proot updated"
	return 0
}

reinstall_proot() {
	uninstall_proot
	install_proot
}
