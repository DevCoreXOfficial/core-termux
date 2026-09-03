#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"

_jcode_install_deps() {
  loading "Installing dependencies" _jcode_install_deps_impl
}

_jcode_install_deps_impl() {
  declare -A DEPS=(
    ["glibc"]="glibc"
    ["patchelf"]="patchelf"
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

_jcode_install_binary() {
  loading "Installing Jcode" _jcode_install_binary_impl
}

_jcode_install_binary_impl() {
  if ! curl -fsSL https://jcode.sh/install | bash &>>"$LOG_FILE"; then
    log_error "Failed to install Jcode"
    return 1
  fi
  return 0
}

install_jcode() {
  if command -v jcode &>/dev/null; then
    log_info "Jcode is already installed"
    return 2
  fi
  separator
  box_large "Installing Jcode"
  separator
  echo

  mkdir -p "$(dirname "$LOG_FILE")"

  _jcode_install_deps || return 1
  _jcode_install_binary || return 1

  log_success "Jcode installed"
  return 0
}

uninstall_jcode() {
  _walkie_remove_wrapper jcode
  if ! command -v jcode &>/dev/null; then
    log_info "Jcode is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling Jcode"
  separator
  echo

  confirm_remove_configs "Jcode" \
    "$HOME/.jcode" \
    "$HOME/.config/jcode"

  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Jcode" _uninstall_jcode_impl

  log_success "Jcode uninstalled"
  return 0
}

_uninstall_jcode_impl() {
  local jcode_bin
  jcode_bin="$(command -v jcode 2>/dev/null)"
  if [ -n "$jcode_bin" ] && [ -f "$jcode_bin" ]; then
    rm -f "$jcode_bin"
  fi
  # Also check common install locations
  rm -f "$HOME/.local/bin/jcode" 2>/dev/null
  return 0
}

update_jcode() {
  _check_update_needed "Jcode" "$(_get_installed_version jcode)" "$(_get_remote_github_version 1jehuang/jcode)" _update_jcode
}

_update_jcode() {
  loading "Updating Jcode" _update_jcode_impl
}

_update_jcode_impl() {
  if ! curl -fsSL https://jcode.sh/install | bash &>>"$LOG_FILE"; then
    log_error "Failed to update Jcode"
    return 1
  fi
  return 0
}

reinstall_jcode() {
  uninstall_jcode
  install_jcode
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_jcode; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_jcode; fi
if [[ "${1:-}" == "update" ]]; then update_jcode; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_jcode; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version jcode; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version 1jehuang/jcode; fi
