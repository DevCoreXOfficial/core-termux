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
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $CORE_SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  $CORE_SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $CORE_SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  pm_install gh
}

_impl_uninstall() {
  $CORE_SUDO rm -f /etc/apt/sources.list.d/github-cli.list && pm_remove gh
}

_impl_update() {
  $CORE_SUDO apt-get update -qq && $CORE_SUDO apt-get install -y gh
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
  update)
    _impl_update
    ;;
  *)
    exit 0
    ;;
esac
