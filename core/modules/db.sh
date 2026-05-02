#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_db.log"

install_db() {
	separator
	box "Installing Databases"
	separator
	echo

	log_info "Installing databases..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing databases" _install_db_tools_wrapper; then
		log_success "Databases installed successfully"
		separator
		echo
		list_item "PostgreSQL"
		list_item "MariaDB (MySQL)"
		list_item "SQLite"
		list_item "MongoDB"
		echo
	else
		log_error "Failed to install databases"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

_install_db_tools_wrapper() {
	import "@/tools/db/all"
	install_all_db_tools
}

uninstall_db() {
	separator
	box "Uninstalling Databases"
	separator
	echo

	log_info "Uninstalling databases..."

	if loading "Uninstalling databases" _uninstall_db_tools_wrapper; then
		log_success "Databases uninstalled"
	else
		log_error "Failed to uninstall databases"
		return 1
	fi
}

_uninstall_db_tools_wrapper() {
	import "@/tools/db/all"
	uninstall_all_db_tools
}

update_db() {
	separator
	box "Updating Databases"
	separator
	echo

	log_info "Updating databases..."

	if loading "Updating databases" _update_db_tools_wrapper; then
		log_success "Databases updated"
	else
		log_error "Failed to update databases"
		return 1
	fi
}

_update_db_tools_wrapper() {
	import "@/tools/db/all"
	update_all_db_tools
}