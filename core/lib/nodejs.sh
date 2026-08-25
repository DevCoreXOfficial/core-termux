#!/usr/bin/env bash

# Core - shared Node.js LTS installer.
# Single source of truth for every node-dependent tool and for the engine's
# dependency resolution. The one-line install.sh cannot load this file and
# therefore duplicates the logic inline (by design).

[[ -n "${__CORE_NODEJS_LIB:-}" ]] && return 0
__CORE_NODEJS_LIB=1

[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"

# Self-detect when invoked outside the main process (tool scripts).
[[ -n "${CORE_ENV:-}" ]] || core_detect_platform

ensure_nodejs_lts() {
  # Already satisfied?
  if command -v node >/dev/null 2>&1; then
    return 0
  fi

  local _log="${LOG_FILE:-${CORE_CACHE:-$HOME/.cache}/core/install.log}"
  mkdir -p "$(dirname "$_log")"

  if [[ "$CORE_ENV" == "termux" ]]; then
    loading "Installing Node.js LTS" _nodejs_lts_termux
    if ! command -v node >/dev/null 2>&1; then
      log_error "Node.js LTS failed to install"
      return 1
    fi
    command -v corepack >/dev/null 2>&1 && corepack enable &>/dev/null || true
    log_success "Node.js $(node --version) installed (corepack enabled)"
  else
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    # Respect the user's login shell when persisting PATH.
    local rc_file
    case "${SHELL:-}" in
      *zsh*) rc_file="$HOME/.zshrc" ;;
      *)     rc_file="$HOME/.bashrc" ;;
    esac
    if ! grep -qs 'HOME/.local/bin' "$rc_file"; then
      printf '\n# Added by Core\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$rc_file"
      log_ok "Added ~/.local/bin to your PATH ($rc_file)"
    fi

    loading "Installing Node.js LTS (NodeSource)" _nodejs_lts_ubuntu
    if ! command -v node >/dev/null 2>&1; then
      log_error "Node.js LTS failed to install - last output:"
      tail -5 "$_log" 2>/dev/null | sed 's/^/  /' >&2
      return 1
    fi
    log_success "Node.js $(node --version) + npm $(npm --version) ready (LTS)"
  fi
}

_nodejs_lts_termux() {
  yes | pkg install -y nodejs-lts &>>"${LOG_FILE:-/dev/null}"
}

_nodejs_lts_ubuntu() {
  local _log="${LOG_FILE:-/dev/null}"
  # Remove conflicting distro packages first (NodeSource requirement),
  # then install the official LTS build. The NodeSource package ships npm.
  {
    $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get remove -y \
      nodejs 'libnode*' 2>/dev/null || true
    $CORE_SUDO apt-get autoremove -y 2>/dev/null || true
    curl -fsSL https://deb.nodesource.com/setup_lts.x | $CORE_SUDO -E bash -
    $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
  } &>>"$_log"
}
