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

install_powerlevel10k() {
	if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
		log_info "powerlevel10k ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$ZSH_PLUGINS_DIR/powerlevel10k" &>>"$LOG_FILE"; then
		log_success "powerlevel10k installed"
		return 0
	else
		log_error "Failed to install powerlevel10k"
		return 1
	fi
}

uninstall_powerlevel10k() {
	log_info "Uninstalling powerlevel10k..."

	if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/powerlevel10k"
		log_success "powerlevel10k uninstalled"
	else
		log_warn "powerlevel10k not installed"
	fi
}

update_powerlevel10k() {
	log_info "Updating powerlevel10k..."

	if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/powerlevel10k" pull &>>"$LOG_FILE"
		log_success "powerlevel10k updated"
	else
		log_warn "powerlevel10k not installed"
	fi
}