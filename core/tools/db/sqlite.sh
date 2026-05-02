#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_sqlite() {
	if dpkg -s sqlite 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install sqlite -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_sqlite() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite uninstalled"
		return 0
	else
		log_error "Failed to uninstall SQLite"
		return 1
	fi
}

update_sqlite() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite updated"
		return 0
	else
		log_error "Failed to update SQLite"
		return 1
	fi
}