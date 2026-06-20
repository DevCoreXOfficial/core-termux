#!/data/data/com.termux/files/usr/bin/bash

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

	_setup_ui_wrapper
	separator
	log_success "Termux UI configuration completed"
	separator
	echo
	list_item "Cursor: Green (#00FF00)"
	list_item "Extra-keys: Custom layout with navigation"
	list_item "Font: Meslo Nerd Font"
	list_item "Banner: Core-Termux startup banner"
	echo
	log_warn "Please restart Termux to apply all changes"
	echo
}

_setup_ui_wrapper() {
	import "@/tools/ui/all"
	install_all_ui_components
}

uninstall_ui() {
	if [[ ! -d "$TERMUX_DIR" ]]; then
		log_info "Termux UI Configuration is not installed"
		return 0
	fi
	separator
	box "Uninstalling Termux UI Configuration"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	_uninstall_ui_wrapper
	echo
	separator
	log_success "Termux UI configuration uninstalled"
	separator
	echo
	log_warn "Please restart Termux to apply changes"
	echo
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

	_update_ui_wrapper
	echo
	separator
	log_success "Termux UI configuration updated"
	separator
	echo
}

_update_ui_wrapper() {
  import "@/tools/ui/all"
  update_all_ui_components
}

reinstall_ui() {
  separator
  box "Reinstalling Termux UI Configuration"
  separator
  echo

  mkdir -p "$(dirname "$LOG_FILE")"

  _reinstall_ui_wrapper
  separator
  log_success "Termux UI configuration reinstalled"
  separator
  echo
  list_item "Cursor: Green (#00FF00)"
  list_item "Extra-keys: Custom layout with navigation"
  list_item "Font: Meslo Nerd Font"
  list_item "Banner: Core-Termux startup banner"
  echo
  log_warn "Please restart Termux to apply all changes"
  echo
}

_reinstall_ui_wrapper() {
  import "@/tools/ui/all"
  reinstall_all_ui_components
}