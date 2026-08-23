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
  command -v go >/dev/null 2>&1 || pm_install golang-go
  command -v git >/dev/null 2>&1 || pm_install git
  mkdir -p "$HOME/.local/bin" ""$HOME/.local/share/core-data/engram""
  git clone --depth 1 https://github.com/Gentleman-Programming/engram.git ""$HOME/.local/share/core-data/engram"" 2>/dev/null || (cd ""$HOME/.local/share/core-data/engram"" && git pull --ff-only) &>>"$LOG_FILE"
  (cd ""$HOME/.local/share/core-data/engram"" && CGO_ENABLED=0 go build -trimpath -o "$HOME/.local/bin/engram" ./cmd/engram) &>>"$LOG_FILE"
  chmod +x "$HOME/.local/bin/engram" 2>/dev/null || true
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/engram"
  rm -rf "$HOME/.local/share/core-data/engram"
}

_impl_update() {
  (cd ""$HOME/.local/share/core-data/engram"" && git pull --ff-only && CGO_ENABLED=0 go build -trimpath -o "$HOME/.local/bin/engram" ./cmd/engram) &>>"$LOG_FILE"
}

_impl_vlocal() {
  "$HOME/.local/bin/engram" --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
}

_impl_vremote() {
  curl -fsSL https://api.github.com/repos/Gentleman-Programming/engram/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d v
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
