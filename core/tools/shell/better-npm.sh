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

install_better_npm() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
		log_info "zsh-better-npm-completion ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/lukechilds/zsh-better-npm-completion.git" "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" &>>"$LOG_FILE"; then
		log_success "zsh-better-npm-completion installed"
		return 0
	else
		log_error "Failed to install zsh-better-npm-completion"
		return 1
	fi
}

uninstall_better_npm() {
	log_info "Uninstalling zsh-better-npm-completion..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-better-npm-completion"
		log_success "zsh-better-npm-completion uninstalled"
	else
		log_warn "zsh-better-npm-completion not installed"
	fi
}

update_better_npm() {
	log_info "Updating zsh-better-npm-completion..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" pull &>>"$LOG_FILE"
		log_success "zsh-better-npm-completion updated"
	else
		log_warn "zsh-better-npm-completion not installed"
	fi
}