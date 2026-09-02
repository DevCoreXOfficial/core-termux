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
  separator
  box_large "Installing Goose"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Goose"
  separator
  echo

  log_info "Removing binaries..."
  command -v "goose" >/dev/null 2>&1 && rm -f "$(command -v goose)"
}

_impl_update() {
  curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash &>>"$LOG_FILE"
}

_impl_vlocal() {
  command -v goose >/dev/null 2>&1 && goose --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
}

_impl_vremote() {
  curl -fsSL https://api.github.com/repos/aaif-goose/goose/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
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
