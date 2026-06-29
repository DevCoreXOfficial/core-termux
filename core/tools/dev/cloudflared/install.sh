#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_cloudflared_pkg() {
	loading "Installing Cloudflared" _install_cloudflared_pkg_impl
}

_install_cloudflared_pkg_impl() {
	if ! yes | pkg install cloudflared &>>"$LOG_FILE"; then
		log_error "Failed to install Cloudflared"
		return 1
	fi
	return 0
}

_uninstall_cloudflared_pkg() {
	loading "Uninstalling Cloudflared" _uninstall_cloudflared_pkg_impl
}

_uninstall_cloudflared_pkg_impl() {
	if ! pkg uninstall cloudflared -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Cloudflared"
		return 1
	fi
	return 0
}

_update_cloudflared_pkg() {
	loading "Updating Cloudflared" _update_cloudflared_pkg_impl
}

_update_cloudflared_pkg_impl() {
	if ! pkg upgrade cloudflared -y &>>"$LOG_FILE"; then
		log_error "Failed to update Cloudflared"
		return 1
	fi
	return 0
}

install_cloudflared() {
	if command -v cloudflared &>/dev/null; then
		log_info "Cloudflared is already installed"
		return 2
	fi
	log_info "Installing Cloudflared..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_cloudflared_pkg || return 1
	log_success "Cloudflared installed"
	return 0
}

uninstall_cloudflared() {
	if ! command -v cloudflared &>/dev/null; then
		log_info "Cloudflared is not installed"
		return 2
	fi
	log_info "Uninstalling Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_cloudflared_pkg || return 1
	log_success "Cloudflared uninstalled"
	return 0
}

update_cloudflared() {
	log_info "Updating Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_cloudflared_pkg || return 1
	log_success "Cloudflared updated"
	return 0
}

reinstall_cloudflared() {
	uninstall_cloudflared
	install_cloudflared
}
