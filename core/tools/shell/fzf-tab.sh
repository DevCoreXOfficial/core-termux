#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_install_shell_prerequisites() {
	if command -v git &>/dev/null && command -v zsh &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install zsh zoxide git -y &>>"$LOG_FILE"
}

install_fzf_tab() {
	if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
		log_info "fzf-tab ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/Aloxaf/fzf-tab.git" "$ZSH_PLUGINS_DIR/fzf-tab" &>>"$LOG_FILE"; then
		log_success "fzf-tab installed"
		return 0
	else
		log_error "Failed to install fzf-tab"
		return 1
	fi
}

uninstall_fzf_tab() {
	log_info "Uninstalling fzf-tab..."

	if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/fzf-tab"
		log_success "fzf-tab uninstalled"
	else
		log_warn "fzf-tab not installed"
	fi
}

update_fzf_tab() {
	log_info "Updating fzf-tab..."

	if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/fzf-tab" pull &>>"$LOG_FILE"
		log_success "fzf-tab updated"
	else
		log_warn "fzf-tab not installed"
	fi
}