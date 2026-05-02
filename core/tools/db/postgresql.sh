#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_postgresql() {
	if dpkg -s postgresql 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install postgresql -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_postgresql() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL uninstalled"
		return 0
	else
		log_error "Failed to uninstall PostgreSQL"
		return 1
	fi
}

update_postgresql() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL updated"
		return 0
	else
		log_error "Failed to update PostgreSQL"
		return 1
	fi
}