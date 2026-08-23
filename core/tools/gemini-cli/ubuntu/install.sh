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

_impl_require_npm() {
  command -v npm >/dev/null 2>&1 || { log_error "Node.js/npm required. Run: core install nodejs"; exit 1; }
}

_impl_install() {
  _impl_require_npm
  npm install -g @google/gemini-cli &>>"$LOG_FILE"
}

_impl_uninstall() {
  npm uninstall -g @google/gemini-cli &>>"$LOG_FILE" || true
}

_impl_update() {
  _impl_require_npm
  npm install -g @google/gemini-cli@latest &>>"$LOG_FILE"
}

_impl_vlocal() {
  npm ls -g @google/gemini-cli --depth=0 2>/dev/null | grep '@' | sed 's/.*@//' | head -1
}

_impl_vremote() {
  npm view @google/gemini-cli version 2>/dev/null | head -1
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
