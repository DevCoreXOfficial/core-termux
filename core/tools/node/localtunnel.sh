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

install_localtunnel() {
	if command -v lt &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel installed"
		log_info "Applying localtunnel fix for Android..."
		fix_localtunnel_openurl &>>"$LOG_FILE"
		return 0
	else
		log_error "Failed to install Localtunnel"
		return 1
	fi
}

uninstall_localtunnel() {
	log_info "Uninstalling Localtunnel..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel uninstalled"
		return 0
	else
		log_error "Failed to uninstall Localtunnel"
		return 1
	fi
}

update_localtunnel() {
	log_info "Updating Localtunnel..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel updated"
		return 0
	else
		log_error "Failed to update Localtunnel"
		return 1
	fi
}