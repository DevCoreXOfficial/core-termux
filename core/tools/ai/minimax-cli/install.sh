#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

minimax_cli_dependencies() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
    ["git"]="git"
    ["ripgrep"]="rg"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Dependencies installed"
  return 0
}

install_minimax_cli() {
  if command -v mmx &>/dev/null; then
    log_success "MiniMax CLI is already installed"
    return 0
  fi

  log_info "Installing MiniMax CLI..."

  if minimax_cli_dependencies; then
    mkdir -p "$(dirname "$LOG_FILE")"

    if npm install -g mmx-cli &>>"$LOG_FILE"; then
      log_success "MiniMax CLI installed successfully"
      return 0
    else
      log_error "Failed to install MiniMax CLI"
      return 1
    fi
  else
    log_error "Failed to install prerequisites for MiniMax CLI"
    return 1
  fi
}

uninstall_minimax_cli() {
  if ! command -v mmx &>/dev/null; then
    log_success "MiniMax CLI is not installed"
    return 0
  fi

  log_info "Uninstalling MiniMax CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g mmx-cli &>>"$LOG_FILE"; then
    log_success "MiniMax CLI uninstalled successfully"
    return 0
  else
    log_error "Failed to uninstall MiniMax CLI"
    return 1
  fi
}

update_minimax_cli() {
  if ! command -v mmx &>/dev/null; then
    log_error "MiniMax CLI is not installed"
    return 1
  fi

  log_info "Updating MiniMax CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g mmx-cli &>>"$LOG_FILE"; then
    log_success "MiniMax CLI updated successfully"
    return 0
  else
    log_error "Failed to update MiniMax CLI"
    return 1
  fi
}
