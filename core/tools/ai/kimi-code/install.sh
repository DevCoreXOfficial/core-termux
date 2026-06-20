#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_kimi_code_dependencies() {
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

install_kimi_code() {
  if command -v kimi &>/dev/null; then
    log_info "Kimi Code is already installed"
    return 2
  fi

  log_info "Installing Kimi Code..."

  if _kimi_code_dependencies; then
    mkdir -p "$(dirname "$LOG_FILE")"

    if npm install -g @moonshot-ai/kimi-code &>>"$LOG_FILE"; then
      log_success "Kimi Code installed successfully"
      return 0
    else
      log_error "Failed to install Kimi Code"
      return 1
    fi
  else
    log_error "Failed to install prerequisites for Kimi Code"
    return 1
  fi
}

uninstall_kimi_code() {
  if ! command -v kimi &>/dev/null; then
    log_success "Kimi Code is not installed"
    return 2
  fi

  log_info "Uninstalling Kimi Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g @moonshot-ai/kimi-code &>>"$LOG_FILE"; then
    log_success "Kimi Code uninstalled successfully"
    return 0
  else
    log_error "Failed to uninstall Kimi Code"
    return 1
  fi
}

update_kimi_code() {
  if ! command -v kimi &>/dev/null; then
    log_error "Kimi Code is not installed"
    return 1
  fi

  log_info "Updating Kimi Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm update -g @moonshot-ai/kimi-code &>>"$LOG_FILE"; then
    log_success "Kimi Code updated successfully"
    return 0
  else
    log_error "Failed to update Kimi Code"
    return 1
  fi
}

reinstall_kimi_code() {
  uninstall_kimi_code
  install_kimi_code
}
