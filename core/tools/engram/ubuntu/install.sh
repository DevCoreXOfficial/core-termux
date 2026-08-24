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
  command -v go >/dev/null 2>&1 || pm_install golang-go
  mkdir -p "~/.local/share/core-data/engram" "$HOME/.local/bin" "$HOME/go/bin"
  git clone --depth 1 https://github.com/Gentleman-Programming/engram.git "~/.local/share/core-data/engram" 2>/dev/null || (cd "~/.local/share/core-data/engram" && git pull --ff-only) &>>"$LOG_FILE"
  (cd "~/.local/share/core-data/engram" && CGO_ENABLED=0 go install ./cmd/engram) &>>"$LOG_FILE"
  [ -f "$HOME/go/bin/engram" ] && ln -sf "$HOME/go/bin/engram" "$HOME/.local/bin/engram"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/engram" "$HOME/go/bin/engram" 2>/dev/null
  read_confirm_default "Delete ~/.local/share/core-data/engram?" n __a
  [ "$__a" = y ] && rm -rf "~/.local/share/core-data/engram"
}

_impl_update() {
  (cd "~/.local/share/core-data/engram" && git pull --ff-only) &>>"$LOG_FILE"
  (cd "~/.local/share/core-data/engram" && CGO_ENABLED=0 go install ./cmd/engram) &>>"$LOG_FILE"
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  *)
    exit 0
    ;;
esac
