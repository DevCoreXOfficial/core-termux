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
			loading "Installing Neovim" install_neovim
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		nvchad)
			loading "Installing NvChad" install_nvchad
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
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
			loading "Uninstalling Neovim" uninstall_neovim
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		nvchad)
			loading "Uninstalling NvChad" uninstall_nvchad
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
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
      loading "Updating Neovim" update_neovim
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    nvchad)
      loading "Updating NvChad" update_nvchad
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
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
      loading "Reinstalling Neovim" reinstall_neovim
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    nvchad)
      loading "Reinstalling NvChad" reinstall_nvchad
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}