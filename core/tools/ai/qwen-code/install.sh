#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_qwen_code_dependencies() {
  loading "Installing dependencies" _qwen_code_dependencies_impl
}

_qwen_code_dependencies_impl() {
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

_install_qwen_code_npm() {
  loading "Installing Qwen Code" _install_qwen_code_npm_impl
}

_install_qwen_code_npm_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if ! npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_error "Failed to install Qwen Code"
    return 1
  fi

  return 0
}

install_qwen_code() {
  if command -v qwen &>/dev/null; then
    log_info "Qwen Code is already installed"
    return 2
  fi

  log_info "Installing Qwen Code..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _qwen_code_dependencies || return 1
  _install_qwen_code_npm || return 1

  log_success "Qwen Code installed successfully"
  return 0
}

uninstall_qwen_code() {
  if ! command -v qwen &>/dev/null; then
    log_info "Qwen Code is not installed"
    return 2
  fi
  log_info "Uninstalling Qwen Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Qwen Code" _uninstall_qwen_code_impl

  log_success "Qwen Code uninstalled"
  return 0
}

_uninstall_qwen_code_impl() {
  if ! npm uninstall -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Qwen Code"
    return 1
  fi
  return 0
}

update_qwen_code() {
  log_info "Updating Qwen Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating Qwen Code" _update_qwen_code_impl

  log_success "Qwen Code updated successfully"
  return 0
}

_update_qwen_code_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if ! npm update -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_error "Failed to update Qwen Code"
    return 1
  fi
  return 0
}

reinstall_qwen_code() {
  uninstall_qwen_code
  install_qwen_code
}
