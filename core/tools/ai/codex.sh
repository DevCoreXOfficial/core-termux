#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_codex() {
	if command -v codex &>/dev/null; then
		return 0
	fi

	pkg install tur-repo -y &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install codex -y &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Codex"
		return 1
	fi
}

uninstall_codex() {
	log_info "Uninstalling Codex..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall codex -y &>>"$LOG_FILE"; then
		log_success "Codex uninstalled"
		return 0
	else
		log_error "Failed to uninstall Codex"
		return 1
	fi
}

update_codex() {
	log_info "Updating Codex..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade codex -y &>>"$LOG_FILE"; then
		log_success "Codex updated"
		return 0
	else
		log_error "Failed to update Codex"
		return 1
	fi
}