#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_ncurses() {
	if command -v tput &>/dev/null; then
		log_info "Ncurses Utils is already installed"
		return 0
	fi
	log_info "Installing Ncurses Utils..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils installed"
		return 0
	else
		log_error "Failed to install Ncurses Utils"
		return 1
	fi
}

uninstall_ncurses() {
	log_info "Uninstalling Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ncurses Utils"
		return 1
	fi
}

update_ncurses() {
	log_info "Updating Ncurses Utils..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade ncurses-utils -y &>>"$LOG_FILE"; then
		log_success "Ncurses Utils updated"
		return 0
	else
		log_error "Failed to update Ncurses Utils"
		return 1
	fi
}

reinstall_ncurses() {
	uninstall_ncurses
	install_ncurses
}
