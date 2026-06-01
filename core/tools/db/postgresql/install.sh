#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_postgresql() {
	if command -v postgres &>/dev/null; then
		log_success "PostgreSQL is already installed"
		return 0
	fi
	log_info "Installing PostgreSQL..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL installed"
		return 0
	else
		return 1
	fi
}

uninstall_postgresql() {
	log_info "Uninstalling PostgreSQL..."
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
	log_info "Updating PostgreSQL..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL updated"
		return 0
	else
		log_error "Failed to update PostgreSQL"
		return 1
	fi
}