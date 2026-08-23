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


# Download the newest matching asset from the latest GitHub release.
_gh_fetch() {
  local arch alt re asset
  case "$(uname -m)" in
    x86_64) arch="x86_64"; alt="amd64" ;;
    aarch64) arch="aarch64"; alt="arm64" ;;
    *) arch="$(uname -m)"; alt="" ;;
  esac
  re="codegraph-linux-(${arch}|${alt})"
  asset=$(curl -fsSL "https://api.github.com/repos/colbymchenry/codegraph/releases/latest" \
    | jq -r --arg re "$re" '.assets[].name | select(test($re))' | head -1)
  [[ -z "$asset" ]] && return 1
  curl -fsSL "https://github.com/colbymchenry/codegraph/releases/latest/download/${asset}" -o "/tmp/codegraph.dl" &>>"$LOG_FILE"
}


_impl_install() {
  mkdir -p "$HOME/.local/bin"
  _gh_fetch || { log_error "No matching release asset found"; exit 1; }
  tar -xzf /tmp/codegraph.dl -C /tmp && BIN=$(find /tmp -maxdepth 2 -type f -name codegraph | head -1) && [ -n "$BIN" ] && mv "$BIN" "$HOME/.local/bin/codegraph"
  chmod +x "$HOME/.local/bin/codegraph"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/codegraph"
}

_impl_update() {
  _gh_fetch || { log_error "No matching release asset"; exit 1; }
  tar -xzf /tmp/codegraph.dl -C /tmp && BIN=$(find /tmp -maxdepth 2 -type f -name codegraph | head -1) && [ -n "$BIN" ] && mv "$BIN" "$HOME/.local/bin/codegraph"
  chmod +x "$HOME/.local/bin/codegraph"
}

_impl_vlocal() {
  "$HOME/.local/bin/codegraph" --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
}

_impl_vremote() {
  curl -fsSL https://api.github.com/repos/colbymchenry/codegraph/releases/latest | grep '"tag_name"' | cut -d'"' -f4
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
