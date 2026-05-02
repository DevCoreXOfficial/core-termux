#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_editor.log"

EDITOR_COMPONENTS=(
	"neovim"
	"nvchad"
)

source "$(dirname "$BASH_SOURCE")/neovim.sh"
source "$(dirname "$BASH_SOURCE")/nvchad.sh"

install_all_editor_components() {
	local installed_count=0
	local failed_count=0

	for tool in "${EDITOR_COMPONENTS[@]}"; do
		case "$tool" in
		neovim)
			if install_neovim; then ((installed_count++)); else ((failed_count++)); fi
			;;
		nvchad)
			if install_nvchad; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_editor_components() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${EDITOR_COMPONENTS[@]}"; do
		case "$tool" in
		neovim)
			if uninstall_neovim; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		nvchad)
			if uninstall_nvchad; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_editor_components() {
	local updated_count=0
	local failed_count=0

	for tool in "${EDITOR_COMPONENTS[@]}"; do
		case "$tool" in
		neovim)
			if update_neovim; then ((updated_count++)); else ((failed_count++)); fi
			;;
		nvchad)
			if update_nvchad; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}