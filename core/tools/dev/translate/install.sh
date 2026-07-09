#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_translate_pkg() {
	loading "Installing Translate Shell" _install_translate_pkg_impl
}

_install_translate_pkg_impl() {
	if ! yes | pkg install translate-shell &>>"$LOG_FILE"; then
		log_error "Failed to install Translate Shell"
		return 1
	fi
	return 0
}

_uninstall_translate_pkg() {
	loading "Uninstalling Translate Shell" _uninstall_translate_pkg_impl
}

_uninstall_translate_pkg_impl() {
	if ! pkg uninstall translate-shell -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Translate Shell"
		return 1
	fi
	return 0
}

_update_translate_pkg() {
  loading "Updating Translate Shell" _do_translate_update
}

_do_translate_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade translate-shell -y &>>"$LOG_FILE"
}

install_translate() {
	if command -v trans &>/dev/null; then
		log_info "Translate Shell is already installed"
		return 2
	fi
	log_info "Installing Translate Shell..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_translate_pkg || return 1
	log_success "Translate Shell installed"
	return 0
}

uninstall_translate() {
	if ! command -v trans &>/dev/null; then
		log_info "Translate Shell is not installed"
		return 2
	fi
	log_info "Uninstalling Translate Shell..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_translate_pkg || return 1
	log_success "Translate Shell uninstalled"
	return 0
}

update_translate() {
	_check_update_needed "Translate Shell" "$(_get_installed_pkg_version translate-shell "Translate Shell")" "$(_get_remote_pkg_version translate-shell)" _update_translate_pkg
}

reinstall_translate() {
	uninstall_translate
	install_translate
}
