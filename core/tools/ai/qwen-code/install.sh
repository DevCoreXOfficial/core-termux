#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_qwen_code_dependencies() {
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

install_qwen_code() {
  if command -v qwen &>/dev/null; then
    log_info "Qwen Code is already installed"
    return 0
  fi

  log_info "Installing Qwen Code..."

  if ! _qwen_code_dependencies; then
    log_error "Prerequisites installation failed"
    return 1
  fi

  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  log_info "Running npm install for @qwen-code/qwen-code..."
  if npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_success "Qwen Code installed successfully"
    return 0
  else
    log_error "Failed to install Qwen Code"
    return 1
  fi
}

uninstall_qwen_code() {
  log_info "Uninstalling Qwen Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_success "Qwen Code uninstalled"
    return 0
  else
    log_error "Failed to uninstall Qwen Code"
    return 1
  fi
}

update_qwen_code() {
  log_info "Updating Qwen Code..."
  mkdir -p "$(dirname "$LOG_FILE")"
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  log_info "Running npm update for @qwen-code/qwen-code..."
  if npm update -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
    log_success "Qwen Code updated successfully"
    return 0
  else
    log_error "Failed to update Qwen Code"
    return 1
  fi
}

reinstall_qwen_code() {
  uninstall_qwen_code
  install_qwen_code
}
