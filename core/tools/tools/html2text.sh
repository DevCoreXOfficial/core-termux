#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_html2text() {
	if dpkg -s html2text 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install html2text -y &>>"$LOG_FILE"; then
		log_success "html2text installed"
		return 0
	else
		log_error "Failed to install html2text"
		return 1
	fi
}

uninstall_html2text() {
	log_info "Uninstalling html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall html2text -y &>>"$LOG_FILE"; then
		log_success "html2text uninstalled"
		return 0
	else
		log_error "Failed to uninstall html2text"
		return 1
	fi
}

update_html2text() {
	log_info "Updating html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade html2text -y &>>"$LOG_FILE"; then
		log_success "html2text updated"
		return 0
	else
		log_error "Failed to update html2text"
		return 1
	fi
}