#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

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
  loading "Updating Ncurses Utils" _do_ncurses_update
}

_do_ncurses_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade ncurses-utils -y &>>"$LOG_FILE"
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
	_check_update_needed "Ncurses Utils" "$(_get_installed_pkg_version ncurses-utils "Ncurses Utils")" "$(_get_remote_pkg_version ncurses-utils)" _update_ncurses_pkg
}

reinstall_ncurses() {
	uninstall_ncurses
	install_ncurses
}
