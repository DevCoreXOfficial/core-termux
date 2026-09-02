#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_jq_pkg() {
	loading "Installing jq" _install_jq_pkg_impl
}

_install_jq_pkg_impl() {
	if ! yes | pkg install jq &>>"$LOG_FILE"; then
		log_error "Failed to install jq"
		return 1
	fi
	return 0
}

_uninstall_jq_pkg() {
	loading "Uninstalling jq" _uninstall_jq_pkg_impl
}

_uninstall_jq_pkg_impl() {
	if ! pkg uninstall jq -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall jq"
		return 1
	fi
	return 0
}

_update_jq_pkg() {
  loading "Updating jq" _do_jq_update
}

_do_jq_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade jq -y &>>"$LOG_FILE"
}

install_jq() {
	if command -v jq &>/dev/null; then
		log_info "jq is already installed"
		return 2
	fi

	separator
	box_large "Installing jq"
	separator
	echo

	log_info "Installing jq..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_jq_pkg || return 1
	log_success "jq installed"
	return 0
}

uninstall_jq() {
	if ! command -v jq &>/dev/null; then
		log_info "jq is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling jq"
	separator
	echo

	log_info "Uninstalling jq..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_jq_pkg || return 1
	log_success "jq uninstalled"
	return 0
}

update_jq() {
	_check_update_needed "jq" "$(_get_installed_pkg_version jq "jq")" "$(_get_remote_pkg_version jq)" _update_jq_pkg
}

reinstall_jq() {
	uninstall_jq
	install_jq
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_jq; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_jq; fi
if [[ "${1:-}" == "update" ]]; then update_jq; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_jq; fi
