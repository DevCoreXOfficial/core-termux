#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_cloudflared_pkg() {
	loading "Installing Cloudflared" _install_cloudflared_pkg_impl
}

_install_cloudflared_pkg_impl() {
	if ! yes | pkg install cloudflared &>>"$LOG_FILE"; then
		log_error "Failed to install Cloudflared"
		return 1
	fi
	return 0
}

_uninstall_cloudflared_pkg() {
	loading "Uninstalling Cloudflared" _uninstall_cloudflared_pkg_impl
}

_uninstall_cloudflared_pkg_impl() {
	if ! pkg uninstall cloudflared -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Cloudflared"
		return 1
	fi
	return 0
}

_update_cloudflared_pkg() {
  loading "Updating Cloudflared" _do_cloudflared_update
}

_do_cloudflared_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade cloudflared -y &>>"$LOG_FILE"
}

install_cloudflared() {
	if command -v cloudflared &>/dev/null; then
		log_info "Cloudflared is already installed"
		return 2
	fi

	separator
	box_large "Installing Cloudflared"
	separator
	echo

	log_info "Installing Cloudflared..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_cloudflared_pkg || return 1
	log_success "Cloudflared installed"
	return 0
}

uninstall_cloudflared() {
	if ! command -v cloudflared &>/dev/null; then
		log_info "Cloudflared is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Cloudflared"
	separator
	echo

	log_info "Uninstalling Cloudflared..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_cloudflared_pkg || return 1
	log_success "Cloudflared uninstalled"
	return 0
}

update_cloudflared() {
	_check_update_needed "Cloudflared" "$(_get_installed_pkg_version cloudflared "Cloudflared")" "$(_get_remote_pkg_version cloudflared)" _update_cloudflared_pkg
}

reinstall_cloudflared() {
	uninstall_cloudflared
	install_cloudflared
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_cloudflared; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_cloudflared; fi
if [[ "${1:-}" == "update" ]]; then update_cloudflared; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_cloudflared; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version cloudflared; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version cloudflare/cloudflared; fi
