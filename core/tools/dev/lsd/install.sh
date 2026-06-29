#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_lsd_pkg() {
	loading "Installing LSD" _install_lsd_pkg_impl
}

_install_lsd_pkg_impl() {
	if ! yes | pkg install lsd &>>"$LOG_FILE"; then
		log_error "Failed to install LSD"
		return 1
	fi
	return 0
}

_uninstall_lsd_pkg() {
	loading "Uninstalling LSD" _uninstall_lsd_pkg_impl
}

_uninstall_lsd_pkg_impl() {
	if ! pkg uninstall lsd -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall LSD"
		return 1
	fi
	return 0
}

_update_lsd_pkg() {
	loading "Updating LSD" _update_lsd_pkg_impl
}

_update_lsd_pkg_impl() {
	if ! pkg upgrade lsd -y &>>"$LOG_FILE"; then
		log_error "Failed to update LSD"
		return 1
	fi
	return 0
}

install_lsd() {
	if command -v lsd &>/dev/null; then
		log_info "LSD is already installed"
		return 2
	fi
	log_info "Installing LSD..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_lsd_pkg || return 1
	log_success "LSD installed"
	return 0
}

uninstall_lsd() {
	if ! command -v lsd &>/dev/null; then
		log_info "LSD is not installed"
		return 2
	fi
	log_info "Uninstalling LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_lsd_pkg || return 1
	log_success "LSD uninstalled"
	return 0
}

update_lsd() {
	log_info "Updating LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_lsd_pkg || return 1
	log_success "LSD updated"
	return 0
}

reinstall_lsd() {
	uninstall_lsd
	install_lsd
}
