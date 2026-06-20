#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_udocker() {
	if command -v udocker &>/dev/null; then
		log_info "Udocker is already installed"
		return 2
	fi
	log_info "Installing Udocker..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install udocker -y &>>"$LOG_FILE"; then
		log_success "Udocker installed"
		return 0
	else
		log_error "Failed to install Udocker"
		return 1
	fi
}

uninstall_udocker() {
	if ! command -v udocker &>/dev/null; then
		log_info "Udocker is not installed"
		return 2
	fi
	log_info "Uninstalling Udocker..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall udocker -y &>>"$LOG_FILE"; then
		log_success "Udocker uninstalled"
		return 0
	else
		log_error "Failed to uninstall Udocker"
		return 1
	fi
}

update_udocker() {
	log_info "Updating Udocker..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade udocker -y &>>"$LOG_FILE"; then
		log_success "Udocker updated"
		return 0
	else
		log_error "Failed to update Udocker"
		return 1
	fi
}

reinstall_udocker() {
	uninstall_udocker
	install_udocker
}
