#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_lsd() {
	if dpkg -s lsd 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install lsd -y &>>"$LOG_FILE"; then
		log_success "LSD installed"
		return 0
	else
		log_error "Failed to install LSD"
		return 1
	fi
}

uninstall_lsd() {
	log_info "Uninstalling LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall lsd -y &>>"$LOG_FILE"; then
		log_success "LSD uninstalled"
		return 0
	else
		log_error "Failed to uninstall LSD"
		return 1
	fi
}

update_lsd() {
	log_info "Updating LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade lsd -y &>>"$LOG_FILE"; then
		log_success "LSD updated"
		return 0
	else
		log_error "Failed to update LSD"
		return 1
	fi
}