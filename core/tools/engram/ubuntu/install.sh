#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
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
  command -v engram >/dev/null 2>&1 || export PATH="$HOME/.local/bin:$PATH"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/engram"
  rm -rf "$HOME/.local/share/core-data/engram"
}

_impl_update() {
  (cd ""$HOME/.local/share/core-data/engram"" && git pull --ff-only && CGO_ENABLED=0 go build -trimpath -o "$HOME/.local/bin/engram" ./cmd/engram) &>>"$LOG_FILE"
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
