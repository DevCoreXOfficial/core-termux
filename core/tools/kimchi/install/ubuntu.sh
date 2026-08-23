#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
import "@/lib/engine"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

# Download an asset from the latest GitHub release of $repo.
# $1 repo, $2 asset-name regex (arch suffix appended automatically).
_gh_download() {
  local repo="$1" pattern="$2" out="$3"
  local arch alt arch_alt asset url
  case "$(uname -m)" in
    x86_64) arch="x86_64"; alt="amd64" ;;
    aarch64) arch="aarch64"; alt="arm64" ;;
    *) arch="$(uname -m)"; alt="" ;;
  esac
  local re="${pattern}(${arch}|${alt})"
  asset=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | jq -r --arg re "$re" '.assets[].name | select(test($re))' | head -1)
  [ -z "$asset" ] && return 1
  url="https://github.com/${repo}/releases/latest/download/${asset}"
  curl -fsSL "$url" -o "$out" &>>"$LOG_FILE"
}
_impl_install() {
  mkdir -p "$HOME/.local/bin"
  _gh_download "getkimchi/kimchi" "kimchi_linux_" "/tmp/kimchi.tar.gz" && tar -xzf "/tmp/kimchi.tar.gz" -C /tmp &>>"$LOG_FILE"
  BIN=$(find /tmp -maxdepth 2 -type f -name kimchi | head -1)
  [ -z "$BIN" ] && { log_error "binary not found after extraction"; return 1; }
  mv "$BIN" "$HOME/.local/bin/kimchi" && chmod +x "$HOME/.local/bin/kimchi"
  rm -f "/tmp/kimchi.tar.gz"
}

_impl_uninstall() {
  rm -f "$HOME/.local/bin/kimchi"
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
