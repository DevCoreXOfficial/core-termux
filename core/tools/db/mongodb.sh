#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_mongodb() {
	if dpkg -s mongodb 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install mongodb -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_mongodb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MongoDB"
		return 1
	fi
}

update_mongodb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB updated"
		return 0
	else
		log_error "Failed to update MongoDB"
		return 1
	fi
}