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

install_nestjs() {
	if command -v nest &>/dev/null; then
		return 0
	fi

	_install_node_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI installed"
		return 0
	else
		log_error "Failed to install NestJS CLI"
		return 1
	fi
}

uninstall_nestjs() {
	log_info "Uninstalling NestJS CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall NestJS CLI"
		return 1
	fi
}

update_nestjs() {
	log_info "Updating NestJS CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI updated"
		return 0
	else
		log_error "Failed to update NestJS CLI"
		return 1
	fi
}