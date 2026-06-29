#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_html2text_pkg() {
	loading "Installing html2text" _install_html2text_pkg_impl
}

_install_html2text_pkg_impl() {
	if ! yes | pkg install html2text &>>"$LOG_FILE"; then
		log_error "Failed to install html2text"
		return 1
	fi
	return 0
}

_uninstall_html2text_pkg() {
	loading "Uninstalling html2text" _uninstall_html2text_pkg_impl
}

_uninstall_html2text_pkg_impl() {
	if ! pkg uninstall html2text -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall html2text"
		return 1
	fi
	return 0
}

_update_html2text_pkg() {
	loading "Updating html2text" _update_html2text_pkg_impl
}

_update_html2text_pkg_impl() {
	if ! pkg upgrade html2text -y &>>"$LOG_FILE"; then
		log_error "Failed to update html2text"
		return 1
	fi
	return 0
}

install_html2text() {
	if command -v html2text &>/dev/null; then
		log_info "HTML2Text is already installed"
		return 2
	fi
	log_info "Installing html2text..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_html2text_pkg || return 1
	log_success "html2text installed"
	return 0
}

uninstall_html2text() {
	if ! command -v html2text &>/dev/null; then
		log_info "HTML2Text is not installed"
		return 2
	fi
	log_info "Uninstalling html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_html2text_pkg || return 1
	log_success "html2text uninstalled"
	return 0
}

update_html2text() {
	log_info "Updating html2text..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_html2text_pkg || return 1
	log_success "html2text updated"
	return 0
}

reinstall_html2text() {
	uninstall_html2text
	install_html2text
}
