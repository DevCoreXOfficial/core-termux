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
  ARCH=$(uname -m); case "$ARCH" in x86_64) K="linux_x64" ;; aarch64) K="linux_arm64" ;; *) K="linux_x64" ;; esac
  URL=$(curl -fsSL "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/channels/manifest.json" \
    | jq -r --arg k "$K" '.channels.stable.platforms[$k].url // .platforms[$k].url // empty')
  [ -z "$URL" ] && { log_error "Could not resolve Qoder download URL"; return 1; }
  mkdir -p "$HOME/.local/bin"
  curl -fsSL "$URL" -o /tmp/qoder.tar.gz &>>"$LOG_FILE"
  tar -xzf /tmp/qoder.tar.gz -C /tmp &>>"$LOG_FILE"
  BIN=$(find /tmp -maxdepth 2 -type f -name qodercli | head -1)
  [ -z "$BIN" ] && { log_error "qodercli binary not found"; return 1; }
  mv "$BIN" "$HOME/.local/bin/qodercli" && chmod +x "$HOME/.local/bin/qodercli"
  rm -f /tmp/qoder.tar.gz
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/qodercli"
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
