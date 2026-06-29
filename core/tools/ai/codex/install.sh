#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_codex_dependencies() {
	loading "Installing dependencies" _codex_dependencies_impl
}

_codex_dependencies_impl() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["git"]="git"
		["ripgrep"]="rg"
	)

	local pkg_name bin_name
	for pkg_name in "${!DEPS[@]}"; do
		bin_name="${DEPS[$pkg_name]}"
		if ! command -v "$bin_name" &>/dev/null; then
			if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
				log_error "Failed to install $pkg_name"
				return 1
			fi
		fi
	done

	return 0
}

_install_codex_npm() {
	loading "Installing Codex CLI" _install_codex_npm_impl
}

_install_codex_npm_impl() {
	if ! npm i -g @mmmbuto/codex-cli-termux@latest &>>"$LOG_FILE"; then
		log_error "Failed to install Codex CLI"
		return 1
	fi

	return 0
}

install_codex() {
	if command -v codex &>/dev/null; then
		log_info "Codex CLI is already installed"
		return 2
	fi
	log_info "Installing Codex CLI..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_codex_dependencies || return 1
	_install_codex_npm || return 1

	log_success "Codex CLI installed"
	return 0
}

uninstall_codex() {
	if ! command -v codex &>/dev/null; then
		log_info "Codex CLI is not installed"
		return 2
	fi
	log_info "Uninstalling Codex CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Removing Codex CLI" _uninstall_codex_impl

	log_success "Codex CLI uninstalled"
	return 0
}

_uninstall_codex_impl() {
	if ! npm uninstall -g @mmmbuto/codex-cli-termux &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Codex CLI"
		return 1
	fi
	return 0
}

update_codex() {
	log_info "Updating Codex CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Updating Codex CLI" _update_codex_impl

	log_success "Codex CLI updated"
	return 0
}

_update_codex_impl() {
	if ! npm update -g @mmmbuto/codex-cli-termux &>>"$LOG_FILE"; then
		log_error "Failed to update Codex CLI"
		return 1
	fi
	return 0
}

reinstall_codex() {
	uninstall_codex
	install_codex
}
