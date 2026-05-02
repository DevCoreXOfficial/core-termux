#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_gh() {
	if dpkg -s gh 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI installed"
		return 0
	else
		log_error "Failed to install GitHub CLI"
		return 1
	fi
}

uninstall_gh() {
	log_info "Uninstalling GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall GitHub CLI"
		return 1
	fi
}

update_gh() {
	log_info "Updating GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade gh -y &>>"$LOG_FILE"; then
		log_success "GitHub CLI updated"
		return 0
	else
		log_error "Failed to update GitHub CLI"
		return 1
	fi
}