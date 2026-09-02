#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_dev.log"

_install_tree_pkg() {
	loading "Installing Tree" _install_tree_pkg_impl
}

_install_tree_pkg_impl() {
	if ! yes | pkg install tree &>>"$LOG_FILE"; then
		log_error "Failed to install Tree"
		return 1
	fi
	return 0
}

_uninstall_tree_pkg() {
	loading "Uninstalling Tree" _uninstall_tree_pkg_impl
}

_uninstall_tree_pkg_impl() {
	if ! pkg uninstall tree -y &>>"$LOG_FILE"; then
		log_error "Failed to uninstall Tree"
		return 1
	fi
	return 0
}

_update_tree_pkg() {
  loading "Updating Tree" _do_tree_update
}

_do_tree_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade tree -y &>>"$LOG_FILE"
}

install_tree() {
	if command -v tree &>/dev/null; then
		log_info "Tree is already installed"
		return 2
	fi

	separator
	box_large "Installing Tree"
	separator
	echo

	log_info "Installing Tree..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_tree_pkg || return 1
	log_success "Tree installed"
	return 0
}

uninstall_tree() {
	if ! command -v tree &>/dev/null; then
		log_info "Tree is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Tree"
	separator
	echo

	log_info "Uninstalling Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_tree_pkg || return 1
	log_success "Tree uninstalled"
	return 0
}

update_tree() {
	_check_update_needed "Tree" "$(_get_installed_pkg_version tree "Tree")" "$(_get_remote_pkg_version tree)" _update_tree_pkg
}

reinstall_tree() {
	uninstall_tree
	install_tree
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_tree; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_tree; fi
if [[ "${1:-}" == "update" ]]; then update_tree; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_tree; fi
