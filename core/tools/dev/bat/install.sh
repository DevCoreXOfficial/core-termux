#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
	loading "Updating Bat" _update_bat_pkg_impl
}

_update_bat_pkg_impl() {
	if ! pkg upgrade bat -y &>>"$LOG_FILE"; then
		log_error "Failed to update Bat"
		return 1
	fi
	return 0
}

install_bat() {
	if command -v bat &>/dev/null; then
		log_info "Bat is already installed"
		return 2
	fi
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
	log_info "Uninstalling Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_bat_pkg || return 1
	log_success "Bat uninstalled"
	return 0
}

update_bat() {
	log_info "Updating Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_bat_pkg || return 1
	log_success "Bat updated"
	return 0
}

reinstall_bat() {
	uninstall_bat
	install_bat
}
