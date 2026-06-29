#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_imagemagick_pkg() {
	loading "Installing ImageMagick" _install_imagemagick_pkg_impl
}

_install_imagemagick_pkg_impl() {
	if ! yes | pkg install imagemagick &>>"$LOG_FILE"; then
		log_error "Failed to install ImageMagick"
		return 1
	fi
	return 0
}

_uninstall_imagemagick_pkg() {
	loading "Uninstalling ImageMagick" _uninstall_imagemagick_pkg_impl
}

_uninstall_imagemagick_pkg_impl() {
	if ! pkg uninstall imagemagick -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall ImageMagick"
		return 1
	fi
	return 0
}

_update_imagemagick_pkg() {
	loading "Updating ImageMagick" _update_imagemagick_pkg_impl
}

_update_imagemagick_pkg_impl() {
	if ! pkg upgrade imagemagick -y &>>"$LOG_FILE"; then
		log_error "Failed to update ImageMagick"
		return 1
	fi
	return 0
}

install_imagemagick() {
	if command -v magick &>/dev/null; then
		log_info "ImageMagick is already installed"
		return 2
	fi
	log_info "Installing ImageMagick..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_imagemagick_pkg || return 1
	log_success "ImageMagick installed"
	return 0
}

uninstall_imagemagick() {
	if ! command -v magick &>/dev/null; then
		log_info "ImageMagick is not installed"
		return 2
	fi
	log_info "Uninstalling ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_imagemagick_pkg || return 1
	log_success "ImageMagick uninstalled"
	return 0
}

update_imagemagick() {
	log_info "Updating ImageMagick..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_imagemagick_pkg || return 1
	log_success "ImageMagick updated"
	return 0
}

reinstall_imagemagick() {
	uninstall_imagemagick
	install_imagemagick
}
