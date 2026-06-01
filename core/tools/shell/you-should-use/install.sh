#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_you_should_use_install_shell_prerequisites() {
	declare -A DEPS=(
		["zsh"]="zsh"
		["zoxide"]="zoxide"
		["git"]="git"
	)

	local pkg_name bin_name
	for pkg_name in "${!DEPS[@]}"; do
		bin_name="${DEPS[$pkg_name]}"
		if ! command -v "$bin_name" &>/dev/null; then
			if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
				log_error "Failed to install $pkg_name"
				return 1
			fi
		fi
	done

	log_success "Shell prerequisites installed"
	return 0
}

install_you_should_use() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
		log_info "zsh-you-should-use ${D_GREEN}already installed${NC}"
		return 0
	fi

	_you_should_use_install_shell_prerequisites

	log_info "Installing shell prerequisites..."
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