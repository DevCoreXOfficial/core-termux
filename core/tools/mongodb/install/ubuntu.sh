#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"
_impl_install() {
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | $CORE_SUDO gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | $CORE_SUDO tee /etc/apt/sources.list.d/mongodb-org-8.0.list >/dev/null
  pm_install mongodb-org mongodb-mongosh
}

_impl_uninstall() {
  $CORE_SUDO apt-get purge -y mongodb-org* && $CORE_SUDO rm -f /etc/apt/sources.list.d/mongodb-org-8.0.list
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  uninstall)
    _impl_uninstall
    ;;
  *)
    exit 0
    ;;
esac
