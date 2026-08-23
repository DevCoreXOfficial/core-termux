#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/tools/lang/bun/install"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_minimax_cli_dependencies() {
  loading "Installing dependencies" _minimax_cli_dependencies_impl
}

_minimax_cli_dependencies_impl() {
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

_install_minimax_cli_bun() {
  loading "Installing MiniMax CLI" _install_minimax_cli_bun_impl
}

_install_minimax_cli_bun_impl() {
  if ! _install_pkg_fallback "mmx-cli"; then
    log_error "Failed to install MiniMax CLI"
    return 1
  fi

  return 0
}

install_minimax_cli() {
  if command -v mmx &>/dev/null; then
    log_info "MiniMax CLI is already installed"
    return 2
  fi

  log_info "Installing MiniMax CLI..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _minimax_cli_dependencies || return 1
  _install_minimax_cli_bun || return 1

  log_success "MiniMax CLI installed successfully"
  return 0
}

uninstall_minimax_cli() {
  _walkie_remove_wrapper minimax mmx
  if ! command -v mmx &>/dev/null; then
    log_success "MiniMax CLI is not installed"
    return 2
  fi

  confirm_remove_configs "MiniMax" \
    "$HOME/.mmx"

  log_info "Uninstalling MiniMax CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing MiniMax CLI" _uninstall_minimax_cli_impl

  log_success "MiniMax CLI uninstalled successfully"
  return 0
}

_uninstall_minimax_cli_impl() {
  _uninstall_pkg_fallback "mmx-cli"
  return 0
}

update_minimax_cli() {
  _check_update_needed "MiniMax CLI" "$(_get_installed_version mmx)" "$(_get_remote_npm_version mmx-cli)" _update_minimax_cli
}

_update_minimax_cli() {
  loading "Updating MiniMax CLI" _update_minimax_cli_impl
}

_update_minimax_cli_impl() {
  if ! _install_pkg_fallback "mmx-cli@latest"; then
    log_error "Failed to update MiniMax CLI"
    return 1
  fi
  return 0
}

reinstall_minimax_cli() {
  uninstall_minimax_cli
  install_minimax_cli
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_minimax_cli; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_minimax_cli; fi
if [[ "${1:-}" == "update" ]]; then update_minimax_cli; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_minimax_cli; fi
