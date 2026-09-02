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
  if command -v wget &>/dev/null; then
    log_info "wget is already installed"
    return 2
  fi

  separator
  box_large "Installing wget"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  pm_install wget
}

_impl_uninstall() {
  if ! command -v wget &>/dev/null; then
    log_info "wget is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling wget"
  separator
  echo

  pm_remove wget
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y wget
}

_impl_vlocal() {
  dpkg -s wget 2>/dev/null | grep '^Version:' | awk '{print $2}' | head -1
}

_impl_vremote() {
  apt-cache policy wget 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | head -1
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Wget" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
