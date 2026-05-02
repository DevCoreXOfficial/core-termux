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

install_zsh_syntax_highlighting() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
		log_info "zsh-syntax-highlighting ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" &>>"$LOG_FILE"; then
		log_success "zsh-syntax-highlighting installed"
		return 0
	else
		log_error "Failed to install zsh-syntax-highlighting"
		return 1
	fi
}

uninstall_zsh_syntax_highlighting() {
	log_info "Uninstalling zsh-syntax-highlighting..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
		log_success "zsh-syntax-highlighting uninstalled"
	else
		log_warn "zsh-syntax-highlighting not installed"
	fi
}

update_zsh_syntax_highlighting() {
	log_info "Updating zsh-syntax-highlighting..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" pull &>>"$LOG_FILE"
		log_success "zsh-syntax-highlighting updated"
	else
		log_warn "zsh-syntax-highlighting not installed"
	fi
}