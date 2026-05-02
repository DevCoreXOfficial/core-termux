#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
LOG_FILE="$CORE_CACHE/install_shell.log"

install_termux_packages() {
	log_info "Installing zsh and zoxide in Termux..."

	if pkg install -y zsh zoxide &>>"$LOG_FILE"; then
		log_success "zsh and zoxide installed successfully"
		return 0
	else
		log_error "Failed to install zsh and zoxide"
		return 1
	fi
}

install_oh_my_zsh() {
	if [[ -d "$OH_MY_ZSH_DIR" ]]; then
		log_warn "Oh My Zsh already installed"
		return 0
	fi

	log_info "Downloading Oh My Zsh..."
	log_info "When prompted, enter (Y/n) to set ZSH as your default shell"
	echo

	local temp_dir="${PREFIX:-/tmp}/tmp"
	mkdir -p "$temp_dir"
	local temp_file="$temp_dir/omz_install.sh"

	if curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$temp_file" &>>"$LOG_FILE"; then
		sed -i '/exec zsh -l/s/^/#/' "$temp_file"
		sh "$temp_file" &>>"$LOG_FILE"
		rm "$temp_file"
		log_success "Oh My Zsh installed successfully"
		return 0
	else
		log_error "Failed to download Oh My Zsh"
		return 1
	fi
}

add_to_zshrc() {
	local line="$1"
	if ! grep -qxF "$line" ~/.zshrc 2>/dev/null; then
		echo "$line" >>~/.zshrc
	fi
}

setup_zsh_aliases() {
	log_info "Setting up ZSH aliases..."

	add_to_zshrc "alias ls=\"lsd\""
	add_to_zshrc 'alias cat="bat --theme=Dracula --style=plain --paging=never"'
	add_to_zshrc 'eval "$(zoxide init zsh)"'

	log_success "ZSH aliases configured"
}

setupPersistentSession() {
	log_info "Configuring persistent session..."

	mkdir -p "$CORE_CACHE" 2>/dev/null || mkdir -p ~/.cache/core-termux

	echo "$HOME" > ~/.cache/core-termux/last_dir

	if grep -q "# ===== Persistent Directory =====" ~/.zshrc 2>/dev/null; then
		log_warn "Persistent session already configured"
		return 0
	fi

	cat >>~/.zshrc <<'EOF'

# ===== Persistent Directory =====
LAST_DIR_FILE="$HOME/.cache/core-termux/last_dir"
SESSION_TIMESTAMP="$HOME/.cache/core-termux/.session_time"
SESSION_TIMEOUT=5

save_dir() {
  mkdir -p ~/.cache/core-termux 2>/dev/null
  pwd > "$LAST_DIR_FILE"
  date +%s > "$SESSION_TIMESTAMP"
}

restore_dir() {
  if [[ -f "$SESSION_TIMESTAMP" ]] && [[ -f "$LAST_DIR_FILE" ]]; then
    local current_time
    local last_time
    current_time=$(date +%s)
    last_time=$(cat "$SESSION_TIMESTAMP" 2>/dev/null || echo 0)
    local diff=$((current_time - last_time))

    if [[ $diff -lt $SESSION_TIMEOUT ]]; then
      local dir
      dir=$(cat "$LAST_DIR_FILE" 2>/dev/null)
      if [[ -d "$dir" ]] && [[ "$dir" != "$HOME" ]]; then
        cd "$dir" 2>/dev/null
      fi
    fi
  fi
  date +%s > "$SESSION_TIMESTAMP"
}

if typeset -f add-zsh-hook &>/dev/null; then
  add-zsh-hook precmd save_dir
  restore_dir
else
  restore_dir
  trap 'save_dir' EXIT
fi
echo
EOF

	log_success "Persistent session configured"
	log_info "New sessions within Termux will restore last directory"
}

install_shell() {
	separator
	box "Installing ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing zsh and zoxide" install_termux_packages; then
		log_success "Base packages installed"
	else
		log_error "Failed to install base packages"
	fi
	echo

	install_oh_my_zsh
	echo

	if loading "Installing ZSH plugins" _install_shell_plugins_wrapper; then
		log_success "ZSH plugins installed"
	else
		log_error "Failed to install ZSH plugins"
	fi
	echo

	setup_zsh_aliases
	echo

	setupPersistentSession
	echo

	separator
	log_success "ZSH shell environment setup completed"
	separator
	echo
	log_warn "Please restart Termux or run: exec zsh"
	echo
}

_install_shell_plugins_wrapper() {
	import "@/tools/shell/all"
	install_all_shell_plugins

	if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-defer" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh'
		add_to_zshrc "bindkey '^[[A' history-substring-search-up"
		add_to_zshrc "bindkey '^[[B' history-substring-search-down"
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
		add_to_zshrc 'fpath+=~/.zsh-plugins/zsh-completions'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh'
		add_to_zshrc "zstyle ':completion:*' menu-select yes"
		add_to_zshrc "zstyle ':fzf-tab:*' switch-word yes"
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-you-should-use/you-should-use.plugin.zsh'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-autopair/autopair.zsh'
	fi
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
		add_to_zshrc 'source ~/.zsh-plugins/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh'
	fi
}

uninstall_oh_my_zsh() {
	if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
		log_warn "Oh My Zsh not installed"
		return 0
	fi

	log_info "Uninstalling Oh My Zsh..."

	if rm -rf "$OH_MY_ZSH_DIR" &>>"$LOG_FILE"; then
		log_success "Oh My Zsh uninstalled"
	else
		log_error "Failed to uninstall Oh My Zsh"
		return 1
	fi
}

uninstall_shell() {
	separator
	box "Uninstalling ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_shell_plugins_wrapper
	uninstall_oh_my_zsh

	echo
	separator
	log_success "ZSH shell environment uninstalled"
	separator
	echo
}

_uninstall_shell_plugins_wrapper() {
	import "@/tools/shell/all"
	uninstall_all_shell_plugins
}

update_shell() {
	separator
	box "Updating ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Updating ZSH plugins" _update_shell_plugins_wrapper; then
		log_success "ZSH shell environment updated"
	else
		log_error "Failed to update ZSH plugins"
	fi

	echo
	separator
	log_success "ZSH update completed"
	separator
	echo
}

_update_shell_plugins_wrapper() {
	import "@/tools/shell/all"
	update_all_shell_plugins
}