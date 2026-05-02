#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

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