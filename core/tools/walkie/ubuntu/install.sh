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

# Upstream has no npm-hosted release channel: the CLI ships from the
# GitHub repo (github:vikasprogrammer/walkie -> package name `walkie-sh`,
# which is a different, frozen 1.4.0 artifact on the npm registry). Keep
# install/update/version sources pointing at the same git source.
WALKIE_SPEC="github:vikasprogrammer/walkie"
WALKIE_PKG_JSON_URL="https://raw.githubusercontent.com/vikasprogrammer/walkie/master/package.json"

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
  box_large "Installing Walkie"
  separator
  echo

  _impl_require_npm
  _npm_g install -g "$WALKIE_SPEC" &>>"$LOG_FILE"
}

_impl_uninstall() {
  separator
  box_large "Uninstalling Walkie"
  separator
  echo

  _npm_g uninstall -g "$WALKIE_SPEC" &>>"$LOG_FILE" || true
}

_impl_update() {
  _impl_require_npm
  _npm_g install -g "${WALKIE_SPEC}" &>>"$LOG_FILE"
}

_impl_vlocal() {
  # `npm ls` cannot resolve a git spec, so query the installed package
  # name (walkie-sh) and fall back to its global package.json.
  local v
  v=$(npm ls -g walkie-sh --depth=0 2>/dev/null | grep '@' | sed 's/.*@//' | head -1)
  if [ -z "$v" ]; then
    v=$(_spin_capture "Detecting Walkie version" bash -c \
      "curl -fsSL \"\$(npm prefix -g)/lib/node_modules/walkie-sh/package.json\" 2>/dev/null | grep '\"version\"' | head -1 | sed 's/[^0-9.]//g'")
  fi
  echo "$v"
}

_impl_vremote() {
  # Resolve the installed git spec directly (works on modern npm);
  # fall back to the upstream package.json on the default branch.
  local v
  v=$(npm view "$WALKIE_SPEC" version 2>/dev/null | head -1)
  if [ -z "$v" ]; then
    v=$(_spin_capture "Checking Walkie upstream" bash -c \
      "curl -fsSL '$WALKIE_PKG_JSON_URL' 2>/dev/null | grep '\"version\"' | head -1 | sed 's/[^0-9.]//g'")
  fi
  echo "$v"
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "Walkie" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
