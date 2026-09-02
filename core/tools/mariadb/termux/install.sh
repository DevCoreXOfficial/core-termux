#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_mariadb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install mariadb &>>"$LOG_FILE"; then
		log_success "MariaDB installed"
		return 0
	else
		return 1
	fi
}

install_mariadb() {
	if command -v mariadbd &>/dev/null; then
		log_info "MariaDB is already installed"
		return 2
	fi

	separator
	box_large "Installing MariaDB"
	separator
	echo

	log_info "Installing MariaDB..."
	loading "Installing MariaDB" _install_mariadb_impl
}

_uninstall_mariadb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MariaDB"
		return 1
	fi
}

uninstall_mariadb() {
	if ! command -v mariadbd &>/dev/null; then
		log_info "MariaDB is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling MariaDB"
	separator
	echo

	log_info "Uninstalling MariaDB..."
	loading "Uninstalling MariaDB" _uninstall_mariadb_impl
}

_update_mariadb_impl() {
	loading "Updating MariaDB" _do_mariadb_update
}

_do_mariadb_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade mariadb -y &>>"$LOG_FILE"
}

update_mariadb() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "MariaDB" "$(_get_installed_pkg_version mariadb "MariaDB")" "$(_get_remote_pkg_version mariadb)" _update_mariadb_impl
}

reinstall_mariadb() {
	uninstall_mariadb
	install_mariadb
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_mariadb; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_mariadb; fi
if [[ "${1:-}" == "update" ]]; then update_mariadb; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_mariadb; fi
