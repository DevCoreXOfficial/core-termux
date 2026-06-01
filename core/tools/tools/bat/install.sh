#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_bat() {
	if command -v bat &>/dev/null; then
		log_success "Bat is already installed"
		return 0
	fi
	log_info "Installing Bat..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install bat -y &>>"$LOG_FILE"; then
		log_success "Bat installed"
		return 0
	else
		log_error "Failed to install Bat"
		return 1
	fi
}

uninstall_bat() {
	log_info "Uninstalling Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall bat -y &>>"$LOG_FILE"; then
		log_success "Bat uninstalled"
		return 0
	else
		log_error "Failed to uninstall Bat"
		return 1
	fi
}

update_bat() {
	log_info "Updating Bat..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade bat -y &>>"$LOG_FILE"; then
		log_success "Bat updated"
		return 0
	else
		log_error "Failed to update Bat"
		return 1
	fi
}