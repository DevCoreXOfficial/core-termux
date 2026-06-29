#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

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
  log_info "Uninstalling n8n..."
  loading "Uninstalling n8n" _uninstall_n8n_impl
}

_update_n8n_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if npm update -g n8n &>>"$LOG_FILE"; then
    log_success "n8n updated"
    return 0
  else
    log_error "Failed to update n8n"
    return 1
  fi
}

update_n8n() {
  log_info "Updating n8n..."
  loading "Updating n8n" _update_n8n_impl
}

reinstall_n8n() {
  uninstall_n8n
  install_n8n
}
