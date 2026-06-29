#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_mariadb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install mariadb &>>"$LOG_FILE"; then
		log_success "MariaDB installed"
		return 0
	else
		return 1
	fi
}

install_mariadb() {
	if command -v mariadbd &>/dev/null; then
		log_info "MariaDB is already installed"
		return 2
	fi
	log_info "Installing MariaDB..."
	loading "Installing MariaDB" _install_mariadb_impl
}

_uninstall_mariadb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MariaDB"
		return 1
	fi
}

uninstall_mariadb() {
	if ! command -v mariadbd &>/dev/null; then
		log_info "MariaDB is not installed"
		return 2
	fi
	log_info "Uninstalling MariaDB..."
	loading "Uninstalling MariaDB" _uninstall_mariadb_impl
}

_update_mariadb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB updated"
		return 0
	else
		log_error "Failed to update MariaDB"
		return 1
	fi
}

update_mariadb() {
	log_info "Updating MariaDB..."
	loading "Updating MariaDB" _update_mariadb_impl
}

reinstall_mariadb() {
	uninstall_mariadb
	install_mariadb
}
