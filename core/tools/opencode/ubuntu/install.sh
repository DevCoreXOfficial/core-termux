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
  curl -fsSL https://opencode.ai/install | bash &>>"$LOG_FILE"
# Official script installs to ~/.opencode/bin — expose it on PATH.
[ -f "$HOME/.opencode/bin/opencode" ] && ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
}

_impl_uninstall() {
  rm -rf "$HOME/.opencode"
rm -f "$HOME/.local/bin/opencode" "$HOME/.local/bin/opencode"
}

_impl_update() {
  curl -fsSL https://opencode.ai/install | bash &>>"$LOG_FILE"
# Official script installs to ~/.opencode/bin — expose it on PATH.
[ -f "$HOME/.opencode/bin/opencode" ] && ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
