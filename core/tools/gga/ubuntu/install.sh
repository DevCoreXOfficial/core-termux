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
  DEST="$HOME/.local/share/core-data/gga"
  mkdir -p "$DEST"
  git clone --depth 1 https://github.com/Gentleman-Programming/gentleman-guardian-angel.git "$DEST" 2>/dev/null || (cd "$DEST" && git pull --ff-only) &>>"$LOG_FILE"
  (cd "$DEST" && bash ./install.sh </dev/null) &>>"$LOG_FILE"
}

_impl_uninstall() {
  DEST="$HOME/.local/share/core-data/gga"
  [ -f "$DEST/uninstall.sh" ] && (cd "$DEST" && bash ./uninstall.sh </dev/null) &>>"$LOG_FILE"
  rm -rf "$DEST"
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  uninstall)
    _impl_uninstall
    ;;
  update) _impl_install ;;
  *)
    exit 0
    ;;
esac
