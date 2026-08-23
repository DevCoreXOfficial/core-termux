#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_db.log"

_install_redis_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if yes | pkg install redis &>>"$LOG_FILE"; then
		log_success "Redis installed"
		return 0
	else
		return 1
	fi
}

install_redis() {
	if command -v redis-cli &>/dev/null; then
		log_info "Redis is already installed"
		return 2
	fi
	log_info "Installing Redis..."
	loading "Installing Redis" _install_redis_impl
}

_uninstall_redis_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall redis -y &>>"$LOG_FILE"; then
		log_success "Redis uninstalled"
		return 0
	else
		log_error "Failed to uninstall Redis"
		return 1
	fi
}

uninstall_redis() {
	if ! command -v redis-cli &>/dev/null; then
		log_info "Redis is not installed"
		return 2
	fi
	log_info "Uninstalling Redis..."
	loading "Uninstalling Redis" _uninstall_redis_impl
}

_update_redis_impl() {
	loading "Updating Redis" _do_redis_update
}

_do_redis_update() {
	mkdir -p "$(dirname "$LOG_FILE")"
	pkg upgrade redis -y &>>"$LOG_FILE"
}

update_redis() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Redis" "$(_get_installed_pkg_version redis "Redis")" "$(_get_remote_pkg_version redis)" _update_redis_impl
}

reinstall_redis() {
	uninstall_redis
	install_redis
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_redis; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_redis; fi
if [[ "${1:-}" == "update" ]]; then update_redis; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_redis; fi
