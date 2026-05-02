#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_python() {
	if dpkg -s python 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install python -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_python() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall python -y &>>"$LOG_FILE"; then
		log_success "Python uninstalled"
		return 0
	else
		log_error "Failed to uninstall Python"
		return 1
	fi
}

update_python() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade python -y &>>"$LOG_FILE"; then
		log_success "Python updated"
		return 0
	else
		log_error "Failed to update Python"
		return 1
	fi
}