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
			if loading "Installing Meslo Nerd Font" install_font; then ((installed_count++)); else ((failed_count++)); fi
			;;
		extra-keys)
			if loading "Installing Extra Keys" install_extra_keys; then ((installed_count++)); else ((failed_count++)); fi
			;;
		cursor)
			if loading "Installing Cursor Color" install_cursor; then ((installed_count++)); else ((failed_count++)); fi
			;;
		banner)
			if loading "Installing Core-Termux Banner" install_banner; then ((installed_count++)); else ((failed_count++)); fi
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
			if loading "Uninstalling Meslo Nerd Font" uninstall_font; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		extra-keys)
			if loading "Uninstalling Extra Keys" uninstall_extra_keys; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		cursor)
			if loading "Uninstalling Cursor Color" uninstall_cursor; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		banner)
			if loading "Uninstalling Core-Termux Banner" uninstall_banner; then ((uninstalled_count++)); else ((failed_count++)); fi
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
      if loading "Updating Meslo Nerd Font" update_font; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    extra-keys)
      if loading "Updating Extra Keys" update_extra_keys; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    cursor)
      if loading "Updating Cursor Color" update_cursor; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    banner)
      if loading "Updating Core-Termux Banner" update_banner; then ((updated_count++)); else ((failed_count++)); fi
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
      if loading "Reinstalling Meslo Nerd Font" reinstall_font; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    extra-keys)
      if loading "Reinstalling Extra Keys" reinstall_extra_keys; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    cursor)
      if loading "Reinstalling Cursor Color" reinstall_cursor; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    banner)
      if loading "Reinstalling Core-Termux Banner" reinstall_banner; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}