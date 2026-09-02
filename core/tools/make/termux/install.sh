#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_make_pkg() {
	loading "Installing Make" _install_make_pkg_impl
}

_install_make_pkg_impl() {
	if ! yes | pkg install make &>>"$LOG_FILE"; then
		log_error "Failed to install Make"
		return 1
	fi
	return 0
}

_uninstall_make_pkg() {
	loading "Uninstalling Make" _uninstall_make_pkg_impl
}

_uninstall_make_pkg_impl() {
	if ! pkg uninstall make -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Make"
		return 1
	fi
	return 0
}

_update_make_pkg() {
  loading "Updating Make" _do_make_update
}

_do_make_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade make -y &>>"$LOG_FILE"
}

install_make() {
	if command -v make &>/dev/null; then
		log_info "Make is already installed"
		return 2
	fi

	separator
	box_large "Installing Make"
	separator
	echo

	log_info "Installing Make..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_make_pkg || return 1
	log_success "Make installed"
	return 0
}

uninstall_make() {
	if ! command -v make &>/dev/null; then
		log_info "Make is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Make"
	separator
	echo

	log_info "Uninstalling Make..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_make_pkg || return 1
	log_success "Make uninstalled"
	return 0
}

update_make() {
	_check_update_needed "Make" "$(_get_installed_pkg_version make "Make")" "$(_get_remote_pkg_version make)" _update_make_pkg
}

reinstall_make() {
	uninstall_make
	install_make
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_make; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_make; fi
if [[ "${1:-}" == "update" ]]; then update_make; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_make; fi
