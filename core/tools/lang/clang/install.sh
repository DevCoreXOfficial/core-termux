#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_clang_pkg() {
	loading "Installing C/C++ (Clang)" _install_clang_pkg_impl
}

_install_clang_pkg_impl() {
	if ! yes | pkg install clang &>>"$LOG_FILE"; then
		log_error "Failed to install C/C++ (Clang)"
		return 1
	fi
	return 0
}

install_clang() {
	if command -v clang &>/dev/null; then
		log_info "C/C++ (Clang) is already installed"
		return 2
	fi
	log_info "Installing C/C++ (Clang)..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_clang_pkg || return 1
	log_success "C/C++ (Clang) installed"
	return 0
}

_uninstall_clang_pkg() {
	loading "Uninstalling C/C++ (Clang)" _uninstall_clang_pkg_impl
}

_uninstall_clang_pkg_impl() {
	if ! pkg uninstall clang -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall C/C++ (clang)"
		return 1
	fi
	return 0
}

uninstall_clang() {
	if ! command -v clang &>/dev/null; then
		log_info "C/C++ (Clang) is not installed"
		return 2
	fi
	log_info "Uninstalling C/C++ (Clang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_clang_pkg || return 1
	log_success "C/C++ (clang) uninstalled"
	return 0
}

_update_clang_pkg() {
  loading "Updating C/C++ (Clang)" _do_clang_update
}

_do_clang_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade clang -y &>>"$LOG_FILE"
}

update_clang() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "C/C++ (Clang)" "$(_get_installed_pkg_version clang "C/C++ (Clang)")" "$(_get_remote_pkg_version clang)" _update_clang_pkg
}

reinstall_clang() {
	uninstall_clang
	install_clang
}
