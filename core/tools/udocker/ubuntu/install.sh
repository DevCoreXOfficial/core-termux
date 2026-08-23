#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"
_impl_install() {
  if apt-cache show udocker >/dev/null 2>&1; then pm_install udocker; else command -v pipx >/dev/null 2>&1 || pm_install pipx; pipx install udocker; fi
}

_impl_uninstall() {
  apt-cache show udocker >/dev/null 2>&1 ? true : pipx uninstall udocker || true
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  uninstall)
    _impl_uninstall
    ;;
  *)
    exit 0
    ;;
esac
