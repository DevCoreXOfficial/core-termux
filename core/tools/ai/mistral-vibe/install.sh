#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_mistral_vibe_dependencies() {
  declare -A DEPS=(
    ["python"]="python"
    ["clang"]="clang"
    ["make"]="make"
    ["rust"]="rust"
    ["libffi"]=""
    ["openssl"]=""
    ["pkg-config"]=""
    ["git"]="git"
    ["ripgrep"]="rg"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if [[ -n "$bin_name" ]] && command -v "$bin_name" &>/dev/null; then
      continue
    fi
    if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
      log_error "Failed to install $pkg_name"
      return 1
    fi
  done

  pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
  log_success "Python and pip prerequisites installed"
  return 0
}

install_mistral_vibe() {
  if command -v vibe &>/dev/null; then
    log_info "Mistral Vibe is already installed"
    return 2
  fi

  log_info "Installing Mistral Vibe..."

  _mistral_vibe_dependencies
  export ANDROID_API_LEVEL=24
	export GYP_DEFINES="android_ndk_path=''"

  mkdir -p "$(dirname "$LOG_FILE")"

  if pip install mistral-vibe &>>"$LOG_FILE"; then
    log_success "Mistral Vibe installed"
    return 0
  else
    log_error "Failed to install Mistral Vibe"
    return 1
  fi
}

uninstall_mistral_vibe() {
  if ! command -v vibe &>/dev/null; then
    log_info "Mistral Vibe is not installed"
    return 2
  fi
  log_info "Uninstalling Mistral Vibe..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if pip uninstall mistral-vibe -y &>>"$LOG_FILE"; then
    log_success "Mistral Vibe uninstalled"
    return 0
  else
    log_error "Failed to uninstall Mistral Vibe"
    return 1
  fi
}

update_mistral_vibe() {
  log_info "Updating Mistral Vibe..."
  mkdir -p "$(dirname "$LOG_FILE")"

  export ANDROID_API_LEVEL=24
	export GYP_DEFINES="android_ndk_path=''"

  if pip install --upgrade mistral-vibe &>>"$LOG_FILE"; then
    log_success "Mistral Vibe updated"
    return 0
  else
    log_error "Failed to update Mistral Vibe"
    return 1
  fi
}

reinstall_mistral_vibe() {
  uninstall_mistral_vibe
  install_mistral_vibe
}
