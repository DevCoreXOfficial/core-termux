#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_golang_pkg() {
	loading "Installing Go (Golang)" _install_golang_pkg_impl
}

_install_golang_pkg_impl() {
	if ! yes | pkg install golang &>>"$LOG_FILE"; then
		log_error "Failed to install Go (Golang)"
		return 1
	fi
	return 0
}

install_golang() {
	if command -v go &>/dev/null; then
		log_info "Go (Golang) is already installed"
		return 2
	fi
	log_info "Installing Go (Golang)..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_golang_pkg || return 1
	log_success "Go (Golang) installed"
	return 0
}

_uninstall_golang_pkg() {
	loading "Uninstalling Go (Golang)" _uninstall_golang_pkg_impl
}

_uninstall_golang_pkg_impl() {
	if ! pkg uninstall golang -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Go (golang)"
		return 1
	fi
	return 0
}

uninstall_golang() {
	if ! command -v go &>/dev/null; then
		log_info "Go (Golang) is not installed"
		return 2
	fi
	log_info "Uninstalling Go (Golang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_golang_pkg || return 1
	log_success "Go (golang) uninstalled"
	return 0
}

_update_golang_pkg() {
	loading "Updating Go (Golang)" _update_golang_pkg_impl
}

_update_golang_pkg_impl() {
	if ! pkg upgrade golang -y &>>"$LOG_FILE"; then
		log_error "Failed to update Go (golang)"
		return 1
	fi
	return 0
}

update_golang() {
	log_info "Updating Go (Golang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_update_golang_pkg || return 1
	log_success "Go (golang) updated"
	return 0
}

reinstall_golang() {
	uninstall_golang
	install_golang
}
