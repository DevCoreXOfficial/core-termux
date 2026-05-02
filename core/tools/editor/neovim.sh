#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVCHAD_REPO="https://github.com/DevCoreXOfficial/nvchad-termux.git"
NVCHAD_DIR="$HOME/.cache/core-termux/nvchad-termux"

_install_neovim_prereqs() {
	if dpkg -s neovim 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install neovim -y &>>"$LOG_FILE"
}

install_neovim() {
	if dpkg -s neovim 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	_install_neovim_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install neovim -y &>>"$LOG_FILE"; then
		log_success "Neovim installed"
		return 0
	else
		log_error "Failed to install Neovim"
		return 1
	fi
}

uninstall_neovim() {
	log_info "Uninstalling Neovim..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall neovim -y &>>"$LOG_FILE"; then
		log_success "Neovim uninstalled"
		return 0
	else
		log_error "Failed to uninstall Neovim"
		return 1
	fi
}

update_neovim() {
	log_info "Updating Neovim..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade neovim -y &>>"$LOG_FILE"; then
		log_success "Neovim updated"
		return 0
	else
		log_error "Failed to update Neovim"
		return 1
	fi
}