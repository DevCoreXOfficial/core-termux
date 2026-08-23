#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_gh_pkg() {
	loading "Installing GitHub CLI" _install_gh_pkg_impl
}

_install_gh_pkg_impl() {
	if ! yes | pkg install gh &>>"$LOG_FILE"; then
		log_error "Failed to install GitHub CLI"
		return 1
	fi
	return 0
}

_uninstall_gh_pkg() {
	loading "Uninstalling GitHub CLI" _uninstall_gh_pkg_impl
}

_uninstall_gh_pkg_impl() {
	if ! pkg uninstall gh -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall GitHub CLI"
		return 1
	fi
	return 0
}

_update_gh_pkg() {
  loading "Updating GitHub CLI" _do_gh_update
}

_do_gh_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade gh -y &>>"$LOG_FILE"
}

install_gh() {
	if command -v gh &>/dev/null; then
		log_info "GitHub CLI is already installed"
		return 2
	fi
	log_info "Installing GitHub CLI..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_gh_pkg || return 1
	log_success "GitHub CLI installed"
	return 0
}

uninstall_gh() {
	if ! command -v gh &>/dev/null; then
		log_info "GitHub CLI is not installed"
		return 2
	fi

	confirm_remove_configs "GitHub CLI" \
		"$HOME/.config/gh" \
		"$HOME/.local/state/gh" \
		"$HOME/.cache/gh"

	log_info "Uninstalling GitHub CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_gh_pkg || return 1
	log_success "GitHub CLI uninstalled"
	return 0
}

update_gh() {
	_check_update_needed "GitHub CLI" "$(_get_installed_pkg_version gh "GitHub CLI")" "$(_get_remote_pkg_version gh)" _update_gh_pkg
}

reinstall_gh() {
	uninstall_gh
	install_gh
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_gh; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_gh; fi
if [[ "${1:-}" == "update" ]]; then update_gh; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_gh; fi
