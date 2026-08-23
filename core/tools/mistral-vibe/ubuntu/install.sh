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
  if ! command -v pipx >/dev/null 2>&1; then pm_install pipx; fi
  pipx ensurepath 2>/dev/null || true
  pipx install mistral-vibe &>>"$LOG_FILE"
}

_impl_uninstall() {
  pipx uninstall mistral-vibe &>>"$LOG_FILE" || true
}

_impl_update() {
  pipx upgrade mistral-vibe &>>"$LOG_FILE" || pipx install mistral-vibe &>>"$LOG_FILE"
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
