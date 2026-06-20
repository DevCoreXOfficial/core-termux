#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_automation.log"

install_automation() {
	separator
	box "Installing Automation Tools"
	separator
	echo

	log_info "Installing Automation Tools..."
	echo
	mkdir -p "$(dirname "$LOG_FILE")"

	_install_automation_wrapper
	log_success "Automation Tools installed successfully"
	separator
	echo
	list_item "n8n"
	echo
}

_install_automation_wrapper() {
	import "@/tools/automation/all"
	install_all_automation_tools
}

uninstall_automation() {
	separator
	box "Uninstalling Automation Tools"
	separator
	echo

	log_info "Uninstalling Automation Tools..."

	_uninstall_automation_wrapper
	log_success "Automation Tools uninstalled"
}

_uninstall_automation_wrapper() {
	import "@/tools/automation/all"
	uninstall_all_automation_tools
}

update_automation() {
	separator
	box "Updating Automation Tools"
	separator
	echo

	log_info "Updating Automation Tools..."

	_update_automation_wrapper
	log_success "Automation Tools updated"
}

_update_automation_wrapper() {
  import "@/tools/automation/all"
  update_all_automation_tools
}

reinstall_automation() {
  separator
  box "Reinstalling Automation Tools"
  separator
  echo

  log_info "Reinstalling Automation Tools..."
  echo
  mkdir -p "$(dirname "$LOG_FILE")"

  _reinstall_automation_wrapper
  log_success "Automation Tools reinstalled successfully"
  separator
  echo
  list_item "n8n"
  echo
}

_reinstall_automation_wrapper() {
  import "@/tools/automation/all"
  reinstall_all_automation_tools
}