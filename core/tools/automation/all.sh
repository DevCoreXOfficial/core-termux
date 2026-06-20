#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_automation.log"

AUTOMATION_TOOLS=(
	"n8n"
)

source "$(dirname "$BASH_SOURCE")/n8n/install.sh"

install_all_automation_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${AUTOMATION_TOOLS[@]}"; do
		case "$tool" in
		n8n)
			loading "Installing n8n" install_n8n
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
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
			loading "Uninstalling n8n" uninstall_n8n
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
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
      loading "Updating n8n" update_n8n
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_automation_tools() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${AUTOMATION_TOOLS[@]}"; do
    case "$tool" in
    n8n)
      loading "Reinstalling n8n" reinstall_n8n
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}