#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_jq() {
	if dpkg -s jq 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install jq -y &>>"$LOG_FILE"; then
		log_success "jq installed"
		return 0
	else
		log_error "Failed to install jq"
		return 1
	fi
}

uninstall_jq() {
	log_info "Uninstalling jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall jq -y &>>"$LOG_FILE"; then
		log_success "jq uninstalled"
		return 0
	else
		log_error "Failed to uninstall jq"
		return 1
	fi
}

update_jq() {
	log_info "Updating jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade jq -y &>>"$LOG_FILE"; then
		log_success "jq updated"
		return 0
	else
		log_error "Failed to update jq"
		return 1
	fi
}