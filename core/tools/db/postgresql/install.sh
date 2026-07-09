#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_postgresql_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install postgresql &>>"$LOG_FILE"; then
		log_success "PostgreSQL installed"
		return 0
	else
		return 1
	fi
}

install_postgresql() {
	if command -v postgres &>/dev/null; then
		log_info "PostgreSQL is already installed"
		return 2
	fi
	log_info "Installing PostgreSQL..."
	loading "Installing PostgreSQL" _install_postgresql_impl
}

_uninstall_postgresql_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL uninstalled"
		return 0
	else
		log_error "Failed to uninstall PostgreSQL"
		return 1
	fi
}

uninstall_postgresql() {
	if ! command -v postgres &>/dev/null; then
		log_info "PostgreSQL is not installed"
		return 2
	fi
	log_info "Uninstalling PostgreSQL..."
	loading "Uninstalling PostgreSQL" _uninstall_postgresql_impl
}

_update_postgresql_impl() {
	loading "Updating PostgreSQL" _do_postgresql_update
}

_do_postgresql_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade postgresql -y &>>"$LOG_FILE"
}

update_postgresql() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "PostgreSQL" "$(_get_installed_pkg_version postgresql "PostgreSQL")" "$(_get_remote_pkg_version postgresql)" _update_postgresql_impl
}

reinstall_postgresql() {
	uninstall_postgresql
	install_postgresql
}
