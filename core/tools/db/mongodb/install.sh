#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

install_mongodb() {
	if command -v mongod &>/dev/null; then
		log_success "MongoDB is already installed"
		return 0
	fi
	log_info "Installing MongoDB..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if [[ ! -f $PREFIX/etc/apt/sources.list.d/tur.list ]]; then
		if ! pkg install tur-repo -y &>>"$LOG_FILE"; then
			log_error "Failed to install tur-repo"
			return 1
		fi
	fi

	if pkg install mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB installed"
		return 0
	else
		return 1
	fi
}

uninstall_mongodb() {
	log_info "Uninstalling MongoDB..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MongoDB"
		return 1
	fi
}

update_mongodb() {
	log_info "Updating MongoDB..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB updated"
		return 0
	else
		log_error "Failed to update MongoDB"
		return 1
	fi
}