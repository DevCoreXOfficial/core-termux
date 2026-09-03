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
  box_large "Installing Jcode"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://jcode.sh/install | bash &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Jcode"
  separator
  echo

  log_info "Removing binaries..."
  command -v "jcode" >/dev/null 2>&1 && rm -f "$(command -v jcode)"
  rm -f "$HOME/.local/bin/jcode" 2>/dev/null
}

_impl_update() {
  loading "Updating Jcode" bash -c 'curl -fsSL https://jcode.sh/install | bash &>>"$LOG_FILE"' || { log_error "Failed to update Jcode"; return 1; }
  log_success "Jcode updated to the latest version"
}

_impl_vlocal() {
  __jcode_vl_query() {
  command -v jcode >/dev/null 2>&1 && jcode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+[^ ]*' | head -1
  }
  _spin_capture "Detecting Jcode version" __jcode_vl_query
}

_impl_vremote() {
  __jcode_vr_query() {
  curl -fsSL https://api.github.com/repos/1jehuang/jcode/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking Jcode updates" __jcode_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Jcode" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
