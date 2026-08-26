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
  # Official prerequisites (docs): git, curl, xz-utils on Debian/Ubuntu.
  pm_install git curl xz-utils ca-certificates
  mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash &>>"$LOG_FILE"
  # Per-user layout symlinks into ~/.local/bin already; expose if root-mode.
  [ -f /usr/local/bin/hermes ] && ln -sf /usr/local/bin/hermes "$HOME/.local/bin/hermes"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  log_info "Removing binaries..."
  command -v "hermes" >/dev/null 2>&1 && rm -f "$(command -v hermes)"
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
