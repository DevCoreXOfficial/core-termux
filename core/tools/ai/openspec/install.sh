#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"

# Source bun installer for dependency auto-install
_BUN_SAVED_LOG="$LOG_FILE"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lang/bun/install.sh"
LOG_FILE="$_BUN_SAVED_LOG"

_openspec_dependencies() {
  loading "Installing dependencies" _openspec_dependencies_impl
}

_openspec_dependencies_impl() {
  declare -A DEPS=()

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  _ensure_bun || return 1

  return 0
}

_install_openspec_bun() {
  loading "Installing OpenSpec" _install_openspec_bun_impl
}

_install_openspec_bun_impl() {
  if ! bun install -g @fission-ai/openspec@latest &>>"$LOG_FILE"; then
    log_error "Failed to install OpenSpec"
    return 1
  fi

  return 0
}

install_openspec() {
  if command -v openspec &>/dev/null; then
    log_info "OpenSpec is already installed"
    return 2
  fi

  log_info "Installing OpenSpec..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _openspec_dependencies || return 1
  _install_openspec_bun || return 1

  log_success "OpenSpec installed successfully"
  return 0
}

uninstall_openspec() {
  if ! command -v openspec &>/dev/null; then
    log_info "OpenSpec is not installed"
    return 2
  fi
  log_info "Uninstalling OpenSpec..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing OpenSpec" _uninstall_openspec_impl

  log_success "OpenSpec uninstalled"
  return 0
}

_uninstall_openspec_impl() {
  if ! bun uninstall -g @fission-ai/openspec &>>"$LOG_FILE"; then
    log_error "Failed to uninstall OpenSpec"
    return 1
  fi
  return 0
}

update_openspec() {
  _check_update_needed "OpenSpec" "$(_get_installed_version openspec)" "$(_get_remote_npm_version @fission-ai/openspec)" _update_openspec
}

_update_openspec() {
  loading "Updating OpenSpec" _update_openspec_impl
}

_update_openspec_impl() {
  if ! bun install -g @fission-ai/openspec@latest &>>"$LOG_FILE"; then
    log_error "Failed to update OpenSpec"
    return 1
  fi
  return 0
}

reinstall_openspec() {
  uninstall_openspec
  install_openspec
}
