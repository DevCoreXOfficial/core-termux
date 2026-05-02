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

install_openclaw() {
	if command -v openclaw &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	npm install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g openclaw@latest &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install OpenClaw"
		return 1
	fi
}

uninstall_openclaw() {
	log_info "Uninstalling OpenClaw..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
		log_success "OpenClaw uninstalled"
		return 0
	else
		log_error "Failed to uninstall OpenClaw"
		return 1
	fi
}

update_openclaw() {
	log_info "Updating OpenClaw..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
		log_success "OpenClaw updated"
		return 0
	else
		log_error "Failed to update OpenClaw"
		return 1
	fi
}