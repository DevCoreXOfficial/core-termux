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

_ensure_pipx() {
  command -v pipx >/dev/null 2>&1 || { pm_install pipx; pipx ensurepath >/dev/null 2>&1 || true; }
}

_impl_install() {
  _ensure_pipx
  pipx install "huggingface_hub[cli]" &>>"$LOG_FILE"
}

_impl_uninstall() {
  pipx uninstall "huggingface_hub[cli]" &>>"$LOG_FILE" || true
}

_impl_update() {
  _ensure_pipx
  pipx upgrade "huggingface_hub[cli]" &>>"$LOG_FILE" || pipx install "huggingface_hub[cli]" &>>"$LOG_FILE"
}

_impl_vlocal() {
  pipx list 2>/dev/null | grep -A1 '^   package "huggingface_hub' | grep -oE '[0-9]+\.[0-9]+[^ ]*' | head -1
}

_impl_vremote() {
  curl -fsSL "https://pypi.org/pypi/huggingface_hub/json" 2>/dev/null | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4
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
