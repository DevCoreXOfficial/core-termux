#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

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

	separator
	box_large "Installing Rust"
	separator
	echo

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

	separator
	box_large "Uninstalling Rust"
	separator
	echo

	confirm_remove_configs "Rust" \
		"$HOME/.cargo"

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

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_rust; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_rust; fi
if [[ "${1:-}" == "update" ]]; then update_rust; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_rust; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version cargo; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_pkg_version rust; fi
