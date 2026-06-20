#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_golang() {
	if command -v go &>/dev/null; then
		log_info "Go (Golang) is already installed"
		return 2
	fi
	log_info "Installing Go (Golang)..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install golang -y &>>"$LOG_FILE"; then
		log_success "Go (Golang) installed"
		return 0
	else
		return 1
	fi
}

uninstall_golang() {
	if ! command -v go &>/dev/null; then
		log_info "Go (Golang) is not installed"
		return 2
	fi
	log_info "Uninstalling Go (Golang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall golang -y &>>"$LOG_FILE"; then
		log_success "Go (golang) uninstalled"
		return 0
	else
		log_error "Failed to uninstall Go (golang)"
		return 1
	fi
}

update_golang() {
	log_info "Updating Go (Golang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade golang -y &>>"$LOG_FILE"; then
		log_success "Go (golang) updated"
		return 0
	else
		log_error "Failed to update Go (golang)"
		return 1
	fi
}

reinstall_golang() {
	uninstall_golang
	install_golang
}