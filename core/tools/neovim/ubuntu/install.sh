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
  pm_install neovim
}

_impl_uninstall() {
  pm_remove neovim
}

_impl_update() {
  $CORE_SUDO apt-get update -qq && $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y neovim
}

case "${1:-install}" in
  install)
    _impl_install || exit $?
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$LIB_DIR/lib-nvchad-ubuntu.sh" install || log_warn "NvChad setup failed (see log)"
    ;;
  reinstall)
    _impl_uninstall >/dev/null 2>&1 || true
    _impl_install
    ;;
  uninstall)
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$LIB_DIR/lib-nvchad-ubuntu.sh" uninstall >/dev/null 2>&1 || true
    _impl_uninstall
    ;;
  update)
    _impl_update
    ;;
  *)
    exit 0
    ;;
esac
