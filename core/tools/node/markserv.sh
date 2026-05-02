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

install_markserv() {
	if command -v markserv &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv installed"
		return 0
	else
		log_error "Failed to install Markserv"
		return 1
	fi
}

uninstall_markserv() {
	log_info "Uninstalling Markserv..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv uninstalled"
		return 0
	else
		log_error "Failed to uninstall Markserv"
		return 1
	fi
}

update_markserv() {
	log_info "Updating Markserv..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv updated"
		return 0
	else
		log_error "Failed to update Markserv"
		return 1
	fi
}