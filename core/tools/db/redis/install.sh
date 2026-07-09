#!/data/data/com.termux/files/usr/bin/bash

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
