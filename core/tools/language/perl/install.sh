#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_perl() {
	if command -v perl &>/dev/null; then
		log_success "Perl is already installed"
		return 0
	fi
	log_info "Installing Perl..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install perl -y &>>"$LOG_FILE"; then
		log_success "Perl installed"
		return 0
	else
		return 1
	fi
}

uninstall_perl() {
	log_info "Uninstalling Perl..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall perl -y &>>"$LOG_FILE"; then
		log_success "Perl uninstalled"
		return 0
	else
		log_error "Failed to uninstall Perl"
		return 1
	fi
}

update_perl() {
	log_info "Updating Perl..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade perl -y &>>"$LOG_FILE"; then
		log_success "Perl updated"
		return 0
	else
		log_error "Failed to update Perl"
		return 1
	fi
}

reinstall_perl() {
	uninstall_perl
	install_perl
}