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
  box_large "Installing Claude Code"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://claude.ai/install.sh | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Claude Code"
  separator
  echo

  log_info "Removing binaries..."
  command -v "claude" >/dev/null 2>&1 && rm -f "$(command -v claude)"
}

_impl_update() {
  loading "Updating Claude Code" bash -c 'curl -fsSL https://claude.ai/install.sh | bash &>>"$LOG_FILE"' || { log_error "Failed to update Claude Code"; return 1; }
  log_success "Claude Code updated to the latest version"
}

_impl_vlocal() {
  __claude_code_vl_query() {
  command -v claude >/dev/null 2>&1 && claude --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting Claude Code version" __claude_code_vl_query
}

_impl_vremote() {
  __claude_code_vr_query() {
  curl -fsSL https://api.github.com/repos/anthropics/claude-code/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
  }
  _spin_capture "Checking Claude Code updates" __claude_code_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Claude Code" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
