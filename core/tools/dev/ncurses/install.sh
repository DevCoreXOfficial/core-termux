#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_ncurses_pkg() {
	loading "Installing Ncurses Utils" _install_ncurses_pkg_impl
}

_install_ncurses_pkg_impl() {
	if ! yes | pkg install ncurses-utils &>>"$LOG_FILE"; then
		log_error "Failed to install Ncurses Utils"
		return 1
	fi
	return 0
}

_uninstall_ncurses_pkg() {
	loading "Uninstalling Ncurses Utils" _uninstall_ncurses_pkg_impl
}

_uninstall_ncurses_pkg_impl() {
	if ! pkg uninstall ncurses-utils -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Ncurses Utils"
		return 1
	fi
	return 0
}

_update_ncurses_pkg() {
	loading "Updating Ncurses Utils" _update_ncurses_pkg_impl
}

_update_ncurses_pkg_impl() {
	if ! pkg upgrade ncurses-utils -y &>>"$LOG_FILE"; then
		log_error "Failed to update Ncurses Utils"
		return 1
	fi
	return 0
}

install_ncurses() {
	if command -v tput &>/dev/null; then
		log_info "Ncurses Utils is already installed"
		return 2
	fi
	log_info "Installing Ncurses Utils..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_ncurses_pkg || return 1
	log_success "Ncurses Utils installed"
	return 0
}

uninstall_ncurses() {
	if ! command -v tput &>/dev/null; then
		log_info "Ncurses Utils is not installed"
		return 2
	fi
	log_info "Uninstalling Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_ncurses_pkg || return 1
	log_success "Ncurses Utils uninstalled"
	return 0
}

update_ncurses() {
	log_info "Updating Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_ncurses_pkg || return 1
	log_success "Ncurses Utils updated"
	return 0
}

reinstall_ncurses() {
	uninstall_ncurses
	install_ncurses
}
