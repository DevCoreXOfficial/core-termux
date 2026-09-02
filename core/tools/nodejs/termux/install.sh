#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_npmjs_pkg() {
	loading "Installing Node.js LTS" _install_npmjs_pkg_impl
}

_install_npmjs_pkg_impl() {
	if ! yes | pkg install nodejs-lts &>>"$LOG_FILE"; then
		log_error "Failed to install Node.js LTS"
		return 1
	fi
	return 0
}

_enable_corepack() {
	loading "Enabling Corepack (pnpm, yarn)" _enable_corepack_impl
}

_enable_corepack_impl() {
	if ! corepack enable &>>"$LOG_FILE"; then
		log_error "Failed to enable Corepack"
		return 1
	fi
	return 0
}

install_npmjs() {
	if command -v node &>/dev/null; then
		log_info "Node.js LTS is already installed"
		return 2
	fi

	separator
	box_large "Installing Node.js"
	separator
	echo

	log_info "Installing Node.js LTS..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_npmjs_pkg || return 1
	_enable_corepack || return 1
	log_success "Node.js LTS installed (pnpm, yarn available via corepack)"
	return 0
}

_uninstall_npmjs_pkg() {
	loading "Uninstalling Node.js LTS" _uninstall_npmjs_pkg_impl
}

_uninstall_npmjs_pkg_impl() {
	if ! pkg uninstall nodejs-lts -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Node.js LTS"
		return 1
	fi
	return 0
}

uninstall_npmjs() {
	if ! command -v node &>/dev/null; then
		log_info "Node.js LTS is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Node.js"
	separator
	echo

	confirm_remove_configs "Node.js" \
		"$HOME/.npm" \
		"$HOME/.npmrc" \
		"$HOME/.node_repl_history" \
		"$HOME/.config/yarn" \
		"$HOME/.cache/yarn"

	log_info "Uninstalling Node.js LTS..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_npmjs_pkg || return 1
	log_success "Node.js LTS uninstalled"
	return 0
}

_update_npmjs_pkg() {
  loading "Updating Node.js LTS" _do_npmjs_update
}

_do_npmjs_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade nodejs-lts -y &>>"$LOG_FILE"
}

update_npmjs() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Node.js LTS" "$(_get_installed_pkg_version nodejs-lts "Node.js LTS")" "$(_get_remote_pkg_version nodejs-lts)" _update_npmjs_pkg
}

reinstall_npmjs() {
	uninstall_npmjs
	install_npmjs
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_npmjs; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_npmjs; fi
if [[ "${1:-}" == "update" ]]; then update_npmjs; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_npmjs; fi
