#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_ollama() {
	if command -v ollama &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install ollama -y &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Ollama"
		return 1
	fi
}

uninstall_ollama() {
	log_info "Uninstalling Ollama..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall ollama -y &>>"$LOG_FILE"; then
		log_success "Ollama uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ollama"
		return 1
	fi
}

update_ollama() {
	log_info "Updating Ollama..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade ollama -y &>>"$LOG_FILE"; then
		log_success "Ollama updated"
		return 0
	else
		log_error "Failed to update Ollama"
		return 1
	fi
}