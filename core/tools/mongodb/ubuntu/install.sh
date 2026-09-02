#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation methods.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

_impl_install() {
  if command -v mongosh &>/dev/null; then
    log_info "MongoDB is already installed"
    return 2
  fi

  separator
  box_large "Installing MongoDB"
  separator
  echo

  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | $CORE_SUDO gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | $CORE_SUDO tee /etc/apt/sources.list.d/mongodb-org-8.0.list >/dev/null
  pm_install mongodb-org mongodb-mongosh
}

_impl_uninstall() {
  if ! command -v mongosh &>/dev/null; then
    log_info "MongoDB is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling MongoDB"
  separator
  echo

  $CORE_SUDO apt-get purge -y "mongodb-org*" || true
  $CORE_SUDO rm -f /etc/apt/sources.list.d/mongodb-org-8.0.list
}

_impl_update() {
  $CORE_SUDO apt-get update -qq && $CORE_SUDO apt-get install -y mongodb-org mongodb-mongosh
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  *)
    exit 0
    ;;
esac
