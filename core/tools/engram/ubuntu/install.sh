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
  separator
  box_large "Installing Engram"
  separator
  echo

  loading "Installing Engram (clone + go build)" _impl_install_impl
}
_impl_install_impl() {
  command -v go >/dev/null 2>&1 || pm_install golang-go
  mkdir -p "$HOME/.local/share/core-data/engram" "$HOME/.local/bin" "$HOME/go/bin"
  git clone --depth 1 https://github.com/Gentleman-Programming/engram.git "$HOME/.local/share/core-data/engram" 2>/dev/null || (cd "$HOME/.local/share/core-data/engram" && git pull --ff-only) &>>"$LOG_FILE"
  (cd "$HOME/.local/share/core-data/engram" && CGO_ENABLED=0 go install ./cmd/engram) &>>"$LOG_FILE"
  [ -f "$HOME/go/bin/engram" ] && ln -sf "$HOME/go/bin/engram" "$HOME/.local/bin/engram"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Engram"
  separator
  echo

  rm -f "$HOME/.local/bin/engram" "$HOME/go/bin/engram" 2>/dev/null
  read_confirm_default "Delete ~/.local/share/core-data/engram?" n __a
  [ "$__a" = y ] && rm -rf "$HOME/.local/share/core-data/engram"
}

_impl_update() {
  __engram_update_query() {
    (cd "$HOME/.local/share/core-data/engram" && git pull --ff-only) &>>"$LOG_FILE" || return 1
    (cd "$HOME/.local/share/core-data/engram" && CGO_ENABLED=0 go install ./cmd/engram) &>>"$LOG_FILE" || return 1
    [ -f "$HOME/go/bin/engram" ] && ln -sf "$HOME/go/bin/engram" "$HOME/.local/bin/engram"
    return 0
  }
  loading "Updating Engram (git pull + go build)" __engram_update_query || { log_error "Failed to update Engram"; return 1; }
  log_success "Engram updated to the latest version"
}

_impl_vlocal() {
  _get_installed_version engram
}

_impl_vremote() {
  _get_remote_github_version Gentleman-Programming/engram
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Engram" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  *)
    exit 0
    ;;
esac
