#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"

import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
source "$CORE_PATH/tools/bun/termux/lib.sh"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_pi_dependencies() {
  loading "Installing dependencies" _pi_dependencies_impl
}

_pi_dependencies_impl() {
  declare -A DEPS=(
    ["ripgrep"]="rg"
    ["git"]="git"
    ["fd"]="fd"
  )

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

_install_pi_bun() {
  loading "Installing Pi Coding Agent" _install_pi_bun_impl
}

_install_pi_bun_impl() {
  if ! _install_pkg_fallback "@earendil-works/pi-coding-agent" "--ignore-scripts"; then
    log_error "Failed to install Pi"
    return 1
  fi

  return 0
}

install_pi() {
  if command -v pi &>/dev/null; then
    log_info "Pi Coding Agent is already installed"
    return 2
  fi
  log_info "Installing Pi Coding Agent..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _pi_dependencies || return 1
  _install_pi_bun || return 1

  log_success "Pi Coding Agent installed"
  return 0
}

uninstall_pi() {
  _walkie_remove_wrapper pi
  if ! command -v pi &>/dev/null; then
    log_info "Pi Coding Agent is not installed"
    return 2
  fi

  confirm_remove_configs "Pi" \
    "$HOME/.pi"

  log_info "Uninstalling Pi Coding Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Pi Coding Agent" _uninstall_pi_impl

  log_success "Pi uninstalled"
  return 0
}

_uninstall_pi_impl() {
  _uninstall_pkg_fallback "@earendil-works/pi-coding-agent"
  return 0
}

update_pi() {
  _check_update_needed "Pi Coding Agent" "$(_get_installed_version pi)" "$(_get_remote_npm_version @earendil-works/pi-coding-agent)" _update_pi
}

_update_pi() {
  loading "Updating Pi Coding Agent" _update_pi_impl
}

_update_pi_impl() {
  if ! _install_pkg_fallback "@earendil-works/pi-coding-agent@latest" "--ignore-scripts"; then
    log_error "Failed to update Pi"
    return 1
  fi
  return 0
}

reinstall_pi() {
  uninstall_pi
  install_pi
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_pi; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_pi; fi
if [[ "${1:-}" == "update" ]]; then update_pi; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_pi; fi
