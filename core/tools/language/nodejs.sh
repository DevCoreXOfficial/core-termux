#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_nodejs() {
	if dpkg -s nodejs-lts 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install nodejs-lts -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_nodejs() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS uninstalled"
		return 0
	else
		log_error "Failed to uninstall Node.js LTS"
		return 1
	fi
}

update_nodejs() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS updated"
		return 0
	else
		log_error "Failed to update Node.js LTS"
		return 1
	fi
}