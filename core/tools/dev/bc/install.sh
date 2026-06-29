#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_bc_pkg() {
	loading "Installing bc" _install_bc_pkg_impl
}

_install_bc_pkg_impl() {
	if ! yes | pkg install bc &>>"$LOG_FILE"; then
		log_error "Failed to install bc"
		return 1
	fi
	return 0
}

_uninstall_bc_pkg() {
	loading "Uninstalling bc" _uninstall_bc_pkg_impl
}

_uninstall_bc_pkg_impl() {
	if ! pkg uninstall bc -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall bc"
		return 1
	fi
	return 0
}

_update_bc_pkg() {
	loading "Updating bc" _update_bc_pkg_impl
}

_update_bc_pkg_impl() {
	if ! pkg upgrade bc -y &>>"$LOG_FILE"; then
		log_error "Failed to update bc"
		return 1
	fi
	return 0
}

install_bc() {
	if command -v bc &>/dev/null; then
		log_info "bc is already installed"
		return 2
	fi
	log_info "Installing bc..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_bc_pkg || return 1
	log_success "bc installed"
	return 0
}

uninstall_bc() {
	if ! command -v bc &>/dev/null; then
		log_info "bc is not installed"
		return 2
	fi
	log_info "Uninstalling bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_bc_pkg || return 1
	log_success "bc uninstalled"
	return 0
}

update_bc() {
	log_info "Updating bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_bc_pkg || return 1
	log_success "bc updated"
	return 0
}

reinstall_bc() {
	uninstall_bc
	install_bc
}
