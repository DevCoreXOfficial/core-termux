#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openclaw_dependencies() {
  loading "Installing dependencies" _openclaw_dependencies_impl
}

_openclaw_dependencies_impl() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
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

  return 0
}

_install_openclaw_npm() {
  loading "Installing OpenClaw and dependencies" _install_openclaw_npm_impl
}

_install_openclaw_npm_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  npm install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

  if ! npm install -g openclaw@latest &>>"$LOG_FILE"; then
    log_error "Failed to install OpenClaw"
    return 1
  fi

  return 0
}

install_openclaw() {
  if command -v openclaw &>/dev/null; then
    log_info "OpenClaw is already installed"
    return 2
  fi
  log_info "Installing OpenClaw..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _openclaw_dependencies || return 1
  _install_openclaw_npm || return 1

  log_success "OpenClaw installed"
  return 0
}

uninstall_openclaw() {
  if ! command -v openclaw &>/dev/null; then
    log_info "OpenClaw is not installed"
    return 2
  fi
  log_info "Uninstalling OpenClaw..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing OpenClaw" _uninstall_openclaw_impl

  log_success "OpenClaw uninstalled"
  return 0
}

_uninstall_openclaw_impl() {
  if ! npm uninstall -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
    log_error "Failed to uninstall OpenClaw"
    return 1
  fi
  return 0
}

update_openclaw() {
  log_info "Updating OpenClaw..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating OpenClaw" _update_openclaw_impl

  log_success "OpenClaw updated"
  return 0
}

_update_openclaw_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if ! npm update -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
    log_error "Failed to update OpenClaw"
    return 1
  fi
  return 0
}

reinstall_openclaw() {
  uninstall_openclaw
  install_openclaw
}
