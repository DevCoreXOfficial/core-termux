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
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://omp.sh/install | bash &>>"$LOG_FILE"
  # Expose binaries from well-known script locations.
  for d in "$HOME/.local/bin" "$HOME/bin"; do [[ -d "$d" ]] && case ":$PATH:" in *":$d:"*) ;; *) export PATH="$d:$PATH";; esac; done
}

_impl_uninstall() {
  log_info "Removing binaries..."
  command -v "omp" >/dev/null 2>&1 && rm -f "$(command -v omp)"
}

_impl_update() {
  loading "Updating Oh My Pi" bash -c 'curl -fsSL https://omp.sh/install | bash &>>"$LOG_FILE"' || { log_error "Failed to update Oh My Pi"; return 1; }
  log_success "Oh My Pi updated to the latest version"
}

_impl_vlocal() {
  _get_installed_version omp
}

_impl_vremote() {
  _get_remote_github_version ohmyzsh/ohmyzsh
}

case "${1:-}" in
  install)
    separator
    box_large "Installing Oh My Pi"
    separator
    echo

    _impl_install ;;
  uninstall)
    separator
    box_large "Uninstalling Oh My Pi"
    separator
    echo

    _impl_uninstall ;;
  update)     _check_update_needed "Oh-My-Pi" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_install ;;
  *)
    exit 0
    ;;
esac
