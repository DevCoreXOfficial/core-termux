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

install_zsh_defer() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-defer" ]]; then
		log_info "zsh-defer ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/romkatv/zsh-defer.git" "$ZSH_PLUGINS_DIR/zsh-defer" &>>"$LOG_FILE"; then
		log_success "zsh-defer installed"
		return 0
	else
		log_error "Failed to install zsh-defer"
		return 1
	fi
}

uninstall_zsh_defer() {
	log_info "Uninstalling zsh-defer..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-defer" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-defer"
		log_success "zsh-defer uninstalled"
	else
		log_warn "zsh-defer not installed"
	fi
}

update_zsh_defer() {
	log_info "Updating zsh-defer..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-defer/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-defer" pull &>>"$LOG_FILE"
		log_success "zsh-defer updated"
	else
		log_warn "zsh-defer not installed"
	fi
}