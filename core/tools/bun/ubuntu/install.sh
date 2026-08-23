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
  curl -fsSL https://bun.sh/install | bash &>>"$LOG_FILE"
}

_impl_uninstall() {
  rm -rf "$HOME/.bun"
}

_impl_update() {
  curl -fsSL https://bun.sh/install | bash &>>"$LOG_FILE"
}

_impl_vlocal() {
  "$HOME/.bun/bin/bun" --version 2>/dev/null | head -1
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_install ;;
  version-local)  _impl_vlocal ;;
  *)
    exit 0
    ;;
esac
