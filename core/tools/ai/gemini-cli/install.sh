#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"

# Source bun installer for dependency auto-install
_BUN_SAVED_LOG="$LOG_FILE"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lang/bun/install.sh"
LOG_FILE="$_BUN_SAVED_LOG"

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
  if ! bun install -g @google/gemini-cli &>>"$LOG_FILE"; then
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
  if ! command -v gemini &>/dev/null; then
    log_info "Gemini CLI is not installed"
    return 2
  fi
  log_info "Uninstalling Gemini CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Gemini CLI" _uninstall_gemini_cli_impl

  log_success "Gemini CLI uninstalled"
  return 0
}

_uninstall_gemini_cli_impl() {
  if ! bun uninstall -g @google/gemini-cli &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Gemini CLI"
    return 1
  fi
  return 0
}

update_gemini_cli() {
  _check_update_needed "Gemini CLI" "$(_get_installed_version gemini)" "$(_get_remote_npm_version @google/gemini-cli)" _update_gemini_cli
}

_update_gemini_cli() {
  loading "Updating Gemini CLI" _update_gemini_cli_impl
}

_update_gemini_cli_impl() {
  if ! bun install -g @google/gemini-cli@latest &>>"$LOG_FILE"; then
    log_error "Failed to update Gemini CLI"
    return 1
  fi
  return 0
}

reinstall_gemini_cli() {
  uninstall_gemini_cli
  install_gemini_cli
}
