#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

install_jq() {
	if command -v jq &>/dev/null; then
		log_info "jq is already installed"
		return 2
	fi
	log_info "Installing jq..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install jq -y &>>"$LOG_FILE"; then
		log_success "jq installed"
		return 0
	else
		log_error "Failed to install jq"
		return 1
	fi
}

uninstall_jq() {
	if ! command -v jq &>/dev/null; then
		log_info "jq is not installed"
		return 2
	fi
	log_info "Uninstalling jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall jq -y &>>"$LOG_FILE"; then
		log_success "jq uninstalled"
		return 0
	else
		log_error "Failed to uninstall jq"
		return 1
	fi
}

update_jq() {
	log_info "Updating jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade jq -y &>>"$LOG_FILE"; then
		log_success "jq updated"
		return 0
	else
		log_error "Failed to update jq"
		return 1
	fi
}

reinstall_jq() {
	uninstall_jq
	install_jq
}
