#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/tools/lang/bun/install"

LOG_FILE="$CORE_CACHE/install_ai.log"

_openclaw_dependencies() {
  loading "Installing dependencies" _openclaw_dependencies_impl
}

_openclaw_dependencies_impl() {
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

_install_openclaw_bun() {
  loading "Installing OpenClaw and dependencies" _install_openclaw_bun_impl
}

_install_openclaw_bun_impl() {
  bun install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

  if ! bun install -g openclaw@latest &>>"$LOG_FILE"; then
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
  _install_openclaw_bun || return 1

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
  bun uninstall -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

  if ! bun uninstall -g openclaw &>>"$LOG_FILE"; then
    log_error "Failed to uninstall OpenClaw"
    return 1
  fi
  return 0
}

update_openclaw() {
  _check_update_needed "OpenClaw" "$(_get_installed_version openclaw)" "$(_get_remote_npm_version openclaw)" _update_openclaw
}

_update_openclaw() {
  loading "Updating OpenClaw" _update_openclaw_impl
}

_update_openclaw_impl() {
  bun install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

  if ! bun install -g openclaw@latest &>>"$LOG_FILE"; then
    log_error "Failed to update OpenClaw"
    return 1
  fi
  return 0
}

reinstall_openclaw() {
  uninstall_openclaw
  install_openclaw
}
