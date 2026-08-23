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
  ARCH=$(uname -m); case "$ARCH" in x86_64) A=amd64 ;; aarch64) A=arm64 ;; *) A="$ARCH" ;; esac
  TAG=$(curl -fsSLI https://github.com/colbymchenry/codegraph/releases/latest | grep -i "^location:" | sed -E 's#.*/tag/([^[:space:]^/]+).*#\1#')
  mkdir -p "$HOME/.local/bin"
  curl -fsSL "https://github.com/colbymchenry/codegraph/releases/download/${TAG}/codegraph-linux-${A}.tar.gz" -o /tmp/codegraph.tar.gz &>>"$LOG_FILE"
  tar -xzf /tmp/codegraph.tar.gz -C /tmp &>>"$LOG_FILE"
  find /tmp -maxdepth 1 -name "codegraph*" -type f -exec mv {} "$HOME/.local/bin/codegraph" \; &>>"$LOG_FILE"
  chmod +x "$HOME/.local/bin/codegraph"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/codegraph"
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
