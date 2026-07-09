#!/data/data/com.termux/files/usr/bin/bash

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
	_check_update_needed "Bat" "$(_get_installed_pkg_version bat "Bat")" "$(_get_remote_pkg_version bat)" _update_bat_pkg
}

reinstall_bat() {
	uninstall_bat
	install_bat
}
