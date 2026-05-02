#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"
TERMUX_ASSETS_DIR="$(dirname "$CORE_PATH")/assets"

install_font() {
	if [[ -f "$TERMUX_DIR/font.ttf" ]]; then
		log_info "Meslo Nerd Font ${D_GREEN}already installed${NC}"
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"

	local font_source="$TERMUX_ASSETS_DIR/fonts/font.ttf"

	if [[ -f "$font_source" ]]; then
		cp "$font_source" "$TERMUX_DIR/font.ttf"
		log_success "Meslo Nerd Font installed"
		return 0
	else
		log_error "Font file not found: $font_source"
		return 1
	fi
}

uninstall_font() {
	log_info "Uninstalling Meslo Nerd Font..."

	if [[ -f "$TERMUX_DIR/font.ttf" ]]; then
		rm "$TERMUX_DIR/font.ttf"
		log_success "Meslo Nerd Font uninstalled"
	else
		log_warn "Meslo Nerd Font not installed"
	fi
}

update_font() {
	log_info "Updating Meslo Nerd Font..."
	install_font
}