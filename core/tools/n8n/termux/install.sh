#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_auto.log"

_n8n_dependencies() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
    ["python"]="python"
    ["sqlite"]="sqlite"
    ["build-essential"]=""
    ["binutils"]=""
    ["make"]="make"
    ["clang"]="clang"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if [[ -n "$bin_name" ]] && command -v "$bin_name" &>/dev/null; then
      continue
    fi
    if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
      log_error "Failed to install $pkg_name"
      return 1
    fi
  done

  log_success "n8n dependencies installed"
  return 0
}

_install_n8n_impl() {
  _n8n_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if npm install -g n8n &>>"$LOG_FILE"; then
    log_success "n8n installed"
    return 0
  else
    log_error "Failed to install n8n"
    return 1
  fi
}

install_n8n() {
  if command -v n8n &>/dev/null; then
    log_info "n8n is already installed"
    return 0
  fi

  separator
  box_large "Installing n8n"
  separator
  echo

  log_info "Installing n8n..."
  loading "Installing n8n" _install_n8n_impl
}

_uninstall_n8n_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g n8n &>>"$LOG_FILE"; then
    log_success "n8n uninstalled"
    return 0
  else
    log_error "Failed to uninstall n8n"
    return 1
  fi
}

uninstall_n8n() {
  if ! command -v n8n &>/dev/null; then
    log_info "n8n is not installed"
    return 0
  fi

  separator
  box_large "Uninstalling n8n"
  separator
  echo

  confirm_remove_configs "n8n" \
    "$HOME/.n8n" \
    "$HOME/.cache/n8n"

  log_info "Uninstalling n8n..."
  loading "Uninstalling n8n" _uninstall_n8n_impl
}

_update_n8n() {
  loading "Updating n8n" _do_n8n_update
}

_do_n8n_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  npm update -g n8n &>>"$LOG_FILE"
}

update_n8n() {
  _check_update_needed "n8n" "$(_get_installed_version n8n)" "$(_get_remote_npm_version n8n)" _update_n8n
}

reinstall_n8n() {
  uninstall_n8n
  install_n8n
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_n8n; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_n8n; fi
if [[ "${1:-}" == "update" ]]; then update_n8n; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_n8n; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version n8n; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_npm_version n8n; fi
