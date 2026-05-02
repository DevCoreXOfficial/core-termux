#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_wget() {
	if dpkg -s wget 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install wget -y &>>"$LOG_FILE"; then
		log_success "Wget installed"
		return 0
	else
		log_error "Failed to install Wget"
		return 1
	fi
}

uninstall_wget() {
	log_info "Uninstalling Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall wget -y &>>"$LOG_FILE"; then
		log_success "Wget uninstalled"
		return 0
	else
		log_error "Failed to uninstall Wget"
		return 1
	fi
}

update_wget() {
	log_info "Updating Wget..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade wget -y &>>"$LOG_FILE"; then
		log_success "Wget updated"
		return 0
	else
		log_error "Failed to update Wget"
		return 1
	fi
}