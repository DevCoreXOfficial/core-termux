#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_translate() {
	if dpkg -s translate-shell 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell installed"
		return 0
	else
		log_error "Failed to install Translate Shell"
		return 1
	fi
}

uninstall_translate() {
	log_info "Uninstalling Translate Shell..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell uninstalled"
		return 0
	else
		log_error "Failed to uninstall Translate Shell"
		return 1
	fi
}

update_translate() {
	log_info "Updating Translate Shell..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade translate-shell -y &>>"$LOG_FILE"; then
		log_success "Translate Shell updated"
		return 0
	else
		log_error "Failed to update Translate Shell"
		return 1
	fi
}