#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_lang.log"

install_npmjs() {
	if command -v node &>/dev/null; then
		log_info "Node.js LTS is already installed"
		return 2
	fi
	log_info "Installing Node.js LTS..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS installed"
		return 0
	else
		return 1
	fi
}

uninstall_npmjs() {
	if ! command -v node &>/dev/null; then
		log_info "Node.js LTS is not installed"
		return 2
	fi
	log_info "Uninstalling Node.js LTS..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS uninstalled"
		return 0
	else
		log_error "Failed to uninstall Node.js LTS"
		return 1
	fi
}

update_npmjs() {
	log_info "Updating Node.js LTS..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS updated"
		return 0
	else
		log_error "Failed to update Node.js LTS"
		return 1
	fi
}

reinstall_npmjs() {
	uninstall_npmjs
	install_npmjs
}