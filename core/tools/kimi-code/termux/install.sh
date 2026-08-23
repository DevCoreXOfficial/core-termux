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

_kimi_code_dependencies() {
  loading "Installing dependencies" _kimi_code_dependencies_impl
}

_kimi_code_dependencies_impl() {
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

_install_kimi_code_bun() {
  loading "Installing Kimi Code" _install_kimi_code_bun_impl
}

_install_kimi_code_bun_impl() {
  if ! _install_pkg_fallback "@moonshot-ai/kimi-code"; then
    log_error "Failed to install Kimi Code"
    return 1
  fi

  return 0
}

install_kimi_code() {
  if command -v kimi &>/dev/null; then
    log_info "Kimi Code is already installed"
    return 2
  fi

  log_info "Installing Kimi Code..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _kimi_code_dependencies || return 1
  _install_kimi_code_bun || return 1

  log_success "Kimi Code installed successfully"
  return 0
}

uninstall_kimi_code() {
  _walkie_remove_wrapper kimi kimi-code
  if ! command -v kimi &>/dev/null; then
    log_success "Kimi Code is not installed"
    return 2
  fi

  confirm_remove_configs "Kimi Code" \
    "$HOME/.kimi" \
    "$HOME/.kimi-code"

  log_info "Uninstalling Kimi Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Kimi Code" _uninstall_kimi_code_impl

  log_success "Kimi Code uninstalled successfully"
  return 0
}

_uninstall_kimi_code_impl() {
  _uninstall_pkg_fallback "@moonshot-ai/kimi-code"
  return 0
}

update_kimi_code() {
  _check_update_needed "Kimi Code" "$(_get_installed_version kimi)" "$(_get_remote_npm_version @moonshot-ai/kimi-code)" _update_kimi_code
}

_update_kimi_code() {
  loading "Updating Kimi Code" _update_kimi_code_impl
}

_update_kimi_code_impl() {
  if ! _install_pkg_fallback "@moonshot-ai/kimi-code@latest"; then
    log_error "Failed to update Kimi Code"
    return 1
  fi
  return 0
}

reinstall_kimi_code() {
  uninstall_kimi_code
  install_kimi_code
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_kimi_code; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_kimi_code; fi
if [[ "${1:-}" == "update" ]]; then update_kimi_code; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_kimi_code; fi
