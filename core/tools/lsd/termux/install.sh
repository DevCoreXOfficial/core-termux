#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_lsd_pkg() {
	loading "Installing LSD" _install_lsd_pkg_impl
}

_install_lsd_pkg_impl() {
	if ! yes | pkg install lsd &>>"$LOG_FILE"; then
		log_error "Failed to install LSD"
		return 1
	fi
	return 0
}

_uninstall_lsd_pkg() {
	loading "Uninstalling LSD" _uninstall_lsd_pkg_impl
}

_uninstall_lsd_pkg_impl() {
	if ! pkg uninstall lsd -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall LSD"
		return 1
	fi
	return 0
}

_update_lsd_pkg() {
  loading "Updating LSD" _do_lsd_update
}

_do_lsd_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade lsd -y &>>"$LOG_FILE"
}

install_lsd() {
	if command -v lsd &>/dev/null; then
		log_info "LSD is already installed"
		return 2
	fi

	separator
	box_large "Installing LSD"
	separator
	echo

	log_info "Installing LSD..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_lsd_pkg || return 1
	log_success "LSD installed"
	return 0
}

uninstall_lsd() {
	if ! command -v lsd &>/dev/null; then
		log_info "LSD is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling LSD"
	separator
	echo

	log_info "Uninstalling LSD..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_lsd_pkg || return 1
	log_success "LSD uninstalled"
	return 0
}

update_lsd() {
	_check_update_needed "LSD" "$(_get_installed_pkg_version lsd "LSD")" "$(_get_remote_pkg_version lsd)" _update_lsd_pkg
}

reinstall_lsd() {
	uninstall_lsd
	install_lsd
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_lsd; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_lsd; fi
if [[ "${1:-}" == "update" ]]; then update_lsd; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_lsd; fi
