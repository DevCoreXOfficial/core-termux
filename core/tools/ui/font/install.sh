#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"
TERMUX_ASSETS_DIR="$(dirname "$CORE_PATH")/assets"

_install_font_impl() {
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

install_font() {
	if [[ -f "$TERMUX_DIR/font.ttf" ]]; then
		log_info "Meslo Nerd Font already installed"
		return 0
	fi
	log_info "Installing Meslo Nerd Font..."
	loading "Installing Meslo Nerd Font" _install_font_impl
}

_uninstall_font_impl() {
	if [[ -f "$TERMUX_DIR/font.ttf" ]]; then
		rm "$TERMUX_DIR/font.ttf"
		log_success "Meslo Nerd Font uninstalled"
	else
		log_warn "Meslo Nerd Font not installed"
	fi
}

uninstall_font() {
	if [[ ! -f "$TERMUX_DIR/font.ttf" ]]; then
		log_info "Meslo Nerd Font is not installed"
		return 2
	fi
	log_info "Uninstalling Meslo Nerd Font..."
	loading "Uninstalling Meslo Nerd Font" _uninstall_font_impl
}

_update_font_impl() {
	install_font
}

update_font() {
	log_info "Updating Meslo Nerd Font..."
	loading "Updating Meslo Nerd Font" _update_font_impl
}

reinstall_font() {
	uninstall_font
	install_font
}
