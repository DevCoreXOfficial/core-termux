#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_ai_npm_prereqs() {
	if command -v node &>/dev/null && command -v npm &>/dev/null; then
		log_success "Node.js and npm are already installed"
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install nodejs-lts git ripgrep -y &>>"$LOG_FILE"; then
		log_success "Node.js and npm prerequisites installed successfully"
		return 0
	else
		log_error "Failed to install Node.js and npm prerequisites"
		return 1
	fi
}

install_minimax_cli() {
	if command -v mmx &>/dev/null; then
		log_success "MiniMax CLI is already installed"
		return 0
	fi

	log_info "Installing MiniMax CLI..."

	if _install_ai_npm_prereqs; then
		mkdir -p "$(dirname "$LOG_FILE")"

		if npm install -g mmx-cli &>>"$LOG_FILE"; then
			log_success "MiniMax CLI installed successfully"
			return 0
		else
			log_error "Failed to install MiniMax CLI"
			return 1
		fi
	else
		log_error "Failed to install prerequisites for MiniMax CLI"
		return 1
	fi
}

uninstall_minimax_cli() {
	if ! command -v mmx &>/dev/null; then
		log_success "MiniMax CLI is not installed"
		return 0
	fi

	log_info "Uninstalling MiniMax CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g mmx-cli &>>"$LOG_FILE"; then
		log_success "MiniMax CLI uninstalled successfully"
		return 0
	else
		log_error "Failed to uninstall MiniMax CLI"
		return 1
	fi
}

update_minimax_cli() {
	if ! command -v mmx &>/dev/null; then
		log_error "MiniMax CLI is not installed"
		return 1
	fi

	log_info "Updating MiniMax CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g mmx-cli &>>"$LOG_FILE"; then
		log_success "MiniMax CLI updated successfully"
		return 0
	else
		log_error "Failed to update MiniMax CLI"
		return 1
	fi
}
