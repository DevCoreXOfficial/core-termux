#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_editor.log"

install_editor() {
	separator
	box "Installing Code Editor"
	separator
	echo

	log_info "Installing Neovim and dependencies..."

	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Installing Neovim dependencies" _install_editor_deps
	log_success "Neovim dependencies installed"

	_install_editor_wrapper
	log_success "Code editor installed successfully"
	separator
	echo
	list_item "Neovim (code editor)"
	list_item "NvChad (framework for Neovim)"
	list_item "GitHub Copilot (AI code assistant)"
	list_item "CodeCompanion (AI chat assistant)"
	echo
}

_install_editor_deps() {
	yes | pkg install git neovim nodejs-lts python perl curl wget lua-language-server ripgrep stylua tree-sitter &>"$LOG_FILE"
}

_install_editor_wrapper() {
	import "@/tools/editor/all"
	install_all_editor_components
}

uninstall_editor() {
	if ! command -v nvim &>/dev/null; then
		log_info "Code Editor is not installed"
		return 0
	fi
	separator
	box "Uninstalling Code Editor"
	separator
	echo

	log_info "Uninstalling Neovim configuration..."

	_uninstall_editor_wrapper
	log_success "Code editor uninstalled"
}

_uninstall_editor_wrapper() {
	import "@/tools/editor/all"
	uninstall_all_editor_components
}

update_editor() {
	separator
	box "Updating Code Editor"
	separator
	echo

	log_info "Updating NvChad configuration..."

	_update_editor_wrapper
	log_success "Code editor updated"
}

_update_editor_wrapper() {
  import "@/tools/editor/all"
  update_all_editor_components
}

reinstall_editor() {
  separator
  box "Reinstalling Code Editor"
  separator
  echo

  log_info "Reinstalling Neovim and dependencies..."

  _reinstall_editor_wrapper
  log_success "Code editor reinstalled successfully"
  separator
  echo
  list_item "Neovim (code editor)"
  list_item "NvChad (framework for Neovim)"
  list_item "GitHub Copilot (AI code assistant)"
  list_item "CodeCompanion (AI chat assistant)"
  echo
}

_reinstall_editor_wrapper() {
  import "@/tools/editor/all"
  reinstall_all_editor_components
}