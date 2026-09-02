#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

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

	separator
	box_large "Installing Font"
	separator
	echo

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

	separator
	box_large "Uninstalling Font"
	separator
	echo

	log_info "Uninstalling Meslo Nerd Font..."
	loading "Uninstalling Meslo Nerd Font" _uninstall_font_impl
}

_update_font_impl() {
	install_font
}

update_font() {
  _update_font_impl
}

reinstall_font() {
	uninstall_font
	install_font
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_font; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_font; fi
if [[ "${1:-}" == "update" ]]; then update_font; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_font; fi
