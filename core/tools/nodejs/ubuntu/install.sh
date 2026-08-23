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
  curl -fsSL https://deb.nodesource.com/setup_lts.x | $CORE_SUDO -E bash - &>>"$LOG_FILE"
  pm_install nodejs
  $CORE_SUDO corepack enable || true
}

_impl_uninstall() {
  $CORE_SUDO apt-get purge -y nodejs libnode* 2>/dev/null || $CORE_SUDO apt-get purge -y nodejs
}

_impl_update() {
  $CORE_SUDO apt-get update -qq && $CORE_SUDO apt-get install -y nodejs
}

_impl_vlocal() {
  node --version 2>/dev/null | tr -d v
}

_impl_vremote() {
  curl -fsSL https://deb.nodesource.com/setup_lts.x 2>/dev/null | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | tail -1 | tr -d v
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
