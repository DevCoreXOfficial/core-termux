#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_bc() {
	if dpkg -s bc 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install bc -y &>>"$LOG_FILE"; then
		log_success "bc installed"
		return 0
	else
		log_error "Failed to install bc"
		return 1
	fi
}

uninstall_bc() {
	log_info "Uninstalling bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall bc -y &>>"$LOG_FILE"; then
		log_success "bc uninstalled"
		return 0
	else
		log_error "Failed to uninstall bc"
		return 1
	fi
}

update_bc() {
	log_info "Updating bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade bc -y &>>"$LOG_FILE"; then
		log_success "bc updated"
		return 0
	else
		log_error "Failed to update bc"
		return 1
	fi
}