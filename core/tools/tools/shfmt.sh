#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_shfmt() {
	if dpkg -s shfmt 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt installed"
		return 0
	else
		log_error "Failed to install Shfmt"
		return 1
	fi
}

uninstall_shfmt() {
	log_info "Uninstalling Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt uninstalled"
		return 0
	else
		log_error "Failed to uninstall Shfmt"
		return 1
	fi
}

update_shfmt() {
	log_info "Updating Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade shfmt -y &>>"$LOG_FILE"; then
		log_success "Shfmt updated"
		return 0
	else
		log_error "Failed to update Shfmt"
		return 1
	fi
}