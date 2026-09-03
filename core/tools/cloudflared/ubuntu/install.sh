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
  if command -v cloudflared &>/dev/null; then
    log_info "Cloudflared is already installed"
    return 2
  fi

  separator
  box_large "Installing Cloudflared"
  separator
  echo

  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | $CORE_SUDO tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | $CORE_SUDO tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
  pm_install cloudflared
}

_impl_uninstall() {
  if ! command -v cloudflared &>/dev/null; then
    log_info "Cloudflared is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling Cloudflared"
  separator
  echo

  $CORE_SUDO rm -f /etc/apt/sources.list.d/cloudflared.list
  pm_remove cloudflared
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  loading "Updating Cloudflare" $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflared || { log_error "Failed to update Cloudflare"; return 1; }
  log_success "Cloudflare updated to the latest version"
}

_impl_vlocal() {
  __cloudflared_vl_query() {
  cloudflared --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting Cloudflare version" __cloudflared_vl_query
}

_impl_vremote() {
  __cloudflared_vr_query() {
  curl -fsSL https://api.github.com/repos/cloudflare/cloudflared/releases/latest | grep '"tag_name"' | cut -d'"' -f4
  }
  _spin_capture "Checking Cloudflare updates" __cloudflared_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "cloudflared" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
