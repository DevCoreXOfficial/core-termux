#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_make_pkg() {
	loading "Installing Make" _install_make_pkg_impl
}

_install_make_pkg_impl() {
	if ! yes | pkg install make &>>"$LOG_FILE"; then
		log_error "Failed to install Make"
		return 1
	fi
	return 0
}

_uninstall_make_pkg() {
	loading "Uninstalling Make" _uninstall_make_pkg_impl
}

_uninstall_make_pkg_impl() {
	if ! pkg uninstall make -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Make"
		return 1
	fi
	return 0
}

_update_make_pkg() {
	loading "Updating Make" _update_make_pkg_impl
}

_update_make_pkg_impl() {
	if ! pkg upgrade make -y &>>"$LOG_FILE"; then
		log_error "Failed to update Make"
		return 1
	fi
	return 0
}

install_make() {
	if command -v make &>/dev/null; then
		log_info "Make is already installed"
		return 2
	fi
	log_info "Installing Make..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_make_pkg || return 1
	log_success "Make installed"
	return 0
}

uninstall_make() {
	if ! command -v make &>/dev/null; then
		log_info "Make is not installed"
		return 2
	fi
	log_info "Uninstalling Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_make_pkg || return 1
	log_success "Make uninstalled"
	return 0
}

update_make() {
	log_info "Updating Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_make_pkg || return 1
	log_success "Make updated"
	return 0
}

reinstall_make() {
	uninstall_make
	install_make
}
