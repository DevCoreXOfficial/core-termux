#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_ai_pip_prereqs() {
	if command -v python &>/dev/null && command -v pip &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install python clang make rust libffi openssl pkg-config git ripgrep -y &>>"$LOG_FILE"
	pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
}

install_mistral_vibe() {
	if command -v vibe &>/dev/null; then
		return 0
	fi

	_install_ai_pip_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"

	if pip install mistral-vibe &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Mistral Vibe"
		return 1
	fi
}

uninstall_mistral_vibe() {
	log_info "Uninstalling Mistral Vibe..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pip uninstall mistral-vibe -y &>>"$LOG_FILE"; then
		log_success "Mistral Vibe uninstalled"
		return 0
	else
		log_error "Failed to uninstall Mistral Vibe"
		return 1
	fi
}

update_mistral_vibe() {
	log_info "Updating Mistral Vibe..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pip install --upgrade mistral-vibe &>>"$LOG_FILE"; then
		log_success "Mistral Vibe updated"
		return 0
	else
		log_error "Failed to update Mistral Vibe"
		return 1
	fi
}