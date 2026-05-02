#!/bin/bash

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

	if loading "Installing Automation Tools" _install_automation_wrapper; then
		log_success "Automation Tools installed successfully"
		separator
		echo
		list_item "n8n"
		echo
	else
		log_error "Failed to install Automation Tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
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

	if loading "Uninstalling Automation Tools" _uninstall_automation_wrapper; then
		log_success "Automation Tools uninstalled"
	else
		log_error "Failed to uninstall Automation Tools"
		return 1
	fi
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

	if loading "Updating Automation Tools" _update_automation_wrapper; then
		log_success "Automation Tools updated"
	else
		log_error "Failed to update Automation Tools"
		return 1
	fi
}

_update_automation_wrapper() {
	import "@/tools/automation/all"
	update_all_automation_tools
}