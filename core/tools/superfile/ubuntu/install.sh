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
  separator
  box_large "Installing SuperFile"
  separator
  echo

  curl -fsSL https://superfile.dev/install.sh | bash &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling SuperFile"
  separator
  echo

  rm -f "$HOME/.local/bin/spf"
}

_impl_update() {
  curl -fsSL https://superfile.dev/install.sh | bash &>>"$LOG_FILE"
}

_impl_vlocal() {
  command -v spf >/dev/null 2>&1 && spf --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
}

_impl_vremote() {
  curl -fsSL https://api.github.com/repos/yorukot/superfile/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
