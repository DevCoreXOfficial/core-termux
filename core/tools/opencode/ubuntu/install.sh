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
  box_large "Installing OpenCode"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://opencode.ai/install | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  separator
  box_large "Uninstalling OpenCode"
  separator
  echo

  log_info "Removing binaries..."
  command -v "opencode" >/dev/null 2>&1 && rm -f "$(command -v opencode)"
}

_impl_update() {
  loading "Updating OpenCode CLI" bash -c 'curl -fsSL https://opencode.ai/install | bash &>>"$LOG_FILE"' || { log_error "Failed to update OpenCode CLI"; return 1; }
  log_success "OpenCode CLI updated to the latest version"
}

_impl_vlocal() {
  __opencode_vl_query() {
  command -v opencode >/dev/null 2>&1 && opencode --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting OpenCode CLI version" __opencode_vl_query
}

_impl_vremote() {
  __opencode_vr_query() {
  curl -fsSL https://api.github.com/repos/anomalyco/opencode/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking OpenCode CLI updates" __opencode_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "OpenCode" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
