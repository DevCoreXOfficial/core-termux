#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_shfmt_pkg() {
	loading "Installing Shfmt" _install_shfmt_pkg_impl
}

_install_shfmt_pkg_impl() {
	if ! yes | pkg install shfmt &>>"$LOG_FILE"; then
		log_error "Failed to install Shfmt"
		return 1
	fi
	return 0
}

_uninstall_shfmt_pkg() {
	loading "Uninstalling Shfmt" _uninstall_shfmt_pkg_impl
}

_uninstall_shfmt_pkg_impl() {
	if ! pkg uninstall shfmt -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Shfmt"
		return 1
	fi
	return 0
}

_update_shfmt_pkg() {
	loading "Updating Shfmt" _update_shfmt_pkg_impl
}

_update_shfmt_pkg_impl() {
	if ! pkg upgrade shfmt -y &>>"$LOG_FILE"; then
		log_error "Failed to update Shfmt"
		return 1
	fi
	return 0
}

install_shfmt() {
	if command -v shfmt &>/dev/null; then
		log_info "Shfmt is already installed"
		return 2
	fi
	log_info "Installing Shfmt..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_shfmt_pkg || return 1
	log_success "Shfmt installed"
	return 0
}

uninstall_shfmt() {
	if ! command -v shfmt &>/dev/null; then
		log_info "Shfmt is not installed"
		return 2
	fi
	log_info "Uninstalling Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_shfmt_pkg || return 1
	log_success "Shfmt uninstalled"
	return 0
}

update_shfmt() {
	log_info "Updating Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_shfmt_pkg || return 1
	log_success "Shfmt updated"
	return 0
}

reinstall_shfmt() {
	uninstall_shfmt
	install_shfmt
}
