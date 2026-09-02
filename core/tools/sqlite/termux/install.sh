#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_sqlite_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install sqlite &>>"$LOG_FILE"; then
		log_success "SQLite installed"
		return 0
	else
		return 1
	fi
}

install_sqlite() {
	if command -v sqlite3 &>/dev/null; then
		log_info "SQLite is already installed"
		return 2
	fi

	separator
	box_large "Installing SQLite"
	separator
	echo

	log_info "Installing SQLite..."
	loading "Installing SQLite" _install_sqlite_impl
}

_uninstall_sqlite_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite uninstalled"
		return 0
	else
		log_error "Failed to uninstall SQLite"
		return 1
	fi
}

uninstall_sqlite() {
	if ! command -v sqlite3 &>/dev/null; then
		log_info "SQLite is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling SQLite"
	separator
	echo

	log_info "Uninstalling SQLite..."
	loading "Uninstalling SQLite" _uninstall_sqlite_impl
}

_update_sqlite_impl() {
	loading "Updating SQLite" _do_sqlite_update
}

_do_sqlite_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade sqlite -y &>>"$LOG_FILE"
}

update_sqlite() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "SQLite" "$(_get_installed_pkg_version sqlite "SQLite")" "$(_get_remote_pkg_version sqlite)" _update_sqlite_impl
}

reinstall_sqlite() {
	uninstall_sqlite
	install_sqlite
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_sqlite; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_sqlite; fi
if [[ "${1:-}" == "update" ]]; then update_sqlite; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_sqlite; fi
