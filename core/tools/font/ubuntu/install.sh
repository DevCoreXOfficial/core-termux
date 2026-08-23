#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_appearance.log}"
FONT_DIR="$HOME/.local/share/fonts"

case "${1:-install}" in
  install)
    mkdir -p "$FONT_DIR" "$(dirname "$LOG_FILE")"
    FONT_SRC="$(dirname "$CORE_PATH")/assets/fonts/font.ttf"
    if [[ ! -f "$FONT_SRC" ]]; then
      log_error "Font file not found: $FONT_SRC"
      exit 1
    fi
    cp "$FONT_SRC" "$FONT_DIR/MesloNerdFont.ttf"
    command -v fc-cache >/dev/null 2>&1 || pm_install fontconfig
    fc-cache -f "$FONT_DIR" &>>"$LOG_FILE"
    log_success "Meslo Nerd Font installed (~/.local/share/fonts)"
    log_info "Select it in your terminal emulator settings"
    ;;
  uninstall)
    rm -f "$FONT_DIR/MesloNerdFont.ttf"
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONT_DIR" &>/dev/null
    log_success "Font removed"
    ;;
  *) exit 0 ;;
esac
