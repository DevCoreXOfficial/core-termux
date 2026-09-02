#!/usr/bin/env bash

[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
import "@/utils/env"
import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_muse-code.log"
DATA_DIR="${HOME}/.local/share/muse-code"
OFFICIAL_URL="https://dev.meta.ai/install.sh"
CHANNEL_URL="https://api.meta.ai/muse-code/channels/muse-stable"

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

_muse_ubuntu_deps() {
  loading "Installing dependencies" _muse_ubuntu_deps_impl
}

_muse_ubuntu_deps_impl() {
  local pkgs=(curl bash)
  local p
  for p in "${pkgs[@]}"; do
    if ! command -v "$p" &>/dev/null; then
      if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$p" &>>"$LOG_FILE"; then
        # fallback without sudo if already root or no sudo
        apt-get update -qq &>>"$LOG_FILE" || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y "$p" &>>"$LOG_FILE" || return 1
      fi
    fi
  done
  return 0
}

install_muse_code() {
  if command -v muse-code &>/dev/null || command -v muse &>/dev/null; then
    log_info "Muse Code is already installed"
    return 2
  fi

  separator
  box_large "Installing Muse Code"
  separator
  echo

  _muse_ubuntu_deps || return 1

  loading "Downloading and installing Muse Code" _muse_ubuntu_install_impl

  if command -v muse-code &>/dev/null || command -v muse &>/dev/null; then
    log_success "Muse Code installed"
    echo
    list_item "Run: ${GRAY_19}muse-code${NC}  (alias: ${GRAY_19}muse${NC})"
    echo
    return 0
  else
    log_error "Installation finished but binary not found on PATH"
    log_info "Check log: $LOG_FILE"
    return 1
  fi
}

_muse_ubuntu_install_impl() {
  mkdir -p "$HOME/.local/bin"
  # Run the official installer - it outputs to stdout/stderr which loading captures
  if ! curl -fsSL "$OFFICIAL_URL" | bash; then
    log_error "Failed to install Muse Code"
    log_info "Check log: $LOG_FILE"
    return 1
  fi
  return 0
}

uninstall_muse_code() {
  separator
  box_large "Uninstalling Muse Code"
  separator
  echo

  if ! command -v muse-code &>/dev/null && ! command -v muse &>/dev/null && [[ ! -d "$DATA_DIR" ]]; then
    log_info "Muse Code is not installed"
    return 0
  fi

  confirm_remove_configs "Muse Code" \
    "$HOME/.config/muse" \
    "$HOME/.muse" \
    "$DATA_DIR" \
    "$HOME/.local/share/muse"

  log_info "Removing Muse Code..."

  # Try official uninstaller if present
  if command -v muse-code &>/dev/null; then
    muse-code uninstall &>>"$LOG_FILE" || true
  fi

  rm -f "$HOME/.local/bin/muse-code" "$HOME/.local/bin/muse" 2>/dev/null || true
  rm -rf "$DATA_DIR" "$HOME/.local/share/muse" "$HOME/.muse" 2>/dev/null || true

  log_success "Muse Code uninstalled"
  echo
}

_get_installed_muse_version() {
  local out
  out="$(muse-code --version 2>&1 || muse --version 2>&1 || true)"
  echo "$out" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[~.\-][Rr]?[0-9.]+' | head -1
  if [[ -z "$out" ]]; then
    _get_installed_version muse-code 2>/dev/null || _get_installed_version muse 2>/dev/null || true
  fi
}

_get_remote_muse_version() {
  local ver
  ver="$(curl -fsSL "$CHANNEL_URL" 2>/dev/null | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' | cut -d'"' -f4 | head -1)"
  if [[ -n "$ver" ]]; then
    echo "$ver"
    return 0
  fi
  curl -fsSL "https://dev.meta.ai/install.sh" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+~R[0-9.]+' | head -1 || true
}

_update_muse_code() {
  loading "Updating Muse Code" _update_muse_code_impl
}

_update_muse_code_impl() {
  if ! curl -fsSL "$OFFICIAL_URL" | bash &>>"$LOG_FILE"; then
    log_error "Failed to update Muse Code"
    return 1
  fi
  return 0
}

update_muse_code() {
  _check_update_needed "Muse Code" "$(_get_installed_muse_version)" "$(_get_remote_muse_version)" _update_muse_code
}

reinstall_muse_code() {
  uninstall_muse_code
  install_muse_code
}

if [[ "${1:-}" == "install" ]]; then install_muse_code; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_muse_code; fi
if [[ "${1:-}" == "update" ]]; then update_muse_code; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_muse_code; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_muse_version; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_muse_version; fi
