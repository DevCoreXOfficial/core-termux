#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_php_pkg() {
	loading "Installing PHP" _install_php_pkg_impl
}

_install_php_pkg_impl() {
	if ! yes | pkg install php &>>"$LOG_FILE"; then
		log_error "Failed to install PHP"
		return 1
	fi
	return 0
}

install_php() {
	if command -v php &>/dev/null; then
		log_info "PHP is already installed"
		return 2
	fi
	log_info "Installing PHP..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_php_pkg || return 1
	log_success "PHP installed"
	return 0
}

_uninstall_php_pkg() {
	loading "Uninstalling PHP" _uninstall_php_pkg_impl
}

_uninstall_php_pkg_impl() {
	if ! pkg uninstall php -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall PHP"
		return 1
	fi
	return 0
}

uninstall_php() {
	if ! command -v php &>/dev/null; then
		log_info "PHP is not installed"
		return 2
	fi
	log_info "Uninstalling PHP..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_php_pkg || return 1
	log_success "PHP uninstalled"
	return 0
}

_update_php_pkg() {
	loading "Updating PHP" _update_php_pkg_impl
}

_update_php_pkg_impl() {
	if ! pkg upgrade php -y &>>"$LOG_FILE"; then
		log_error "Failed to update PHP"
		return 1
	fi
	return 0
}

update_php() {
	log_info "Updating PHP..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_update_php_pkg || return 1
	log_success "PHP updated"
	return 0
}

reinstall_php() {
	uninstall_php
	install_php
}
