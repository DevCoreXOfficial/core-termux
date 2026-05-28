#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_rust() {
	if dpkg -s rust 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi
	log_info "Installing Rust..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install rust -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_rust() {
	log_info "Uninstalling Rust..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall rust -y &>>"$LOG_FILE"; then
		log_success "Rust uninstalled"
		return 0
	else
		log_error "Failed to uninstall Rust"
		return 1
	fi
}

update_rust() {
	log_info "Updating Rust..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade rust -y &>>"$LOG_FILE"; then
		log_success "Rust updated"
		return 0
	else
		log_error "Failed to update Rust"
		return 1
	fi
}