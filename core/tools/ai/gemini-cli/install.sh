#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_gemini_cli_dependencies() {
  loading "Installing dependencies" _gemini_cli_dependencies_impl
}

_gemini_cli_dependencies_impl() {
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

_install_gemini_cli_npm() {
  loading "Installing Gemini CLI" _install_gemini_cli_npm_impl
}

_install_gemini_cli_npm_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if ! npm install -g @google/gemini-cli &>>"$LOG_FILE"; then
    log_error "Failed to install Gemini CLI"
    return 1
  fi

  return 0
}

install_gemini_cli() {
  if command -v gemini &>/dev/null; then
    log_info "Gemini CLI is already installed"
    return 2
  fi

  log_info "Installing Gemini CLI..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _gemini_cli_dependencies || return 1
  _install_gemini_cli_npm || return 1

  log_success "Gemini CLI installed"
  return 0
}

uninstall_gemini_cli() {
  if ! command -v gemini &>/dev/null; then
    log_info "Gemini CLI is not installed"
    return 2
  fi
  log_info "Uninstalling Gemini CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Gemini CLI" _uninstall_gemini_cli_impl

  log_success "Gemini CLI uninstalled"
  return 0
}

_uninstall_gemini_cli_impl() {
  if ! npm uninstall -g @google/gemini-cli &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Gemini CLI"
    return 1
  fi
  return 0
}

update_gemini_cli() {
  log_info "Updating Gemini CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating Gemini CLI" _update_gemini_cli_impl

  log_success "Gemini CLI updated"
  return 0
}

_update_gemini_cli_impl() {
  export GYP_DEFINES="android_ndk_path=''"
  export ANDROID_API_LEVEL=24

  if ! npm update -g @google/gemini-cli &>>"$LOG_FILE"; then
    log_error "Failed to update Gemini CLI"
    return 1
  fi
  return 0
}

reinstall_gemini_cli() {
  uninstall_gemini_cli
  install_gemini_cli
}
