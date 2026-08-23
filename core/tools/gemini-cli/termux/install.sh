#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
source "$CORE_PATH/tools/bun/termux/lib.sh"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_gemini_cli_dependencies() {
  loading "Installing dependencies" _gemini_cli_dependencies_impl
}

_gemini_cli_dependencies_impl() {
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

_install_gemini_cli_bun() {
  loading "Installing Gemini CLI" _install_gemini_cli_bun_impl
}

_install_gemini_cli_bun_impl() {
  if ! _install_pkg_fallback "@google/gemini-cli"; then
    log_error "Failed to install Gemini CLI"
    return 1
  fi

  return 0
}

install_gemini_cli() {
  if command -v gemini &>/dev/null; then
    log_info "Gemini CLI is already installed"
    return 2
  fi

  log_info "Installing Gemini CLI..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _gemini_cli_dependencies || return 1
  _install_gemini_cli_bun || return 1

  log_success "Gemini CLI installed"
  return 0
}

uninstall_gemini_cli() {
  _walkie_remove_wrapper gemini
  if ! command -v gemini &>/dev/null; then
    log_info "Gemini CLI is not installed"
    return 2
  fi

  confirm_remove_configs "Gemini CLI" \
    "$HOME/.gemini"

  log_info "Uninstalling Gemini CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Gemini CLI" _uninstall_gemini_cli_impl

  log_success "Gemini CLI uninstalled"
  return 0
}

_uninstall_gemini_cli_impl() {
  _uninstall_pkg_fallback "@google/gemini-cli"
  return 0
}

update_gemini_cli() {
  _check_update_needed "Gemini CLI" "$(_get_installed_version gemini)" "$(_get_remote_npm_version @google/gemini-cli)" _update_gemini_cli
}

_update_gemini_cli() {
  loading "Updating Gemini CLI" _update_gemini_cli_impl
}

_update_gemini_cli_impl() {
  if ! _install_pkg_fallback "@google/gemini-cli@latest"; then
    log_error "Failed to update Gemini CLI"
    return 1
  fi
  return 0
}

reinstall_gemini_cli() {
  uninstall_gemini_cli
  install_gemini_cli
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_gemini_cli; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_gemini_cli; fi
if [[ "${1:-}" == "update" ]]; then update_gemini_cli; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_gemini_cli; fi
