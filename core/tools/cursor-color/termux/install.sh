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
  _update_cursor_impl
}

reinstall_cursor() {
	uninstall_cursor
	install_cursor
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_cursor; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_cursor; fi
if [[ "${1:-}" == "update" ]]; then update_cursor; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_cursor; fi
