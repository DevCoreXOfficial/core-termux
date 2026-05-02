#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

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