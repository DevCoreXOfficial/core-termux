#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

TERMUX_DIR="$HOME/.termux"
TERMUX_ASSETS_DIR="$(dirname "$CORE_PATH")/assets"
LOG_FILE="$CORE_CACHE/install_ui.log"

setup_ui() {
	separator
	box "Configuring Termux UI"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if [[ ! -d "$TERMUX_DIR" ]]; then
		mkdir -p "$TERMUX_DIR"
		log_info "Created Termux directory: $TERMUX_DIR"
	fi

	if loading "Configuring UI components" _setup_ui_wrapper; then
		separator
		log_success "Termux UI configuration completed"
		separator
		echo
		list_item "Cursor: Green (#00FF00)"
		list_item "Extra-keys: Custom layout with navigation"
		list_item "Font: Meslo Nerd Font"
		echo
		log_warn "Please restart Termux to apply all changes"
		echo
	else
		log_error "Failed to configure UI"
		return 1
	fi
}

_setup_ui_wrapper() {
	import "@/tools/ui/all"
	install_all_ui_components
}

uninstall_ui() {
	separator
	box "Uninstalling Termux UI Configuration"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Restoring UI defaults" _uninstall_ui_wrapper; then
		echo
		separator
		log_success "Termux UI configuration uninstalled"
		separator
		echo
		log_warn "Please restart Termux to apply changes"
		echo
		return 0
	else
		log_error "Failed to uninstall UI"
		return 1
	fi
}

_uninstall_ui_wrapper() {
	import "@/tools/ui/all"
	uninstall_all_ui_components
}

update_ui() {
	separator
	box "Updating Termux UI Configuration"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Updating UI components" _update_ui_wrapper; then
		echo
		separator
		log_success "Termux UI configuration updated"
		separator
		echo
		return 0
	else
		log_error "Failed to update UI"
		return 1
	fi
}

_update_ui_wrapper() {
	import "@/tools/ui/all"
	update_all_ui_components
}