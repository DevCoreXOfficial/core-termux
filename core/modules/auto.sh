#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_auto.log"

install_auto() {
	separator
	box "Installing Automation Tools"
	separator
	echo

	log_info "Installing Automation Tools..."
	echo
	mkdir -p "$(dirname "$LOG_FILE")"

	_install_auto_wrapper
	log_success "Automation Tools installed successfully"
	separator
	echo
	list_item "n8n"
	echo
}

_install_auto_wrapper() {
	import "@/tools/auto/all"
	install_all_auto_tools
}

uninstall_auto() {
	if ! command -v n8n &>/dev/null; then
		log_info "Automation Tools are not installed"
		return 0
	fi
	separator
	box "Uninstalling Automation Tools"
	separator
	echo

	log_info "Uninstalling Automation Tools..."

	_uninstall_auto_wrapper
	log_success "Automation Tools uninstalled"
}

_uninstall_auto_wrapper() {
	import "@/tools/auto/all"
	uninstall_all_auto_tools
}

update_auto() {
	separator
	box "Updating Automation Tools"
	separator
	echo

	log_info "Updating Automation Tools..."

	_update_auto_wrapper
	log_success "Automation Tools updated"
}

_update_auto_wrapper() {
  import "@/tools/auto/all"
  update_all_auto_tools
}

reinstall_auto() {
  separator
  box "Reinstalling Automation Tools"
  separator
  echo

  log_info "Reinstalling Automation Tools..."
  echo
  mkdir -p "$(dirname "$LOG_FILE")"

  _reinstall_auto_wrapper
  log_success "Automation Tools reinstalled successfully"
  separator
  echo
  list_item "n8n"
  echo
}

_reinstall_auto_wrapper() {
  import "@/tools/auto/all"
  reinstall_all_auto_tools
}