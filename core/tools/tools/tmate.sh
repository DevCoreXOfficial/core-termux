#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_tmate() {
	if dpkg -s tmate 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate installed"
		return 0
	else
		log_error "Failed to install Tmate"
		return 1
	fi
}

uninstall_tmate() {
	log_info "Uninstalling Tmate..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate uninstalled"
		return 0
	else
		log_error "Failed to uninstall Tmate"
		return 1
	fi
}

update_tmate() {
	log_info "Updating Tmate..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade tmate -y &>>"$LOG_FILE"; then
		log_success "Tmate updated"
		return 0
	else
		log_error "Failed to update Tmate"
		return 1
	fi
}