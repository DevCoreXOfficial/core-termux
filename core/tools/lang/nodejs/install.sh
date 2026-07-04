#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_npmjs_pkg() {
	loading "Installing Node.js LTS" _install_npmjs_pkg_impl
}

_install_npmjs_pkg_impl() {
	if ! yes | pkg install nodejs-lts &>>"$LOG_FILE"; then
		log_error "Failed to install Node.js LTS"
		return 1
	fi
	return 0
}

_enable_corepack() {
	loading "Enabling Corepack (pnpm, yarn)" _enable_corepack_impl
}

_enable_corepack_impl() {
	if ! corepack enable &>>"$LOG_FILE"; then
		log_error "Failed to enable Corepack"
		return 1
	fi
	return 0
}

install_npmjs() {
	if command -v node &>/dev/null; then
		log_info "Node.js LTS is already installed"
		return 2
	fi
	log_info "Installing Node.js LTS..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_npmjs_pkg || return 1
	_enable_corepack || return 1
	log_success "Node.js LTS installed (pnpm, yarn available via corepack)"
	return 0
}

_uninstall_npmjs_pkg() {
	loading "Uninstalling Node.js LTS" _uninstall_npmjs_pkg_impl
}

_uninstall_npmjs_pkg_impl() {
	if ! pkg uninstall nodejs-lts -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Node.js LTS"
		return 1
	fi
	return 0
}

uninstall_npmjs() {
	if ! command -v node &>/dev/null; then
		log_info "Node.js LTS is not installed"
		return 2
	fi
	log_info "Uninstalling Node.js LTS..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_npmjs_pkg || return 1
	log_success "Node.js LTS uninstalled"
	return 0
}

_update_npmjs_pkg() {
	loading "Updating Node.js LTS" _update_npmjs_pkg_impl
}

_update_npmjs_pkg_impl() {
	if ! pkg upgrade nodejs-lts -y &>>"$LOG_FILE"; then
		log_error "Failed to update Node.js LTS"
		return 1
	fi
	return 0
}

update_npmjs() {
	log_info "Updating Node.js LTS..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_update_npmjs_pkg || return 1
	log_success "Node.js LTS updated"
	return 0
}

reinstall_npmjs() {
	uninstall_npmjs
	install_npmjs
}
