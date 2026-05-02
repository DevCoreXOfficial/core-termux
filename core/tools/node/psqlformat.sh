#!/bin/bash

import "@/utils/log"
import "@/fix/localtunnel"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

_install_node_prerequisites() {
	if command -v node &>/dev/null && command -v npm &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install nodejs-lts -y &>>"$LOG_FILE"
}

install_psqlformat() {
	if command -v psqlformat &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format installed"
		return 0
	else
		log_error "Failed to install PSQL Format"
		return 1
	fi
}

uninstall_psqlformat() {
	log_info "Uninstalling PSQL Format..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format uninstalled"
		return 0
	else
		log_error "Failed to uninstall PSQL Format"
		return 1
	fi
}

update_psqlformat() {
	log_info "Updating PSQL Format..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format updated"
		return 0
	else
		log_error "Failed to update PSQL Format"
		return 1
	fi
}