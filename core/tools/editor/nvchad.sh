#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVCHAD_REPO="https://github.com/DevCoreXOfficial/nvchad-termux.git"
NVCHAD_DIR="$HOME/.cache/core-termux/nvchad-termux"

_install_nvchad_prereqs() {
	if dpkg -s neovim 2>/dev/null | grep -q "Status: install ok installed" && command -v git &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install git neovim nodejs-lts python perl curl wget lua-language-server ripgrep stylua tree-sitter -y &>>"$LOG_FILE"
}

install_nvchad() {
	if [[ -d "$HOME/.config/nvim" ]]; then
		log_info "NvChad ${D_GREEN}already installed${NC}"
		return 0
	fi

	_install_nvchad_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"

	rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
	if git clone "$NVCHAD_REPO" "$NVCHAD_DIR" &>>"$LOG_FILE"; then
		cp -r "$NVCHAD_DIR/nvim" ~/.config/ &>>"$LOG_FILE"
		nvim --headless "+Lazy! sync" +qa &>>"$LOG_FILE"
		nvim --headless "+Lazy! clean nvim-treesitter" +qa &>>"$LOG_FILE"
		nvim --headless "+Lazy! install nvim-treesitter" +qa &>>"$LOG_FILE"
		log_success "NvChad installed"
		return 0
	else
		log_error "Failed to install NvChad"
		return 1
	fi
}

uninstall_nvchad() {
	log_info "Uninstalling NvChad..."

	if [[ -d "$HOME/.config/nvim" ]]; then
		rm -rf ~/.config/nvim &>>"$LOG_FILE"
		rm -rf ~/.local/state/nvim &>>"$LOG_FILE"
		rm -rf ~/.local/share/nvim &>>"$LOG_FILE"
		rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
		log_success "NvChad uninstalled"
	else
		log_warn "NvChad not installed"
	fi
}

update_nvchad() {
	log_info "Updating NvChad..."
	mkdir -p "$(dirname "$LOG_FILE")"

	rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
	if git clone "$NVCHAD_REPO" "$NVCHAD_DIR" &>>"$LOG_FILE"; then
		cp -r "$NVCHAD_DIR/nvim" ~/.config/ &>>"$LOG_FILE"
		log_success "NvChad updated"
		return 0
	else
		log_error "Failed to update NvChad"
		return 1
	fi
}