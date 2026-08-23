#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_fzf_pkg() {
	loading "Installing Fzf" _install_fzf_pkg_impl
}

_install_fzf_pkg_impl() {
	if ! yes | pkg install fzf &>>"$LOG_FILE"; then
		log_error "Failed to install Fzf"
		return 1
	fi
	return 0
}

_uninstall_fzf_pkg() {
	loading "Uninstalling Fzf" _uninstall_fzf_pkg_impl
}

_uninstall_fzf_pkg_impl() {
	if ! pkg uninstall fzf -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Fzf"
		return 1
	fi
	return 0
}

_update_fzf_pkg() {
  loading "Updating Fzf" _do_fzf_update
}

_do_fzf_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade fzf -y &>>"$LOG_FILE"
}

install_fzf() {
	if command -v fzf &>/dev/null; then
		log_info "Fzf is already installed"
		return 2
	fi
	log_info "Installing Fzf..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_fzf_pkg || return 1
	log_success "Fzf installed"
	return 0
}

uninstall_fzf() {
	if ! command -v fzf &>/dev/null; then
		log_info "Fzf is not installed"
		return 2
	fi

	confirm_remove_configs "Fzf" \
		"$HOME/.fzf"

	log_info "Uninstalling Fzf..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_fzf_pkg || return 1
	log_success "Fzf uninstalled"
	return 0
}

update_fzf() {
	_check_update_needed "Fzf" "$(_get_installed_pkg_version fzf "Fzf")" "$(_get_remote_pkg_version fzf)" _update_fzf_pkg
}

reinstall_fzf() {
	uninstall_fzf
	install_fzf
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_fzf; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_fzf; fi
if [[ "${1:-}" == "update" ]]; then update_fzf; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_fzf; fi
