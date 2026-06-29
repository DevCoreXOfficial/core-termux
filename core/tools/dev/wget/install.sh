#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_wget_pkg() {
	loading "Installing Wget" _install_wget_pkg_impl
}

_install_wget_pkg_impl() {
	if ! yes | pkg install wget &>>"$LOG_FILE"; then
		log_error "Failed to install Wget"
		return 1
	fi
	return 0
}

_uninstall_wget_pkg() {
	loading "Uninstalling Wget" _uninstall_wget_pkg_impl
}

_uninstall_wget_pkg_impl() {
	if ! pkg uninstall wget -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Wget"
		return 1
	fi
	return 0
}

_update_wget_pkg() {
	loading "Updating Wget" _update_wget_pkg_impl
}

_update_wget_pkg_impl() {
	if ! pkg upgrade wget -y &>>"$LOG_FILE"; then
		log_error "Failed to update Wget"
		return 1
	fi
	return 0
}

install_wget() {
	if command -v wget &>/dev/null; then
		log_info "Wget is already installed"
		return 2
	fi
	log_info "Installing Wget..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_wget_pkg || return 1
	log_success "Wget installed"
	return 0
}

uninstall_wget() {
	if ! command -v wget &>/dev/null; then
		log_info "Wget is not installed"
		return 2
	fi
	log_info "Uninstalling Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_wget_pkg || return 1
	log_success "Wget uninstalled"
	return 0
}

update_wget() {
	log_info "Updating Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_wget_pkg || return 1
	log_success "Wget updated"
	return 0
}

reinstall_wget() {
	uninstall_wget
	install_wget
}
