#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
import "@/lib/engine"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"
_impl_install() {
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | $CORE_SUDO tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | $CORE_SUDO tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
  pm_install cloudflared
}

_impl_uninstall() {
  $CORE_SUDO rm -f /etc/apt/sources.list.d/cloudflared.list && pm_remove cloudflared
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  reinstall)
    _impl_uninstall >/dev/null 2>&1 || true
    _impl_install
    ;;
  uninstall)
    _impl_uninstall
    ;;
  *)
    exit 0
    ;;
esac
