#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_php_pkg() {
	loading "Installing PHP" _install_php_pkg_impl
}

_install_php_pkg_impl() {
	if ! yes | pkg install php &>>"$LOG_FILE"; then
		log_error "Failed to install PHP"
		return 1
	fi
	return 0
}

install_php() {
	if command -v php &>/dev/null; then
		log_info "PHP is already installed"
		return 2
	fi
	log_info "Installing PHP..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_php_pkg || return 1
	log_success "PHP installed"
	return 0
}

_uninstall_php_pkg() {
	loading "Uninstalling PHP" _uninstall_php_pkg_impl
}

_uninstall_php_pkg_impl() {
	if ! pkg uninstall php -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall PHP"
		return 1
	fi
	return 0
}

uninstall_php() {
	if ! command -v php &>/dev/null; then
		log_info "PHP is not installed"
		return 2
	fi
	log_info "Uninstalling PHP..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_php_pkg || return 1
	log_success "PHP uninstalled"
	return 0
}

_update_php_pkg() {
  loading "Updating PHP" _do_php_update
}

_do_php_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade php -y &>>"$LOG_FILE"
}

update_php() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "PHP" "$(_get_installed_pkg_version php "PHP")" "$(_get_remote_pkg_version php)" _update_php_pkg
}

reinstall_php() {
	uninstall_php
	install_php
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_php; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_php; fi
if [[ "${1:-}" == "update" ]]; then update_php; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_php; fi
