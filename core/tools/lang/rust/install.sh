#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_rust_pkg() {
	loading "Installing Rust" _install_rust_pkg_impl
}

_install_rust_pkg_impl() {
	if ! yes | pkg install rust &>>"$LOG_FILE"; then
		log_error "Failed to install Rust"
		return 1
	fi
	return 0
}

install_rust() {
	if command -v rust &>/dev/null; then
		log_info "Rust is already installed"
		return 2
	fi
	log_info "Installing Rust..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_rust_pkg || return 1
	log_success "Rust installed"
	return 0
}

_uninstall_rust_pkg() {
	loading "Uninstalling Rust" _uninstall_rust_pkg_impl
}

_uninstall_rust_pkg_impl() {
	if ! pkg uninstall rust -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Rust"
		return 1
	fi
	return 0
}

uninstall_rust() {
	if ! command -v rustc &>/dev/null; then
		log_info "Rust is not installed"
		return 2
	fi
	log_info "Uninstalling Rust..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_rust_pkg || return 1
	log_success "Rust uninstalled"
	return 0
}

_update_rust_pkg() {
  loading "Updating Rust" _do_rust_update
}

_do_rust_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade rust -y &>>"$LOG_FILE"
}

update_rust() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Rust" "$(_get_installed_pkg_version rust "Rust")" "$(_get_remote_pkg_version rust)" _update_rust_pkg
}

reinstall_rust() {
	uninstall_rust
	install_rust
}
