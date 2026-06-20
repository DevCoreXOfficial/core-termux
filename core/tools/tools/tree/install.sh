#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_tree() {
	if command -v tree &>/dev/null; then
		log_info "Tree is already installed"
		return 2
	fi
	log_info "Installing Tree..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install tree -y &>>"$LOG_FILE"; then
		log_success "Tree installed"
		return 0
	else
		log_error "Failed to install Tree"
		return 1
	fi
}

uninstall_tree() {
	if ! command -v tree &>/dev/null; then
		log_info "Tree is not installed"
		return 2
	fi
	log_info "Uninstalling Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall tree -y &>>"$LOG_FILE"; then
		log_success "Tree uninstalled"
		return 0
	else
		log_error "Failed to uninstall Tree"
		return 1
	fi
}

update_tree() {
	log_info "Updating Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade tree -y &>>"$LOG_FILE"; then
		log_success "Tree updated"
		return 0
	else
		log_error "Failed to update Tree"
		return 1
	fi
}

reinstall_tree() {
	uninstall_tree
	install_tree
}
