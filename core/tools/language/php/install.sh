#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_php() {
	if dpkg -s php 2>/dev/null | grep -q "Status: install ok installed"; then
		log_success "PHP is already installed"
		return 0
	fi
	log_info "Installing PHP..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install php -y &>>"$LOG_FILE"; then
		log_success "PHP installed"
		return 0
	else
		return 1
	fi
}

uninstall_php() {
	log_info "Uninstalling PHP..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall php -y &>>"$LOG_FILE"; then
		log_success "PHP uninstalled"
		return 0
	else
		log_error "Failed to uninstall PHP"
		return 1
	fi
}

update_php() {
	log_info "Updating PHP..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade php -y &>>"$LOG_FILE"; then
		log_success "PHP updated"
		return 0
	else
		log_error "Failed to update PHP"
		return 1
	fi
}