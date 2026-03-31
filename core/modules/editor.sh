#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVCHAD_REPO="https://github.com/DevCoreXOfficial/nvchad-termux.git"
NVCHAD_DIR="$HOME/.cache/core-termux/nvchad-termux"

# Instalar editor de código
install_editor() {
	separator
	box "Installing Code Editor"
	separator
	echo

	log_info "Installing Neovim and dependencies..."

	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar prerequisitos
	if loading "Installing Neovim dependencies" _install_editor_deps; then
		log_success "Neovim dependencies installed"
	else
		log_warn "Some dependencies may have failed"
	fi

	# Clonar e instalar NvChad
	if loading "Installing NvChad configuration" _install_nvchad; then
		log_success "Code editor installed successfully"
		separator
		echo
		list_item "Neovim (code editor)"
		list_item "NvChad (framework for Neovim)"
		list_item "GitHub Copilot (AI code assistant)"
		list_item "CodeCompanion (AI chat assistant)"
		echo
	else
		log_error "Failed to install code editor"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar dependencias
_install_editor_deps() {
	pkg install git neovim nodejs-lts python perl curl wget lua-language-server ripgrep stylua tree-sitter -y &>"$LOG_FILE"
}

# Función interna para instalar NvChad
_install_nvchad() {
	rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
	git clone "$NVCHAD_REPO" "$NVCHAD_DIR" &>>"$LOG_FILE"
	cp -r "$NVCHAD_DIR/nvim" ~/.config/ &>>"$LOG_FILE"
  nvim --headless "+Lazy! sync" +qa &>>"$LOG_FILE"
  nvim --headless "+Lazy! clean nvim-treesitter" +qa &>>"$LOG_FILE"
  nvim --headless "+Lazy! install nvim-treesitter" +qa &>>"$LOG_FILE"
}

# Desinstalar editor de código
uninstall_editor() {
	separator
	box "Uninstalling Code Editor"
	separator
	echo

	log_info "Uninstalling Neovim configuration..."

	if loading "Uninstalling NvChad" _uninstall_nvchad; then
		log_success "Code editor uninstalled"
	else
		log_error "Failed to uninstall code editor"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_nvchad() {
	rm -rf ~/.config/nvim &>>"$LOG_FILE"
	rm -rf ~/.local/state/nvim &>>"$LOG_FILE"
	rm -rf ~/.local/share/nvim &>>"$LOG_FILE"
	rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
}

# Actualizar editor de código
update_editor() {
	separator
	box "Updating Code Editor"
	separator
	echo

	log_info "Updating NvChad configuration..."

	if loading "Updating NvChad" _update_nvchad; then
		log_success "Code editor updated"
	else
		log_error "Failed to update code editor"
		return 1
	fi
}

# Función interna para actualizar
_update_nvchad() {
	rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
	git clone "$NVCHAD_REPO" "$NVCHAD_DIR" &>>"$LOG_FILE"
	cp -r "$NVCHAD_DIR/nvim" ~/.config/ &>>"$LOG_FILE"
}
