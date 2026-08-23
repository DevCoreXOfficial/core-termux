#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_appearance.log}"
MARKER="# ===== Core Cursor ====="

_detect_shell_config() {
  if [[ -f "$HOME/.zshrc" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  fi
}

case "${1:-install}" in
  install)
    RC="$(_detect_shell_config)"
    if [[ -z "$RC" ]]; then
      log_error "No shell config file found (.zshrc or .bashrc)"
      exit 1
    fi
    if grep -qF "$MARKER" "$RC"; then
      log_info "Cursor color already configured"
      exit 0
    fi
    cat >>"$RC" <<EOF

$MARKER
# Green cursor (OSC 12; honored by xterm-compatible terminals)
printf '\033]12;#00FF00\007'
EOF
    log_success "Cursor color set to #00FF00 ($RC)"
    ;;
  uninstall)
    RC="$(_detect_shell_config)"
    [[ -z "$RC" ]] && exit 0
    if grep -qF "$MARKER" "$RC"; then
      sed -i "/^$MARKER\$/d; /^# Green cursor (OSC 12/d; /^printf '\\\\033]12;/d" "$RC"
      log_success "Cursor color removed"
    else
      log_info "Cursor color not configured"
    fi
    ;;
  *) exit 0 ;;
esac
