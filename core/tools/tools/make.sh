#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_make() {
	if dpkg -s make 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install make -y &>>"$LOG_FILE"; then
		log_success "Make installed"
		return 0
	else
		log_error "Failed to install Make"
		return 1
	fi
}

uninstall_make() {
	log_info "Uninstalling Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall make -y &>>"$LOG_FILE"; then
		log_success "Make uninstalled"
		return 0
	else
		log_error "Failed to uninstall Make"
		return 1
	fi
}

update_make() {
	log_info "Updating Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade make -y &>>"$LOG_FILE"; then
		log_success "Make updated"
		return 0
	else
		log_error "Failed to update Make"
		return 1
	fi
}