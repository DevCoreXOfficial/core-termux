#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_codex_install_dependencies() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["git"]="git"
		["ripgrep"]="rg"
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

	log_success "Dependencies installed"
	return 0
}

install_codex() {
	if command -v codex &>/dev/null; then
		log_success "Codex CLI is already installed"
		return 0
	fi
	log_info "Installing Codex CLI..."

	if ! _codex_install_dependencies; then
		log_error "Failed to install dependencies"
		return 1
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm i -g @mmmbuto/codex-cli-termux@latest &>>"$LOG_FILE"; then
		log_success "Codex CLI installed"
		return 0
	else
		log_error "Failed to install Codex CLI"
		return 1
	fi
}

uninstall_codex() {
	log_info "Uninstalling Codex CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @mmmbuto/codex-cli-termux &>>"$LOG_FILE"; then
		log_success "Codex CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall Codex CLI"
		return 1
	fi
}

update_codex() {
	log_info "Updating Codex CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g @mmmbuto/codex-cli-termux &>>"$LOG_FILE"; then
		log_success "Codex CLI updated"
		return 0
	else
		log_error "Failed to update Codex CLI"
		return 1
	fi
}
