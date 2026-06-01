#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_automation.log"

_install_automation_prerequisites() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["python"]="python"
		["sqlite"]="sqlite"
		["build-essential"]=""
		["binutils"]=""
		["make"]="make"
		["clang"]="clang"
	)

	local pkg_name bin_name
	for pkg_name in "${!DEPS[@]}"; do
		bin_name="${DEPS[$pkg_name]}"
		if [[ -n "$bin_name" ]] && command -v "$bin_name" &>/dev/null; then
			continue
		fi
		if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
			log_error "Failed to install $pkg_name"
			return 1
		fi
	done

	log_success "Automation prerequisites installed"
	return 0
}

install_n8n() {
	if command -v n8n &>/dev/null; then
		return 0
	fi
	log_info "Installing n8n..."

	_install_automation_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g n8n &>>"$LOG_FILE"; then
		log_success "n8n installed"
		return 0
	else
		log_error "Failed to install n8n"
		return 1
	fi
}

uninstall_n8n() {
	log_info "Uninstalling n8n..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g n8n &>>"$LOG_FILE"; then
		log_success "n8n uninstalled"
		return 0
	else
		log_error "Failed to uninstall n8n"
		return 1
	fi
}

update_n8n() {
	log_info "Updating n8n..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g n8n &>>"$LOG_FILE"; then
		log_success "n8n updated"
		return 0
	else
		log_error "Failed to update n8n"
		return 1
	fi
}