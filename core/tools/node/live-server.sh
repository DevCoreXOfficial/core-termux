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

install_live_server() {
	if command -v live-server &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server installed"
		return 0
	else
		log_error "Failed to install Live Server"
		return 1
	fi
}

uninstall_live_server() {
	log_info "Uninstalling Live Server..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server uninstalled"
		return 0
	else
		log_error "Failed to uninstall Live Server"
		return 1
	fi
}

update_live_server() {
	log_info "Updating Live Server..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server updated"
		return 0
	else
		log_error "Failed to update Live Server"
		return 1
	fi
}