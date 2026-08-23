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
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>>"$LOG_FILE"
  ~/.fzf/install --all &>>"$LOG_FILE"
}

_impl_uninstall() {
  rm -rf ~/.fzf
}

_impl_update() {
  (cd ~/.fzf && git pull --ff-only) &>>"$LOG_FILE" && ~/.fzf/install --all &>>"$LOG_FILE"
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
