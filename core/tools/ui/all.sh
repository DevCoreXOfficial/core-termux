#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

UI_COMPONENTS=(
	"font"
	"extra-keys"
	"cursor"
	"banner"
)

source "$(dirname "$BASH_SOURCE")/font/install.sh"
source "$(dirname "$BASH_SOURCE")/extra-keys/install.sh"
source "$(dirname "$BASH_SOURCE")/cursor/install.sh"
source "$(dirname "$BASH_SOURCE")/banner/install.sh"

install_all_ui_components() {
	local installed_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			loading "Installing Meslo Nerd Font" install_font
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		extra-keys)
			loading "Installing Extra Keys" install_extra_keys
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		cursor)
			loading "Installing Cursor Color" install_cursor
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		banner)
			loading "Installing Core-Termux Banner" install_banner
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

uninstall_all_ui_components() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			loading "Uninstalling Meslo Nerd Font" uninstall_font
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		extra-keys)
			loading "Uninstalling Extra Keys" uninstall_extra_keys
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		cursor)
			loading "Uninstalling Cursor Color" uninstall_cursor
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		banner)
			loading "Uninstalling Core-Termux Banner" uninstall_banner
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		esac
	done

	return 0
}

update_all_ui_components() {
  local updated_count=0
  local failed_count=0

  for tool in "${UI_COMPONENTS[@]}"; do
    case "$tool" in
    font)
      loading "Updating Meslo Nerd Font" update_font
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    extra-keys)
      loading "Updating Extra Keys" update_extra_keys
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    cursor)
      loading "Updating Cursor Color" update_cursor
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    banner)
      loading "Updating Core-Termux Banner" update_banner
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_ui_components() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${UI_COMPONENTS[@]}"; do
    case "$tool" in
    font)
      loading "Reinstalling Meslo Nerd Font" reinstall_font
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    extra-keys)
      loading "Reinstalling Extra Keys" reinstall_extra_keys
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    cursor)
      loading "Reinstalling Cursor Color" reinstall_cursor
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    banner)
      loading "Reinstalling Core-Termux Banner" reinstall_banner
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}