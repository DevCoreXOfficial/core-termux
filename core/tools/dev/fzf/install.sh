#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_fzf_pkg() {
	loading "Installing Fzf" _install_fzf_pkg_impl
}

_install_fzf_pkg_impl() {
	if ! yes | pkg install fzf &>>"$LOG_FILE"; then
		log_error "Failed to install Fzf"
		return 1
	fi
	return 0
}

_uninstall_fzf_pkg() {
	loading "Uninstalling Fzf" _uninstall_fzf_pkg_impl
}

_uninstall_fzf_pkg_impl() {
	if ! pkg uninstall fzf -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Fzf"
		return 1
	fi
	return 0
}

_update_fzf_pkg() {
	loading "Updating Fzf" _update_fzf_pkg_impl
}

_update_fzf_pkg_impl() {
	if ! pkg upgrade fzf -y &>>"$LOG_FILE"; then
		log_error "Failed to update Fzf"
		return 1
	fi
	return 0
}

install_fzf() {
	if command -v fzf &>/dev/null; then
		log_info "Fzf is already installed"
		return 2
	fi
	log_info "Installing Fzf..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_fzf_pkg || return 1
	log_success "Fzf installed"
	return 0
}

uninstall_fzf() {
	if ! command -v fzf &>/dev/null; then
		log_info "Fzf is not installed"
		return 2
	fi
	log_info "Uninstalling Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_fzf_pkg || return 1
	log_success "Fzf uninstalled"
	return 0
}

update_fzf() {
	log_info "Updating Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_fzf_pkg || return 1
	log_success "Fzf updated"
	return 0
}

reinstall_fzf() {
	uninstall_fzf
	install_fzf
}
