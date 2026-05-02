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

install_ngrok() {
	if command -v ngrok &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok installed"
		return 0
	else
		log_error "Failed to install Ngrok"
		return 1
	fi
}

uninstall_ngrok() {
	log_info "Uninstalling Ngrok..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ngrok"
		return 1
	fi
}

update_ngrok() {
	log_info "Updating Ngrok..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok updated"
		return 0
	else
		log_error "Failed to update Ngrok"
		return 1
	fi
}