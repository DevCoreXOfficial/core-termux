#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

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
  loading "Updating ImageMagick" _do_imagemagick_update
}

_do_imagemagick_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade imagemagick -y &>>"$LOG_FILE"
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
	_check_update_needed "ImageMagick" "$(_get_installed_pkg_version imagemagick "ImageMagick")" "$(_get_remote_pkg_version imagemagick)" _update_imagemagick_pkg
}

reinstall_imagemagick() {
	uninstall_imagemagick
	install_imagemagick
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_imagemagick; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_imagemagick; fi
if [[ "${1:-}" == "update" ]]; then update_imagemagick; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_imagemagick; fi
