#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
	loading "Updating Tree" _update_tree_pkg_impl
}

_update_tree_pkg_impl() {
	if ! pkg upgrade tree -y &>>"$LOG_FILE"; then
		log_error "Failed to update Tree"
		return 1
	fi
	return 0
}

install_tree() {
	if command -v tree &>/dev/null; then
		log_info "Tree is already installed"
		return 2
	fi
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
	log_info "Uninstalling Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_tree_pkg || return 1
	log_success "Tree uninstalled"
	return 0
}

update_tree() {
	log_info "Updating Tree..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_update_tree_pkg || return 1
	log_success "Tree updated"
	return 0
}

reinstall_tree() {
	uninstall_tree
	install_tree
}
