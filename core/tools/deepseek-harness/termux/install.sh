#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_dsh_dependencies() {
	loading "Installing dependencies" _dsh_dependencies_impl
}

_dsh_dependencies_impl() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["git"]="git"
		["clang"]="clang"
		["make"]="make"
		["cmake"]="cmake"
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

_install_dsh_npm() {
	loading "Installing DeepSeek Harness" _install_dsh_npm_impl
}

_install_dsh_npm_impl() {
	if ! npm i -g @deepseek-ai/dsh@latest &>>"$LOG_FILE"; then
		log_error "Failed to install DeepSeek Harness"
		return 1
	fi

	return 0
}

install_deepseek-harness() {
	if command -v dsh &>/dev/null; then
		log_info "DeepSeek Harness is already installed"
		return 2
	fi
	separator
	box_large "Installing DeepSeek Harness"
	separator
	echo
	log_info "Installing DeepSeek Harness (dsh)..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_dsh_dependencies || return 1
	_install_dsh_npm || return 1

	log_success "DeepSeek Harness installed"
	return 0
}

uninstall_deepseek-harness() {
	_walkie_remove_wrapper dsh
	if ! command -v dsh &>/dev/null; then
		log_info "DeepSeek Harness is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling DeepSeek Harness"
	separator
	echo

	confirm_remove_configs "DeepSeek Harness" \
		"$HOME/.dsh" \
		"$HOME/.config/dsh"

	log_info "Uninstalling DeepSeek Harness..."
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Removing DeepSeek Harness" _uninstall_dsh_impl

	log_success "DeepSeek Harness uninstalled"
	return 0
}

_uninstall_dsh_impl() {
	if ! npm uninstall -g @deepseek-ai/dsh &>>"$LOG_FILE"; then
		log_error "Failed to uninstall DeepSeek Harness"
		return 1
	fi
	return 0
}

update_deepseek-harness() {
	_check_update_needed "DeepSeek Harness" "$(_get_installed_version dsh)" "$(_get_remote_npm_version @deepseek-ai/dsh)" _update_dsh
}

_update_dsh() {
	_update_dsh_impl
}

_update_dsh_impl() {
	_update_dsh_npm
}

_update_dsh_npm() {
  loading "Updating DeepSeek Harness" _update_dsh_npm_impl
}

_update_dsh_npm_impl() {
  if ! npm update -g @deepseek-ai/dsh &>>"$LOG_FILE"; then
    log_error "Failed to update DeepSeek Harness"
    return 1
  fi
  return 0
}

reinstall_deepseek-harness() {
	uninstall_deepseek-harness
	install_deepseek-harness
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_deepseek-harness; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_deepseek-harness; fi
if [[ "${1:-}" == "update" ]]; then update_deepseek-harness; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_deepseek-harness; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version dsh; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_npm_version @deepseek-ai/dsh; fi
