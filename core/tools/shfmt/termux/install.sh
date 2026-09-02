#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_shfmt_pkg() {
	loading "Installing Shfmt" _install_shfmt_pkg_impl
}

_install_shfmt_pkg_impl() {
	if ! yes | pkg install shfmt &>>"$LOG_FILE"; then
		log_error "Failed to install Shfmt"
		return 1
	fi
	return 0
}

_uninstall_shfmt_pkg() {
	loading "Uninstalling Shfmt" _uninstall_shfmt_pkg_impl
}

_uninstall_shfmt_pkg_impl() {
	if ! pkg uninstall shfmt -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Shfmt"
		return 1
	fi
	return 0
}

_update_shfmt_pkg() {
  loading "Updating Shfmt" _do_shfmt_update
}

_do_shfmt_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade shfmt -y &>>"$LOG_FILE"
}

install_shfmt() {
	if command -v shfmt &>/dev/null; then
		log_info "Shfmt is already installed"
		return 2
	fi

	separator
	box_large "Installing shfmt"
	separator
	echo

	log_info "Installing Shfmt..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_shfmt_pkg || return 1
	log_success "Shfmt installed"
	return 0
}

uninstall_shfmt() {
	if ! command -v shfmt &>/dev/null; then
		log_info "Shfmt is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling shfmt"
	separator
	echo

	log_info "Uninstalling Shfmt..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_shfmt_pkg || return 1
	log_success "Shfmt uninstalled"
	return 0
}

update_shfmt() {
	_check_update_needed "Shfmt" "$(_get_installed_pkg_version shfmt Shfmt)" "$(_get_remote_pkg_version shfmt)" _update_shfmt_pkg
}

reinstall_shfmt() {
	uninstall_shfmt
	install_shfmt
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_shfmt; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_shfmt; fi
if [[ "${1:-}" == "update" ]]; then update_shfmt; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_shfmt; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version shfmt; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version mvdan/sh; fi
