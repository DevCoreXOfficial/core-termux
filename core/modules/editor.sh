#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVCHAD_REPO="https://github.com/DevCoreXOfficial/nvchad-termux.git"
NVCHAD_DIR="$HOME/.cache/core-termux/nvchad-termux"

install_editor() {
	separator
	box "Installing Code Editor"
	separator
	echo

	log_info "Installing Neovim and dependencies..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing Neovim dependencies" _install_editor_deps; then
		log_success "Neovim dependencies installed"
	else
		log_warn "Some dependencies may have failed"
	fi

	if loading "Installing NvChad configuration" _install_editor_wrapper; then
		log_success "Code editor installed successfully"
		separator
		echo
		list_item "Neovim (code editor)"
		list_item "NvChad (framework for Neovim)"
		list_item "GitHub Copilot (AI code assistant)"
		list_item "CodeCompanion (AI chat assistant)"
		echo
	else
		log_error "Failed to install code editor"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

_install_editor_deps() {
	pkg install git neovim nodejs-lts python perl curl wget lua-language-server ripgrep stylua tree-sitter -y &>"$LOG_FILE"
}

_install_editor_wrapper() {
	import "@/tools/editor/all"
	install_all_editor_components
}

uninstall_editor() {
	separator
	box "Uninstalling Code Editor"
	separator
	echo

	log_info "Uninstalling Neovim configuration..."

	if loading "Uninstalling NvChad" _uninstall_editor_wrapper; then
		log_success "Code editor uninstalled"
	else
		log_error "Failed to uninstall code editor"
		return 1
	fi
}

_uninstall_editor_wrapper() {
	import "@/tools/editor/all"
	uninstall_all_editor_components
}

update_editor() {
	separator
	box "Updating Code Editor"
	separator
	echo

	log_info "Updating NvChad configuration..."

	if loading "Updating NvChad" _update_editor_wrapper; then
		log_success "Code editor updated"
	else
		log_error "Failed to update code editor"
		return 1
	fi
}

_update_editor_wrapper() {
	import "@/tools/editor/all"
	update_all_editor_components
}