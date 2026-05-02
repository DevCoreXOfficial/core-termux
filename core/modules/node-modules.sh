#!/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/fix/localtunnel"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

install_node() {
	separator
	box "Installing Node.js Modules"
	separator
	echo

	log_info "Installing Node.js global modules..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing npm global packages" _install_node_wrapper; then
		log_success "Node.js global modules installed"
		echo
		list_item "TypeScript"
		list_item "NestJS CLI"
		list_item "Prettier"
		list_item "Live Server"
		list_item "Localtunnel"
		list_item "Vercel CLI"
		list_item "Markserv"
		list_item "PSQL Format"
		list_item "NPM Check Updates"
		list_item "Ngrok"
		echo
		separator
		log_success "Node.js modules installation completed"
		separator
		echo
	else
		log_error "Failed to install Node.js global modules"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

_install_node_wrapper() {
	import "@/tools/node/all"
	install_all_node_packages
}

uninstall_node() {
	separator
	box "Uninstalling Node.js Modules"
	separator
	echo

	log_info "Uninstalling Node.js global modules..."

	if loading "Uninstalling npm global packages" _uninstall_node_wrapper; then
		log_success "Node.js global modules uninstalled"
		echo
		separator
		log_success "Node.js modules uninstallation completed"
		separator
		echo
		return 0
	else
		log_error "Failed to uninstall Node.js global modules"
		return 1
	fi
}

_uninstall_node_wrapper() {
	import "@/tools/node/all"
	uninstall_all_node_packages
}

update_node() {
	separator
	box "Updating Node.js Modules"
	separator
	echo

	log_info "Updating Node.js global modules..."

	if loading "Updating npm global packages" _update_node_wrapper; then
		log_success "Node.js global modules updated"
		echo
		separator
		log_success "Node.js modules update completed"
		separator
		echo
		return 0
	else
		log_error "Failed to update Node.js global modules"
		return 1
	fi
}

_update_node_wrapper() {
	import "@/tools/node/all"
	update_all_node_packages
}