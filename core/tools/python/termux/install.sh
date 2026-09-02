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

_install_python_pkg() {
	loading "Installing Python" _install_python_pkg_impl
}

_install_python_pkg_impl() {
	if ! yes | pkg install python &>>"$LOG_FILE"; then
		log_error "Failed to install Python"
		return 1
	fi
	return 0
}

install_python() {
	if command -v python &>/dev/null; then
		log_info "Python is already installed"
		return 2
	fi

	separator
	box_large "Installing Python"
	separator
	echo

	log_info "Installing Python..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_python_pkg || return 1
	log_success "Python installed"
	return 0
}

_uninstall_python_pkg() {
	loading "Uninstalling Python" _uninstall_python_pkg_impl
}

_uninstall_python_pkg_impl() {
	if ! pkg uninstall python -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Python"
		return 1
	fi
	return 0
}

uninstall_python() {
	if ! command -v python &>/dev/null; then
		log_info "Python is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Python"
	separator
	echo

	confirm_remove_configs "Python" \
		"$HOME/.python_history" \
		"$HOME/.cache/pip" \
		"$HOME/.cache/black"

	log_info "Uninstalling Python..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_python_pkg || return 1
	log_success "Python uninstalled"
	return 0
}

_update_python_pkg() {
  loading "Updating Python" _do_python_update
}

_do_python_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade python -y &>>"$LOG_FILE"
}

update_python() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Python" "$(_get_installed_pkg_version python "Python")" "$(_get_remote_pkg_version python)" _update_python_pkg
}

reinstall_python() {
	uninstall_python
	install_python
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_python; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_python; fi
if [[ "${1:-}" == "update" ]]; then update_python; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_python; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version python3; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_pkg_version python; fi
