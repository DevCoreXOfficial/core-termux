#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_automation.log"

AUTOMATION_TOOLS=(
	"n8n"
)

source "$(dirname "$BASH_SOURCE")/n8n.sh"

install_all_automation_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${AUTOMATION_TOOLS[@]}"; do
		case "$tool" in
		n8n)
			if install_n8n; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_automation_tools() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${AUTOMATION_TOOLS[@]}"; do
		case "$tool" in
		n8n)
			if uninstall_n8n; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_automation_tools() {
	local updated_count=0
	local failed_count=0

	for tool in "${AUTOMATION_TOOLS[@]}"; do
		case "$tool" in
		n8n)
			if update_n8n; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}