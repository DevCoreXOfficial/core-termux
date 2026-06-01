#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_autopair_install_shell_prerequisites() {
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

install_zsh_autopair() {
	if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
		log_info "zsh-autopair ${D_GREEN}already installed${NC}"
		return 0
	fi

	_zsh_autopair_install_shell_prerequisites

	log_info "Installing shell prerequisites..."
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