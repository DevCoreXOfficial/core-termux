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
  pm_install golang-go

  # Go environment (user dirs + go/bin on PATH) in every shell config.
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$rc" ]] || continue
    grep -q 'GOMODCACHE' "$rc" && continue
    cat >>"$rc" <<'GOENV'

# Added by Core - Go environment
export GOPATH="$HOME/.local/go"
export GOCACHE="$HOME/.cache/go"
export GOMODCACHE="$GOPATH/pkg/mod"
export PATH="$PATH:$HOME/go/bin:$GOPATH/bin"
GOENV
    log_success "Go environment added to $rc"
  done
  mkdir -p "$HOME/.local/bin"
  pm_install golang-go
}

_impl_uninstall() {
  pm_remove golang-go
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y golang-go
}

_impl_vlocal() {
  dpkg -s golang-go 2>/dev/null | grep '^Version:' | awk '{print $2}' | head -1
}

_impl_vremote() {
  apt-cache policy golang-go 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | head -1
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
