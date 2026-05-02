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

install_gemini_cli() {
	if command -v gemini &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @google/gemini-cli &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Gemini CLI"
		return 1
	fi
}

uninstall_gemini_cli() {
	log_info "Uninstalling Gemini CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @google/gemini-cli &>>"$LOG_FILE"; then
		log_success "Gemini CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall Gemini CLI"
		return 1
	fi
}

update_gemini_cli() {
	log_info "Updating Gemini CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @google/gemini-cli &>>"$LOG_FILE"; then
		log_success "Gemini CLI updated"
		return 0
	else
		log_error "Failed to update Gemini CLI"
		return 1
	fi
}