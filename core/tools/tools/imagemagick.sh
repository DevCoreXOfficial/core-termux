#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_tools.log"

install_imagemagick() {
	if dpkg -s imagemagick 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick installed"
		return 0
	else
		log_error "Failed to install ImageMagick"
		return 1
	fi
}

uninstall_imagemagick() {
	log_info "Uninstalling ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick uninstalled"
		return 0
	else
		log_error "Failed to uninstall ImageMagick"
		return 1
	fi
}

update_imagemagick() {
	log_info "Updating ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade imagemagick -y &>>"$LOG_FILE"; then
		log_success "ImageMagick updated"
		return 0
	else
		log_error "Failed to update ImageMagick"
		return 1
	fi
}