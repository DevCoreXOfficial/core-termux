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
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal &>>"$LOG_FILE"
  export PATH="$HOME/.cargo/bin:$PATH"
}

_impl_uninstall() {
  "$HOME/.cargo/bin/rustup" self uninstall -y &>>"$LOG_FILE" || rm -rf ~/.cargo ~/.rustup
}

_impl_update() {
  rustup update &>>"$LOG_FILE" || "$HOME/.cargo/bin/rustup" update &>>"$LOG_FILE"
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall ; sleep 1 ; _impl_install ;;
  *)
    exit 0
    ;;
esac
