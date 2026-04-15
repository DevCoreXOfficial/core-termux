#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

# Install prerequisites for shell plugins
_install_shell_prerequisites() {
	if command -v git &>/dev/null && command -v zsh &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install zsh zoxide git -y &>>"$LOG_FILE"
}

# ===== POWERLEVEL10K =====
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

# ===== ZSH-DEFER =====
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

# ===== ZSH-AUTOSUGGESTIONS =====
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

# ===== ZSH-SYNTAX-HIGHLIGHTING =====
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

# ===== ZSH-HISTORY-SUBSTRING-SEARCH =====
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

# ===== ZSH-COMPLETIONS =====
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

# ===== FZF-TAB =====
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

# ===== ZSH-YOU-SHOULD-USE =====
install_you_should_use() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
		log_info "zsh-you-should-use ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_shell_prerequisites

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone --depth=1 "https://github.com/MichaelAquilina/zsh-you-should-use.git" "$ZSH_PLUGINS_DIR/zsh-you-should-use" &>>"$LOG_FILE"; then
		log_success "zsh-you-should-use installed"
		return 0
	else
		log_error "Failed to install zsh-you-should-use"
		return 1
	fi
}

uninstall_you_should_use() {
	log_info "Uninstalling zsh-you-should-use..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
		rm -rf "$ZSH_PLUGINS_DIR/zsh-you-should-use"
		log_success "zsh-you-should-use uninstalled"
	else
		log_warn "zsh-you-should-use not installed"
	fi
}

update_you_should_use() {
	log_info "Updating zsh-you-should-use..."

	if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use/.git" ]]; then
		git -C "$ZSH_PLUGINS_DIR/zsh-you-should-use" pull &>>"$LOG_FILE"
		log_success "zsh-you-should-use updated"
	else
		log_warn "zsh-you-should-use not installed"
	fi
}

# ===== ZSH-AUTOPAIR =====
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

# ===== ZSH-BETTER-NPM-COMPLETION =====
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
