#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
import "@/tools/lang/bun/install"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openclaude_dependencies() {
  loading "Installing dependencies" _openclaude_dependencies_impl
}

_openclaude_dependencies_impl() {
  declare -A DEPS=(
    ["git"]="git"
    ["ripgrep"]="rg"
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

_install_openclaude_bun() {
  loading "Installing OpenClaude" _install_openclaude_bun_impl
}

_install_openclaude_bun_impl() {
  if ! _install_pkg_fallback "@gitlawb/openclaude"; then
    log_error "Failed to install OpenClaude"
    return 1
  fi

  return 0
}

install_openclaude() {
  if command -v openclaude &>/dev/null; then
    log_info "OpenClaude is already installed"
    return 2
  fi
  log_info "Installing OpenClaude..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _openclaude_dependencies || return 1
  _install_openclaude_bun || return 1

  log_success "OpenClaude installed"
  return 0
}

uninstall_openclaude() {
  _walkie_remove_wrapper openclaude
  if ! command -v openclaude &>/dev/null; then
    log_info "OpenClaude is not installed"
    return 2
  fi

  confirm_remove_configs "OpenClaude" \
    "$HOME/.openclaude" \
    "$HOME/.openclaude.json"

  log_info "Uninstalling OpenClaude..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing OpenClaude" _uninstall_openclaude_impl

  log_success "OpenClaude uninstalled"
  return 0
}

_uninstall_openclaude_impl() {
  _uninstall_pkg_fallback "@gitlawb/openclaude"
  return 0
}

update_openclaude() {
  _check_update_needed "OpenClaude" "$(_get_installed_version openclaude)" "$(_get_remote_npm_version @gitlawb/openclaude)" _update_openclaude
}

_update_openclaude() {
  loading "Updating OpenClaude" _update_openclaude_impl
}

_update_openclaude_impl() {
  if ! _install_pkg_fallback "@gitlawb/openclaude@latest"; then
    log_error "Failed to update OpenClaude"
    return 1
  fi
  return 0
}

reinstall_openclaude() {
  uninstall_openclaude
  install_openclaude
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_openclaude; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_openclaude; fi
if [[ "${1:-}" == "update" ]]; then update_openclaude; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_openclaude; fi
