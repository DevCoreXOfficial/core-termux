#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_editor.log"

EDITOR_COMPONENTS=(
	"neovim"
	"nvchad"
)

source "$(dirname "$BASH_SOURCE")/neovim/install.sh"
source "$(dirname "$BASH_SOURCE")/nvchad/install.sh"

install_all_editor_components() {
	local installed_count=0
	local failed_count=0

	for tool in "${EDITOR_COMPONENTS[@]}"; do
		case "$tool" in
		neovim)
			if loading "Installing Neovim" install_neovim; then ((installed_count++)); else ((failed_count++)); fi
			;;
		nvchad)
			if loading "Installing NvChad" install_nvchad; then ((installed_count++)); else ((failed_count++)); fi
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
			if loading "Uninstalling Neovim" uninstall_neovim; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		nvchad)
			if loading "Uninstalling NvChad" uninstall_nvchad; then ((uninstalled_count++)); else ((failed_count++)); fi
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
      if loading "Updating Neovim" update_neovim; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    nvchad)
      if loading "Updating NvChad" update_nvchad; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_editor_components() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${EDITOR_COMPONENTS[@]}"; do
    case "$tool" in
    neovim)
      if loading "Reinstalling Neovim" reinstall_neovim; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    nvchad)
      if loading "Reinstalling NvChad" reinstall_nvchad; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}