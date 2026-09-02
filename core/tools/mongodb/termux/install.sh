#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_mongodb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"

	if [[ ! -f $PREFIX/etc/apt/sources.list.d/tur.list ]]; then
		if ! yes | pkg install tur-repo &>>"$LOG_FILE"; then
			log_error "Failed to install tur-repo"
			return 1
		fi
	fi

	if yes | pkg install mongodb &>>"$LOG_FILE"; then
		log_success "MongoDB installed"
		return 0
	else
		return 1
	fi
}

install_mongodb() {
	if command -v mongod &>/dev/null; then
		log_info "MongoDB is already installed"
		return 2
	fi

	separator
	box_large "Installing MongoDB"
	separator
	echo

	log_info "Installing MongoDB..."
	loading "Installing MongoDB" _install_mongodb_impl
}

_uninstall_mongodb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MongoDB"
		return 1
	fi
}

uninstall_mongodb() {
	if ! command -v mongod &>/dev/null; then
		log_info "MongoDB is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling MongoDB"
	separator
	echo

	log_info "Uninstalling MongoDB..."
	loading "Uninstalling MongoDB" _uninstall_mongodb_impl
}

_update_mongodb_impl() {
	loading "Updating MongoDB" _do_mongodb_update
}

_do_mongodb_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade mongodb -y &>>"$LOG_FILE"
}

update_mongodb() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "MongoDB" "$(_get_installed_pkg_version mongodb "MongoDB")" "$(_get_remote_pkg_version mongodb)" _update_mongodb_impl
}

reinstall_mongodb() {
	uninstall_mongodb
	install_mongodb
}

# ===== version check =====
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version mongosh; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version mongodb/mongosh; fi

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_mongodb; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_mongodb; fi
if [[ "${1:-}" == "update" ]]; then update_mongodb; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_mongodb; fi
