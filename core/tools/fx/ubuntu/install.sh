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
  box_large "Installing fx"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://fx.sh/setup.sh | bash &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling fx"
  separator
  echo

  log_info "Removing binaries..."
  command -v "fx" >/dev/null 2>&1 && rm -f "$(command -v fx)"
  rm -f "$HOME/.local/bin/fx" 2>/dev/null
}

_impl_update() {
  loading "Updating fx" bash -c 'curl -fsSL https://fx.sh/setup.sh | bash &>>"$LOG_FILE"' || { log_error "Failed to update fx"; return 1; }
  log_success "fx updated to the latest version"
}

_impl_vlocal() {
  __fx_vl_query() {
  command -v fx >/dev/null 2>&1 && fx --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+[^ ]*' | head -1
  }
  _spin_capture "Detecting fx version" __fx_vl_query
}

_impl_vremote() {
  __fx_vr_query() {
  curl -fsSL https://api.github.com/repos/vercel-labs/fx/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking fx updates" __fx_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "fx" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
