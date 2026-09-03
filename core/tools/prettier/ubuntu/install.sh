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

# Global installs can hit a root-owned npm prefix (distro nodejs).
_npm_g() {
  npm "$@" &>>"$LOG_FILE" || {
    log_warn "npm failed without privileges - retrying with sudo"
    $CORE_SUDO npm "$@" &>>"$LOG_FILE"
  }
}

_impl_require_npm() {
  command -v npm >/dev/null 2>&1 && return 0
  # Delegate to Core's canonical Node.js installer (platform-aware).
  if [[ -n "${TERMUX_VERSION:-}" || "${PREFIX:-}" == *com.termux* ]]; then
    yes | pkg install -y nodejs-lts &>>"$LOG_FILE"
    command -v corepack >/dev/null 2>&1 && corepack enable &>/dev/null || true
  else
    mkdir -p "$HOME/.local/bin"
    bash "$CORE_PATH/tools/nodejs/ubuntu/install.sh" install
    export PATH="$HOME/.local/bin:$PATH"
  fi
  command -v npm >/dev/null 2>&1 || { log_error "npm unavailable after Node.js install"; exit 1; }
}

_impl_install() {
  if command -v prettier &>/dev/null; then
    log_info "Prettier is already installed"
    return 2
  fi

  separator
  box_large "Installing Prettier"
  separator
  echo

  _impl_require_npm
  mkdir -p "$HOME/.local/bin"
  _npm_g install -g prettier &>>"$LOG_FILE"
}

_impl_uninstall() {
  if ! command -v prettier &>/dev/null; then
    log_info "Prettier is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling Prettier"
  separator
  echo

  _npm_g uninstall -g prettier &>>"$LOG_FILE" || true
}

_impl_update() {
  _impl_require_npm
  loading "Updating Prettier" bash -c '_npm_g install -g prettier@latest &>>"$LOG_FILE"' || { log_error "Failed to update Prettier"; return 1; }
  log_success "Prettier updated to the latest version"
}

_impl_vlocal() {
  __prettier_vl_query() {
  npm ls -g prettier --depth=0 2>/dev/null | grep '@' | sed 's/.*@//' | head -1
  }
  _spin_capture "Detecting Prettier version" __prettier_vl_query
}

_impl_vremote() {
  __prettier_vr_query() {
  npm view prettier version 2>/dev/null | head -1
  }
  _spin_capture "Checking Prettier updates" __prettier_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Prettier" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
