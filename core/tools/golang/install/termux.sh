#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_lang.log"

_install_golang_pkg() {
	loading "Installing Go (Golang)" _install_golang_pkg_impl
}

_install_golang_pkg_impl() {
	if ! yes | pkg install golang &>>"$LOG_FILE"; then
		log_error "Failed to install Go (Golang)"
		return 1
	fi
	return 0
}

install_golang() {
	if command -v go &>/dev/null; then
		log_info "Go (Golang) is already installed"
		return 2
	fi
	log_info "Installing Go (Golang)..."

	mkdir -p "$(dirname "$LOG_FILE")"
	_install_golang_pkg || return 1
	log_success "Go (Golang) installed"
	return 0
}

_uninstall_golang_pkg() {
	loading "Uninstalling Go (Golang)" _uninstall_golang_pkg_impl
}

_uninstall_golang_pkg_impl() {
	if ! pkg uninstall golang -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Go (golang)"
		return 1
	fi
	return 0
}

uninstall_golang() {
	if ! command -v go &>/dev/null; then
		log_info "Go (Golang) is not installed"
		return 2
	fi

	confirm_remove_configs "Go" \
		"$HOME/.cache/go" \
		"$HOME/.cache/go-build"

	log_info "Uninstalling Go (Golang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	_uninstall_golang_pkg || return 1
	log_success "Go (golang) uninstalled"
	return 0
}

_update_golang_pkg() {
  loading "Updating Go (Golang)" _do_golang_update
}

_do_golang_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade golang -y &>>"$LOG_FILE"
}

update_golang() {
  mkdir -p "$(dirname "$LOG_FILE")"
  _check_update_needed "Go (golang)" "$(_get_installed_version go version Go)" "$(_get_remote_pkg_version golang)" _update_golang_pkg
}

reinstall_golang() {
	uninstall_golang
	install_golang
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_golang; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_golang; fi
if [[ "${1:-}" == "update" ]]; then update_golang; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_golang; fi
