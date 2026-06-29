#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
	log_info "Uninstalling MongoDB..."
	loading "Uninstalling MongoDB" _uninstall_mongodb_impl
}

_update_mongodb_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB updated"
		return 0
	else
		log_error "Failed to update MongoDB"
		return 1
	fi
}

update_mongodb() {
	log_info "Updating MongoDB..."
	loading "Updating MongoDB" _update_mongodb_impl
}

reinstall_mongodb() {
	uninstall_mongodb
	install_mongodb
}
