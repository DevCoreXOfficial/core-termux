#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_fzf() {
	if dpkg -s fzf 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf installed"
		return 0
	else
		log_error "Failed to install Fzf"
		return 1
	fi
}

uninstall_fzf() {
	log_info "Uninstalling Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf uninstalled"
		return 0
	else
		log_error "Failed to uninstall Fzf"
		return 1
	fi
}

update_fzf() {
	log_info "Updating Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade fzf -y &>>"$LOG_FILE"; then
		log_success "Fzf updated"
		return 0
	else
		log_error "Failed to update Fzf"
		return 1
	fi
}