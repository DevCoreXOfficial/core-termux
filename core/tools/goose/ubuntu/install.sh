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
  loading "Updating goose" bash -c 'curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash &>>"$LOG_FILE"' || { log_error "Failed to update goose"; return 1; }
  log_success "goose updated to the latest version"
}

_impl_vlocal() {
  __goose_vl_query() {
  command -v goose >/dev/null 2>&1 && goose --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting goose version" __goose_vl_query
}

_impl_vremote() {
  __goose_vr_query() {
  curl -fsSL https://api.github.com/repos/aaif-goose/goose/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking goose updates" __goose_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Goose CLI" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
