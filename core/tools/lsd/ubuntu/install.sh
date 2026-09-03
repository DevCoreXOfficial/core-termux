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
  if command -v lsd &>/dev/null; then
    log_info "LSD is already installed"
    return 2
  fi

  separator
  box_large "Installing LSD"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  pm_install lsd
}

_impl_uninstall() {
  if ! command -v lsd &>/dev/null; then
    log_info "LSD is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling LSD"
  separator
  echo

  pm_remove lsd
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  loading "Updating lsd" $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y lsd || { log_error "Failed to update lsd"; return 1; }
  log_success "lsd updated to the latest version"
}

_impl_vlocal() {
  __lsd_vl_query() {
  dpkg -s lsd 2>/dev/null | grep '^Version:' | awk '{print $2}' | head -1
  }
  _spin_capture "Detecting lsd version" __lsd_vl_query
}

_impl_vremote() {
  __lsd_vr_query() {
  apt-cache policy lsd 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | head -1
  }
  _spin_capture "Checking lsd updates" __lsd_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "LSD" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
