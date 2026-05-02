#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

UI_COMPONENTS=(
	"font"
	"extra-keys"
	"cursor"
)

source "$(dirname "$BASH_SOURCE")/font.sh"
source "$(dirname "$BASH_SOURCE")/extra-keys.sh"
source "$(dirname "$BASH_SOURCE")/cursor.sh"

install_all_ui_components() {
	local installed_count=0
	local failed_count=0

	for tool in "${UI_COMPONENTS[@]}"; do
		case "$tool" in
		font)
			if install_font; then ((installed_count++)); else ((failed_count++)); fi
			;;
		extra-keys)
			if install_extra_keys; then ((installed_count++)); else ((failed_count++)); fi
			;;
		cursor)
			if install_cursor; then ((installed_count++)); else ((failed_count++)); fi
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
			if uninstall_font; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		extra-keys)
			if uninstall_extra_keys; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		cursor)
			if uninstall_cursor; then ((uninstalled_count++)); else ((failed_count++)); fi
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
			if update_font; then ((updated_count++)); else ((failed_count++)); fi
			;;
		extra-keys)
			if update_extra_keys; then ((updated_count++)); else ((failed_count++)); fi
			;;
		cursor)
			if update_cursor; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}