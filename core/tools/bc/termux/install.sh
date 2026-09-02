#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_bc_pkg() {
	loading "Installing bc" _install_bc_pkg_impl
}

_install_bc_pkg_impl() {
	if ! yes | pkg install bc &>>"$LOG_FILE"; then
		log_error "Failed to install bc"
		return 1
	fi
	return 0
}

_uninstall_bc_pkg() {
	loading "Uninstalling bc" _uninstall_bc_pkg_impl
}

_uninstall_bc_pkg_impl() {
	if ! pkg uninstall bc -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall bc"
		return 1
	fi
	return 0
}

_update_bc_pkg() {
  loading "Updating bc" _do_bc_update
}

_do_bc_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade bc -y &>>"$LOG_FILE"
}

install_bc() {
	if command -v bc &>/dev/null; then
		log_info "bc is already installed"
		return 2
	fi

	separator
	box_large "Installing BC"
	separator
	echo

	log_info "Installing bc..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_bc_pkg || return 1
	log_success "bc installed"
	return 0
}

uninstall_bc() {
	if ! command -v bc &>/dev/null; then
		log_info "bc is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling BC"
	separator
	echo

	log_info "Uninstalling bc..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_bc_pkg || return 1
	log_success "bc uninstalled"
	return 0
}

update_bc() {
	_check_update_needed "bc" "$(_get_installed_pkg_version bc "bc")" "$(_get_remote_pkg_version bc)" _update_bc_pkg
}

reinstall_bc() {
	uninstall_bc
	install_bc
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_bc; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_bc; fi
if [[ "${1:-}" == "update" ]]; then update_bc; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_bc; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version bc; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_pkg_version bc; fi
