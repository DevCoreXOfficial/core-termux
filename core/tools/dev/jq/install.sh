#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_jq_pkg() {
	loading "Installing jq" _install_jq_pkg_impl
}

_install_jq_pkg_impl() {
	if ! yes | pkg install jq &>>"$LOG_FILE"; then
		log_error "Failed to install jq"
		return 1
	fi
	return 0
}

_uninstall_jq_pkg() {
	loading "Uninstalling jq" _uninstall_jq_pkg_impl
}

_uninstall_jq_pkg_impl() {
	if ! pkg uninstall jq -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall jq"
		return 1
	fi
	return 0
}

_update_jq_pkg() {
	loading "Updating jq" _update_jq_pkg_impl
}

_update_jq_pkg_impl() {
	if ! pkg upgrade jq -y &>>"$LOG_FILE"; then
		log_error "Failed to update jq"
		return 1
	fi
	return 0
}

install_jq() {
	if command -v jq &>/dev/null; then
		log_info "jq is already installed"
		return 2
	fi
	log_info "Installing jq..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_jq_pkg || return 1
	log_success "jq installed"
	return 0
}

uninstall_jq() {
	if ! command -v jq &>/dev/null; then
		log_info "jq is not installed"
		return 2
	fi
	log_info "Uninstalling jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_jq_pkg || return 1
	log_success "jq uninstalled"
	return 0
}

update_jq() {
	log_info "Updating jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_jq_pkg || return 1
	log_success "jq updated"
	return 0
}

reinstall_jq() {
	uninstall_jq
	install_jq
}
