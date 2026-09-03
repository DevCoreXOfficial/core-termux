#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation methods.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/version"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

_impl_install() {
  separator
  box_large "Installing SuperFile"
  separator
  echo

  curl -fsSL https://superfile.dev/install.sh | bash &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling SuperFile"
  separator
  echo

  rm -f "$HOME/.local/bin/spf"
}

_impl_update() {
  loading "Updating Superfile" bash -c 'curl -fsSL https://superfile.dev/install.sh | bash &>>"$LOG_FILE"' || { log_error "Failed to update Superfile"; return 1; }
  log_success "Superfile updated to the latest version"
}

_impl_vlocal() {
  __superfile_vl_query() {
  command -v spf >/dev/null 2>&1 && spf --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting Superfile version" __superfile_vl_query
}

_impl_vremote() {
  __superfile_vr_query() {
  curl -fsSL https://api.github.com/repos/yorukot/superfile/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking Superfile updates" __superfile_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "SuperFile" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
