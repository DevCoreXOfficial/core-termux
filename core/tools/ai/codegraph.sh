#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_ai_npm_prereqs() {
	if command -v node &>/dev/null && command -v npm &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install nodejs-lts git ripgrep clang make python sqlite -y &>>"$LOG_FILE"
}

install_codegraph() {
	if command -v codegraph &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @colbymchenry/codegraph &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install CodeGraph"
		return 1
	fi
}

uninstall_codegraph() {
	log_info "Uninstalling CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @colbymchenry/codegraph &>>"$LOG_FILE"; then
		log_success "CodeGraph uninstalled"
		return 0
	else
		log_error "Failed to uninstall CodeGraph"
		return 1
	fi
}

update_codegraph() {
	log_info "Updating CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @colbymchenry/codegraph &>>"$LOG_FILE"; then
		log_success "CodeGraph updated"
		return 0
	else
		log_error "Failed to update CodeGraph"
		return 1
	fi
}
