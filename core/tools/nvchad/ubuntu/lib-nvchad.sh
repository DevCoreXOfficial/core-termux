#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"
_impl_install() {
  command -v nvim >/dev/null 2>&1 || { log_error 'Neovim is required. Run: core install nvchad'; return 1 2>/dev/null || exit 1; }
  command -v rg >/dev/null 2>&1 || pm_install ripgrep
  [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
  git clone https://github.com/NvChad/starter.git "$HOME/.config/nvim" &>>"$LOG_FILE"
  nvim --headless "+qa" &>>"$LOG_FILE" || true
}

_impl_uninstall() {
  read_confirm_default 'Delete NvChad config (~/.config/nvim)?' n __a
  [ "$__a" = y ] && rm -rf "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.cache/nvim"
}

_impl_update() {
  cd "$HOME/.config/nvim" && git pull --ff-only &>>"$LOG_FILE"
  nvim --headless "+qa" &>>"$LOG_FILE" || true
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  reinstall)
    _impl_uninstall >/dev/null 2>&1 || true
    _impl_install
    ;;
  uninstall)
    _impl_uninstall
    ;;
  update)
    _impl_update
    ;;
  *)
    exit 0
    ;;
esac
