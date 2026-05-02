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

install_zsh_completions() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
		log_info "zsh-completions ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/zsh-users/zsh-completions.git" "$ZSH_PLUGINS_DIR/zsh-completions" &>>"$LOG_FILE"; then
		log_success "zsh-completions installed"
		return 0
	else
		log_error "Failed to install zsh-completions"
		return 1
	fi
}

uninstall_zsh_completions() {
	log_info "Uninstalling zsh-completions..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-completions"
		log_success "zsh-completions uninstalled"
	else
		log_warn "zsh-completions not installed"
	fi
}

update_zsh_completions() {
	log_info "Updating zsh-completions..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-completions" pull &>>"$LOG_FILE"
		log_success "zsh-completions updated"
	else
		log_warn "zsh-completions not installed"
	fi
}