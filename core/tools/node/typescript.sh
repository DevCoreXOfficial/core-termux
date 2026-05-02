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

install_typescript() {
	if command -v tsc &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript installed"
		return 0
	else
		log_error "Failed to install TypeScript"
		return 1
	fi
}

uninstall_typescript() {
	log_info "Uninstalling TypeScript..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript uninstalled"
		return 0
	else
		log_error "Failed to uninstall TypeScript"
		return 1
	fi
}

update_typescript() {
	log_info "Updating TypeScript..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript updated"
		return 0
	else
		log_error "Failed to update TypeScript"
		return 1
	fi
}