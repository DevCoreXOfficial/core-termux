#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

install_php() {
	if command -v php &>/dev/null; then
		log_info "PHP is already installed"
		return 2
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
	if ! command -v php &>/dev/null; then
		log_info "PHP is not installed"
		return 2
	fi
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

reinstall_php() {
	uninstall_php
	install_php
}