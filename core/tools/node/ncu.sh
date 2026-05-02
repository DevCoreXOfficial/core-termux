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

install_ncu() {
	if command -v ncu &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates installed"
		return 0
	else
		log_error "Failed to install NPM Check Updates"
		return 1
	fi
}

uninstall_ncu() {
	log_info "Uninstalling NPM Check Updates..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates uninstalled"
		return 0
	else
		log_error "Failed to uninstall NPM Check Updates"
		return 1
	fi
}

update_ncu() {
	log_info "Updating NPM Check Updates..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates updated"
		return 0
	else
		log_error "Failed to update NPM Check Updates"
		return 1
	fi
}