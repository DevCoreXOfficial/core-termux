#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_cloudflared() {
	if dpkg -s cloudflared 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared installed"
		return 0
	else
		log_error "Failed to install Cloudflared"
		return 1
	fi
}

uninstall_cloudflared() {
	log_info "Uninstalling Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared uninstalled"
		return 0
	else
		log_error "Failed to uninstall Cloudflared"
		return 1
	fi
}

update_cloudflared() {
	log_info "Updating Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade cloudflared -y &>>"$LOG_FILE"; then
		log_success "Cloudflared updated"
		return 0
	else
		log_error "Failed to update Cloudflared"
		return 1
	fi
}