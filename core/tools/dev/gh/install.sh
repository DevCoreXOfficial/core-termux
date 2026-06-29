#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_gh_pkg() {
	loading "Installing GitHub CLI" _install_gh_pkg_impl
}

_install_gh_pkg_impl() {
	if ! yes | pkg install gh &>>"$LOG_FILE"; then
		log_error "Failed to install GitHub CLI"
		return 1
	fi
	return 0
}

_uninstall_gh_pkg() {
	loading "Uninstalling GitHub CLI" _uninstall_gh_pkg_impl
}

_uninstall_gh_pkg_impl() {
	if ! pkg uninstall gh -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall GitHub CLI"
		return 1
	fi
	return 0
}

_update_gh_pkg() {
	loading "Updating GitHub CLI" _update_gh_pkg_impl
}

_update_gh_pkg_impl() {
	if ! pkg upgrade gh -y &>>"$LOG_FILE"; then
		log_error "Failed to update GitHub CLI"
		return 1
	fi
	return 0
}

install_gh() {
	if command -v gh &>/dev/null; then
		log_info "GitHub CLI is already installed"
		return 2
	fi
	log_info "Installing GitHub CLI..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_gh_pkg || return 1
	log_success "GitHub CLI installed"
	return 0
}

uninstall_gh() {
	if ! command -v gh &>/dev/null; then
		log_info "GitHub CLI is not installed"
		return 2
	fi
	log_info "Uninstalling GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_gh_pkg || return 1
	log_success "GitHub CLI uninstalled"
	return 0
}

update_gh() {
	log_info "Updating GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_gh_pkg || return 1
	log_success "GitHub CLI updated"
	return 0
}

reinstall_gh() {
	uninstall_gh
	install_gh
}
