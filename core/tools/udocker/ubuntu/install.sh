#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation methods.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

_impl_install() {
  if apt-cache show udocker >/dev/null 2>&1; then pm_install udocker
  else command -v pipx >/dev/null 2>&1 || pm_install pipx; pipx ensurepath >/dev/null 2>&1 || true; pipx install udocker; fi
}

_impl_uninstall() {
  command -v pipx >/dev/null 2>&1 && pipx uninstall udocker 2>/dev/null || true
  pm_remove udocker 2>/dev/null || true
}

_impl_update() {
  command -v pipx >/dev/null 2>&1 && pipx upgrade udocker 2>/dev/null || $CORE_SUDO apt-get install -y udocker
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  *)
    exit 0
    ;;
esac
