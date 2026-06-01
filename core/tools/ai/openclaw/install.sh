#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openclaw_install_ai_npm_prereqs() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["git"]="git"
		["ripgrep"]="rg"
	)

	local pkg_name bin_name
	for pkg_name in "${!DEPS[@]}"; do
		bin_name="${DEPS[$pkg_name]}"
		if ! command -v "$bin_name" &>/dev/null; then
			if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
				log_error "Failed to install $pkg_name"
				return 1
			fi
		fi
	done

	log_success "Node.js and npm prerequisites installed"
	return 0
}

install_openclaw() {
	if command -v openclaw &>/dev/null; then
		log_success "OpenClaw is already installed"
		return 0
	fi
	log_info "Installing OpenClaw..."

	_openclaw_install_ai_npm_prereqs

	npm install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g openclaw@latest &>>"$LOG_FILE"; then
		log_success "OpenClaw installed"
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