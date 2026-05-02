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

install_prettier() {
	if command -v prettier &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier installed"
		return 0
	else
		log_error "Failed to install Prettier"
		return 1
	fi
}

uninstall_prettier() {
	log_info "Uninstalling Prettier..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier uninstalled"
		return 0
	else
		log_error "Failed to uninstall Prettier"
		return 1
	fi
}

update_prettier() {
	log_info "Updating Prettier..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier updated"
		return 0
	else
		log_error "Failed to update Prettier"
		return 1
	fi
}