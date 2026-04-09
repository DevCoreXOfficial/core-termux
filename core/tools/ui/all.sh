#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"
TERMUX_ASSETS_DIR="$(dirname "$CORE_PATH")/assets"

# ===== FONT =====
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
	# Font update is same as install
	install_font
}

# ===== EXTRA KEYS =====
install_extra_keys() {
	if [[ -f "$TERMUX_DIR/termux.properties" ]]; then
		log_info "Extra Keys ${D_GREEN}already configured${NC}"
		return 0
	fi

	log_info "Configuring Termux extra-keys..."
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"

	cat >"$TERMUX_DIR/termux.properties" <<'EOF'
terminal-cursor-blink-rate=500

extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]
EOF

	log_success "Extra-keys configured"
	return 0
}

uninstall_extra_keys() {
	log_info "Uninstalling Extra Keys..."

	if [[ -f "$TERMUX_DIR/termux.properties" ]]; then
		rm "$TERMUX_DIR/termux.properties"
		log_success "Extra Keys uninstalled"
	else
		log_warn "Extra Keys not configured"
	fi
}

update_extra_keys() {
	log_info "Updating Extra Keys..."
	install_extra_keys
}

# ===== CURSOR =====
install_cursor() {
	if [[ -f "$TERMUX_DIR/colors.properties" ]]; then
		log_info "Cursor Color ${D_GREEN}already configured${NC}"
		return 0
	fi

	log_info "Configuring cursor color..."
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"

	cat >"$TERMUX_DIR/colors.properties" <<'EOF'
cursor=#00FF00
EOF

	log_success "Cursor color set to #00FF00 (green)"
	return 0
}

uninstall_cursor() {
	log_info "Uninstalling Cursor Color..."

	if [[ -f "$TERMUX_DIR/colors.properties" ]]; then
		rm "$TERMUX_DIR/colors.properties"
		log_success "Cursor Color uninstalled"
	else
		log_warn "Cursor Color not configured"
	fi
}

update_cursor() {
	log_info "Updating Cursor Color..."
	install_cursor
}
