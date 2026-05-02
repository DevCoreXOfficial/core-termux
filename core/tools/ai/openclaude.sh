#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_ai_npm_prereqs() {
	if command -v node &>/dev/null && command -v npm &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install nodejs-lts git ripgrep -y &>>"$LOG_FILE"
}

install_openclaude() {
	if command -v openclaude &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install OpenClaude"
		return 1
	fi
}

uninstall_openclaude() {
	log_info "Uninstalling OpenClaude..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		log_success "OpenClaude uninstalled"
		return 0
	else
		log_error "Failed to uninstall OpenClaude"
		return 1
	fi
}

update_openclaude() {
	log_info "Updating OpenClaude..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		log_success "OpenClaude updated"
		return 0
	else
		log_error "Failed to update OpenClaude"
		return 1
	fi
}