#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_perl() {
	if dpkg -s perl 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install perl -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_perl() {
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
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade perl -y &>>"$LOG_FILE"; then
		log_success "Perl updated"
		return 0
	else
		log_error "Failed to update Perl"
		return 1
	fi
}