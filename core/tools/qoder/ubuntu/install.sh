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
  box_large "Installing Qoder"
  separator
  echo

  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://qoder.com/install | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Qoder"
  separator
  echo

  log_info "Removing binaries..."
  command -v "qodercli" >/dev/null 2>&1 && rm -f "$(command -v qodercli)"
}

_impl_update() {
  loading "Updating Qoder CLI" bash -c 'curl -fsSL https://qoder.com/install | bash &>>"$LOG_FILE"' || { log_error "Failed to update Qoder CLI"; return 1; }
  log_success "Qoder CLI updated to the latest version"
}

_impl_vlocal() {
  _get_installed_version qodercli
}

_impl_vremote() {
  _get_remote_github_version qoder-ai/qoder
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Qoder" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
