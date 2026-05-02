#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_mariadb() {
	if dpkg -s mariadb 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install mariadb -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_mariadb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MariaDB"
		return 1
	fi
}

update_mariadb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB updated"
		return 0
	else
		log_error "Failed to update MariaDB"
		return 1
	fi
}