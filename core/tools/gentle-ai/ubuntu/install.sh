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
  command -v go >/dev/null 2>&1 || pm_install golang-go
  command -v git >/dev/null 2>&1 || pm_install git
  mkdir -p "$HOME/.local/bin" ""$HOME/.local/share/core-data/gentle-ai""
  git clone --depth 1 https://github.com/Gentleman-Programming/gentle-ai.git ""$HOME/.local/share/core-data/gentle-ai"" 2>/dev/null || (cd ""$HOME/.local/share/core-data/gentle-ai"" && git pull --ff-only) &>>"$LOG_FILE"
  (cd ""$HOME/.local/share/core-data/gentle-ai"" && CGO_ENABLED=0 go build -trimpath -o "$HOME/.local/bin/gentle-ai" ./cmd/gentle-ai) &>>"$LOG_FILE"
  command -v gentle-ai >/dev/null 2>&1 || export PATH="$HOME/.local/bin:$PATH"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/gentle-ai"
  rm -rf "$HOME/.local/share/core-data/gentle-ai"
}

_impl_update() {
  (cd ""$HOME/.local/share/core-data/gentle-ai"" && git pull --ff-only && CGO_ENABLED=0 go build -trimpath -o "$HOME/.local/bin/gentle-ai" ./cmd/gentle-ai) &>>"$LOG_FILE"
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
