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

install_zsh_autopair() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
		log_info "zsh-autopair ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/hlissner/zsh-autopair.git" "$ZSH_PLUGINS_DIR/zsh-autopair" &>>"$LOG_FILE"; then
		log_success "zsh-autopair installed"
		return 0
	else
		log_error "Failed to install zsh-autopair"
		return 1
	fi
}

uninstall_zsh_autopair() {
	log_info "Uninstalling zsh-autopair..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-autopair"
		log_success "zsh-autopair uninstalled"
	else
		log_warn "zsh-autopair not installed"
	fi
}

update_zsh_autopair() {
	log_info "Updating zsh-autopair..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-autopair" pull &>>"$LOG_FILE"
		log_success "zsh-autopair updated"
	else
		log_warn "zsh-autopair not installed"
	fi
}