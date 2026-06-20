#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_mariadb() {
	if command -v mariadbd &>/dev/null; then
		log_info "MariaDB is already installed"
		return 0
	fi
	log_info "Installing MariaDB..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB installed"
		return 0
	else
		return 1
	fi
}

uninstall_mariadb() {
	log_info "Uninstalling MariaDB..."
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
	log_info "Updating MariaDB..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB updated"
		return 0
	else
		log_error "Failed to update MariaDB"
		return 1
	fi
}

reinstall_mariadb() {
	uninstall_mariadb
	install_mariadb
}