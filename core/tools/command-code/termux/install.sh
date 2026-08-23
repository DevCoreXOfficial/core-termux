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
COMMAND_CODE_DATA_DIR="$HOME/.local/share/core-termux-data/command-code"

_command_code_dependencies() {
  loading "Installing dependencies" _command_code_dependencies_impl
}

_command_code_dependencies_impl() {
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

_install_command_code_bun() {
  loading "Installing command-code via bun" _install_command_code_bun_impl
}

_install_command_code_bun_impl() {
  if ! _install_pkg_fallback_local "$COMMAND_CODE_DATA_DIR" "command-code@latest"; then
    log_error "Failed to install command-code package"
    return 1
  fi

  return 0
}

_install_command_code_wrappers() {
  loading "Creating command-code and cmdc wrappers" _install_command_code_wrappers_impl
}

_install_command_code_wrappers_impl() {
  local wrapper_content='#!/data/data/com.termux/files/usr/bin/bash

exec bun '"$COMMAND_CODE_DATA_DIR"'/node_modules/command-code/dist/index.mjs "$@"'

  echo "$wrapper_content" >"$PREFIX/bin/command-code"
  chmod +x "$PREFIX/bin/command-code"

  ln -sf "$PREFIX/bin/command-code" "$PREFIX/bin/cmdc"

  return 0
}

install_command_code() {
  if command -v command-code &>/dev/null; then
    log_info "Command Code is already installed"
    return 2
  fi

  log_info "Installing Command Code..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _command_code_dependencies || return 1
  _install_command_code_bun || return 1
  _install_command_code_wrappers || return 1

  log_success "Command Code installed successfully"
  return 0
}

uninstall_command_code() {
  _walkie_remove_wrapper command-code
  if ! command -v command-code &>/dev/null; then
    log_info "Command Code is not installed"
    return 2
  fi

  confirm_remove_configs "Command Code" \
    "$HOME/.commandcode"

  log_info "Uninstalling Command Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Command Code files" _uninstall_command_code_impl

  log_success "Command Code uninstalled"
  return 0
}

_uninstall_command_code_impl() {
  rm -f "$PREFIX/bin/command-code"
  rm -f "$PREFIX/bin/cmdc"
  rm -rf "$COMMAND_CODE_DATA_DIR"
  return 0
}

update_command_code() {
  _check_update_needed "Command Code" "$(_get_installed_version command-code)" "$(_get_remote_npm_version command-code)" _update_command_code
}

_update_command_code() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -d "$COMMAND_CODE_DATA_DIR" ]; then
    log_warn "Command Code is not installed"
    return 1
  fi

  loading "Updating command-code package" _update_command_code_impl

  log_success "Command Code updated"
  return 0
}

_update_command_code_impl() {
  if [ ! -d "$COMMAND_CODE_DATA_DIR/node_modules" ]; then
    # Not installed yet — do a fresh install
    _install_command_code_bun_impl
    return $?
  fi

  # Try bun first
  if (cd "$COMMAND_CODE_DATA_DIR" && bun install command-code@latest &>>"$LOG_FILE"); then
    return 0
  fi

  # Fall back to npm
  log_warn "bun update failed for command-code, falling back to npm..."
  if ! command -v npm &>/dev/null; then
    if ! yes | pkg install nodejs-lts &>>"$LOG_FILE"; then
      log_error "Failed to install Node.js/npm for fallback"
      return 1
    fi
  fi

  if (cd "$COMMAND_CODE_DATA_DIR" && npm install command-code@latest &>>"$LOG_FILE"); then
    return 0
  fi

  log_error "Failed to update Command Code"
  return 1
}

reinstall_command_code() {
  uninstall_command_code
  install_command_code
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_command_code; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_command_code; fi
if [[ "${1:-}" == "update" ]]; then update_command_code; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_command_code; fi
