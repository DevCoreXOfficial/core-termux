#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation method.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
import "@/lib/engine"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

_impl_install() {
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  log_info "Nothing to clean beyond the binary itself"
}

_impl_update() {
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash &>>"$LOG_FILE"
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
