#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

_install_cursor_impl() {
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"

	cat >"$TERMUX_DIR/colors.properties" <<'EOF'
cursor=#00FF00
EOF

	log_success "Cursor color set to #00FF00 (green)"
	return 0
}

install_cursor() {
	if [[ -f "$TERMUX_DIR/colors.properties" ]]; then
		log_info "Cursor Color already configured"
		return 0
	fi
	log_info "Installing Cursor Color..."
	loading "Installing Cursor Color" _install_cursor_impl
}

_uninstall_cursor_impl() {
	if [[ -f "$TERMUX_DIR/colors.properties" ]]; then
		rm "$TERMUX_DIR/colors.properties"
		log_success "Cursor Color uninstalled"
	else
		log_warn "Cursor Color not configured"
	fi
}

uninstall_cursor() {
	if [[ ! -f "$TERMUX_DIR/colors.properties" ]]; then
		log_info "Cursor Color is not installed"
		return 0
	fi
	log_info "Uninstalling Cursor Color..."
	loading "Uninstalling Cursor Color" _uninstall_cursor_impl
}

_update_cursor_impl() {
	install_cursor
}

update_cursor() {
	log_info "Updating Cursor Color..."
	loading "Updating Cursor Color" _update_cursor_impl
}

reinstall_cursor() {
	uninstall_cursor
	install_cursor
}
