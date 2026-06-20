#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openclaude_dependencies() {
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

install_openclaude() {
  if command -v openclaude &>/dev/null; then
    log_info "OpenClaude is already installed"
    return 0
  fi
  log_info "Installing OpenClaude..."

  _openclaude_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if npm install -g @gitlawb/openclaude &>>"$LOG_FILE"; then
    log_success "OpenClaude installed"
    return 0
  else
    log_error "Failed to install OpenClaude"
    return 1
  fi
}

uninstall_openclaude() {
  log_info "Uninstalling OpenClaude..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g @gitlawb/openclaude &>>"$LOG_FILE"; then
    log_success "OpenClaude uninstalled"
    return 0
  else
    log_error "Failed to uninstall OpenClaude"
    return 1
  fi
}

update_openclaude() {
  log_info "Updating OpenClaude..."
  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if npm update -g @gitlawb/openclaude &>>"$LOG_FILE"; then
    log_success "OpenClaude updated"
    return 0
  else
    log_error "Failed to update OpenClaude"
    return 1
  fi
}

reinstall_openclaude() {
  uninstall_openclaude
  install_openclaude
}
