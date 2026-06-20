#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_sqlite() {
	if command -v sqlite &>/dev/null; then
		log_info "SQLite is already installed"
		return 2
	fi
	log_info "Installing SQLite..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite installed"
		return 0
	else
		return 1
	fi
}

uninstall_sqlite() {
	if ! command -v sqlite3 &>/dev/null; then
		log_info "SQLite is not installed"
		return 2
	fi
	log_info "Uninstalling SQLite..."
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
	log_info "Updating SQLite..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite updated"
		return 0
	else
		log_error "Failed to update SQLite"
		return 1
	fi
}

reinstall_sqlite() {
	uninstall_sqlite
	install_sqlite
}