#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_perl_pkg() {
	loading "Installing Perl" _install_perl_pkg_impl
}

_install_perl_pkg_impl() {
	if ! yes | pkg install perl &>>"$LOG_FILE"; then
		log_error "Failed to install Perl"
		return 1
	fi
	return 0
}

install_perl() {
	if command -v perl &>/dev/null; then
		log_info "Perl is already installed"
		return 2
	fi
	log_info "Installing Perl..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_perl_pkg || return 1
	log_success "Perl installed"
	return 0
}

_uninstall_perl_pkg() {
	loading "Uninstalling Perl" _uninstall_perl_pkg_impl
}

_uninstall_perl_pkg_impl() {
	if ! pkg uninstall perl -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Perl"
		return 1
	fi
	return 0
}

uninstall_perl() {
	if ! command -v perl &>/dev/null; then
		log_info "Perl is not installed"
		return 2
	fi
	log_info "Uninstalling Perl..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_perl_pkg || return 1
	log_success "Perl uninstalled"
	return 0
}

_update_perl_pkg() {
  loading "Updating Perl" _do_perl_update
}

_do_perl_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade perl -y &>>"$LOG_FILE"
}

update_perl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Perl" "$(_get_installed_pkg_version perl "Perl")" "$(_get_remote_pkg_version perl)" _update_perl_pkg
}

reinstall_perl() {
	uninstall_perl
	install_perl
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_perl; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_perl; fi
if [[ "${1:-}" == "update" ]]; then update_perl; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_perl; fi
