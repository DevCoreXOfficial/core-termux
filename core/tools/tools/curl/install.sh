#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_curl() {
	if command -v curl &>/dev/null; then
		log_success "Curl is already installed"
		return 0
	fi
	log_info "Installing Curl..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install curl -y &>>"$LOG_FILE"; then
		log_success "Curl installed"
		return 0
	else
		log_error "Failed to install Curl"
		return 1
	fi
}

uninstall_curl() {
	log_info "Uninstalling Curl..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall curl -y &>>"$LOG_FILE"; then
		log_success "Curl uninstalled"
		return 0
	else
		log_error "Failed to uninstall Curl"
		return 1
	fi
}

update_curl() {
	log_info "Updating Curl..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade curl -y &>>"$LOG_FILE"; then
		log_success "Curl updated"
		return 0
	else
		log_error "Failed to update Curl"
		return 1
	fi
}

reinstall_curl() {
	uninstall_curl
	install_curl
}
