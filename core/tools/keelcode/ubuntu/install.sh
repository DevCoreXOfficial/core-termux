#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation methods.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/version"
import "@/lib/platform"
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
  separator
  box_large "Installing KeelCode"
  separator
  echo

  _impl_require_npm
  _npm_g install -g @keelcode-ai/keelcode &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling KeelCode"
  separator
  echo

  _npm_g uninstall -g @keelcode-ai/keelcode &>>"$LOG_FILE" || true
}

_impl_update() {
  _impl_require_npm
  loading "Updating KeelCode CLI" bash -c '_npm_g install -g @keelcode-ai/keelcode@latest &>>"$LOG_FILE"' || { log_error "Failed to update KeelCode CLI"; return 1; }
  log_success "KeelCode CLI updated to the latest version"
}

_impl_vlocal() {
  __keelcode_vl_query() {
  npm ls -g @keelcode-ai/keelcode --depth=0 2>/dev/null | grep '@' | sed 's/.*@//' | head -1
  }
  _spin_capture "Detecting KeelCode CLI version" __keelcode_vl_query
}

_impl_vremote() {
  __keelcode_vr_query() {
  npm view @keelcode-ai/keelcode version 2>/dev/null | head -1
  }
  _spin_capture "Checking KeelCode CLI updates" __keelcode_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "KeelCode" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
