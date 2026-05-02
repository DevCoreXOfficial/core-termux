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

install_qwen_code() {
	if command -v qwen &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Qwen Code"
		return 1
	fi
}

uninstall_qwen_code() {
	log_info "Uninstalling Qwen Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		log_success "Qwen Code uninstalled"
		return 0
	else
		log_error "Failed to uninstall Qwen Code"
		return 1
	fi
}

update_qwen_code() {
	log_info "Updating Qwen Code..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		log_success "Qwen Code updated"
		return 0
	else
		log_error "Failed to update Qwen Code"
		return 1
	fi
}