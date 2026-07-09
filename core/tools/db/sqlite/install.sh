#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_sqlite_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install sqlite &>>"$LOG_FILE"; then
		log_success "SQLite installed"
		return 0
	else
		return 1
	fi
}

install_sqlite() {
	if command -v sqlite3 &>/dev/null; then
		log_info "SQLite is already installed"
		return 2
	fi
	log_info "Installing SQLite..."
	loading "Installing SQLite" _install_sqlite_impl
}

_uninstall_sqlite_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite uninstalled"
		return 0
	else
		log_error "Failed to uninstall SQLite"
		return 1
	fi
}

uninstall_sqlite() {
	if ! command -v sqlite3 &>/dev/null; then
		log_info "SQLite is not installed"
		return 2
	fi
	log_info "Uninstalling SQLite..."
	loading "Uninstalling SQLite" _uninstall_sqlite_impl
}

_update_sqlite_impl() {
	loading "Updating SQLite" _do_sqlite_update
}

_do_sqlite_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade sqlite -y &>>"$LOG_FILE"
}

update_sqlite() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "SQLite" "$(_get_installed_pkg_version sqlite "SQLite")" "$(_get_remote_pkg_version sqlite)" _update_sqlite_impl
}

reinstall_sqlite() {
	uninstall_sqlite
	install_sqlite
}
