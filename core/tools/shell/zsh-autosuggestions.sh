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

install_zsh_autosuggestions() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
		log_info "zsh-autosuggestions ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_PLUGINS_DIR/zsh-autosuggestions" &>>"$LOG_FILE"; then
		log_success "zsh-autosuggestions installed"
		return 0
	else
		log_error "Failed to install zsh-autosuggestions"
		return 1
	fi
}

uninstall_zsh_autosuggestions() {
	log_info "Uninstalling zsh-autosuggestions..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
		log_success "zsh-autosuggestions uninstalled"
	else
		log_warn "zsh-autosuggestions not installed"
	fi
}

update_zsh_autosuggestions() {
	log_info "Updating zsh-autosuggestions..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-autosuggestions" pull &>>"$LOG_FILE"
		log_success "zsh-autosuggestions updated"
	else
		log_warn "zsh-autosuggestions not installed"
	fi
}