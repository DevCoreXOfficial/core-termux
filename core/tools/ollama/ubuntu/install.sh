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
  if command -v ollama &>/dev/null; then
    log_info "Ollama is already installed"
    return 2
  fi

  separator
  box_large "Installing Ollama"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://ollama.com/install.sh | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  if ! command -v ollama &>/dev/null; then
    log_info "Ollama is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling Ollama"
  separator
  echo

  log_info "Removing binaries..."
  command -v "ollama" >/dev/null 2>&1 && rm -f "$(command -v ollama)"
}

_impl_update() {
  curl -fsSL https://ollama.com/install.sh | bash &>>"$LOG_FILE"
}

_impl_vlocal() {
  command -v ollama >/dev/null 2>&1 && ollama --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
}

_impl_vremote() {
  curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Ollama" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
