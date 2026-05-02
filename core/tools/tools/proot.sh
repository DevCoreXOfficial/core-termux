#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_proot() {
	if dpkg -s proot 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install proot -y &>>"$LOG_FILE"; then
		log_success "Proot installed"
		return 0
	else
		log_error "Failed to install Proot"
		return 1
	fi
}

uninstall_proot() {
	log_info "Uninstalling Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall proot -y &>>"$LOG_FILE"; then
		log_success "Proot uninstalled"
		return 0
	else
		log_error "Failed to uninstall Proot"
		return 1
	fi
}

update_proot() {
	log_info "Updating Proot..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade proot -y &>>"$LOG_FILE"; then
		log_success "Proot updated"
		return 0
	else
		log_error "Failed to update Proot"
		return 1
	fi
}