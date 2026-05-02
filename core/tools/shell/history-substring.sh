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

install_history_substring() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
		log_info "zsh-history-substring-search ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/zsh-users/zsh-history-substring-search.git" "$ZSH_PLUGINS_DIR/zsh-history-substring-search" &>>"$LOG_FILE"; then
		log_success "zsh-history-substring-search installed"
		return 0
	else
		log_error "Failed to install zsh-history-substring-search"
		return 1
	fi
}

uninstall_history_substring() {
	log_info "Uninstalling zsh-history-substring-search..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
		log_success "zsh-history-substring-search uninstalled"
	else
		log_warn "zsh-history-substring-search not installed"
	fi
}

update_history_substring() {
	log_info "Updating zsh-history-substring-search..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-history-substring-search" pull &>>"$LOG_FILE"
		log_success "zsh-history-substring-search updated"
	else
		log_warn "zsh-history-substring-search not installed"
	fi
}