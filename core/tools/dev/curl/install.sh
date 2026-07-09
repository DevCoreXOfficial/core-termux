#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_curl_pkg() {
	loading "Installing Curl" _install_curl_pkg_impl
}

_install_curl_pkg_impl() {
	if ! yes | pkg install curl &>>"$LOG_FILE"; then
		log_error "Failed to install Curl"
		return 1
	fi
	return 0
}

_uninstall_curl_pkg() {
	loading "Uninstalling Curl" _uninstall_curl_pkg_impl
}

_uninstall_curl_pkg_impl() {
	if ! pkg uninstall curl -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Curl"
		return 1
	fi
	return 0
}

_update_curl_pkg() {
  loading "Updating Curl" _do_curl_update
}

_do_curl_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade curl -y &>>"$LOG_FILE"
}

install_curl() {
	if command -v curl &>/dev/null; then
		log_info "Curl is already installed"
		return 2
	fi
	log_info "Installing Curl..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_curl_pkg || return 1
	log_success "Curl installed"
	return 0
}

uninstall_curl() {
	if ! command -v curl &>/dev/null; then
		log_info "Curl is not installed"
		return 2
	fi
	log_info "Uninstalling Curl..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_curl_pkg || return 1
	log_success "Curl uninstalled"
	return 0
}

update_curl() {
	_check_update_needed "Curl" "$(_get_installed_pkg_version curl "Curl")" "$(_get_remote_pkg_version curl)" _update_curl_pkg
}

reinstall_curl() {
	uninstall_curl
	install_curl
}
