#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ui.log"
TERMUX_DIR="$HOME/.termux"

_install_extra_keys_impl() {
	mkdir -p "$(dirname "$LOG_FILE")" "$TERMUX_DIR"

	cat >"$TERMUX_DIR/termux.properties" <<'EOF'
terminal-cursor-blink-rate=500

extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]
EOF

	log_success "Extra-keys configured"
	return 0
}

EXTRA_KEYS_MARKER="terminal-cursor-blink-rate=500"

install_extra_keys() {
	if grep -qF "$EXTRA_KEYS_MARKER" "$TERMUX_DIR/termux.properties" 2>/dev/null; then
		log_info "Extra Keys already installed"
		return 0
	fi
	log_info "Installing Extra Keys..."
	loading "Installing Extra Keys" _install_extra_keys_impl
}

_uninstall_extra_keys_impl() {
	if [[ -f "$TERMUX_DIR/termux.properties" ]]; then
		rm "$TERMUX_DIR/termux.properties"
		log_success "Extra Keys uninstalled"
	else
		log_warn "Extra Keys not configured"
	fi
}

uninstall_extra_keys() {
	if ! grep -qF "$EXTRA_KEYS_MARKER" "$TERMUX_DIR/termux.properties" 2>/dev/null; then
		log_info "Extra Keys is not installed"
		return 0
	fi
	log_info "Uninstalling Extra Keys..."
	loading "Uninstalling Extra Keys" _uninstall_extra_keys_impl
}

_update_extra_keys_impl() {
	install_extra_keys
}

update_extra_keys() {
	log_info "Updating Extra Keys..."
	loading "Updating Extra Keys" _update_extra_keys_impl
}

reinstall_extra_keys() {
	uninstall_extra_keys
	install_extra_keys
}
