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
  if command -v jq &>/dev/null; then
    log_info "jq is already installed"
    return 2
  fi

  separator
  box_large "Installing jq"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  pm_install jq
}

_impl_uninstall() {
  if ! command -v jq &>/dev/null; then
    log_info "jq is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling jq"
  separator
  echo

  pm_remove jq
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  loading "Updating jq" $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y jq || { log_error "Failed to update jq"; return 1; }
  log_success "jq updated to the latest version"
}

_impl_vlocal() {
  __jq_vl_query() {
  dpkg -s jq 2>/dev/null | grep '^Version:' | awk '{print $2}' | head -1
  }
  _spin_capture "Detecting jq version" __jq_vl_query
}

_impl_vremote() {
  __jq_vr_query() {
  apt-cache policy jq 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | head -1
  }
  _spin_capture "Checking jq updates" __jq_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "jq" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
