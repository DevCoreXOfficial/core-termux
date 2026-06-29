#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_you_should_use_dependencies() {
  declare -A DEPS=(
    ["zsh"]="zsh"
    ["zoxide"]="zoxide"
    ["git"]="git"
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

  log_success "Shell dependencies installed"
  return 0
}

_install_you_should_use_git() {
  loading "Installing zsh-you-should-use" _install_you_should_use_git_impl
}

_install_you_should_use_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/MichaelAquilina/zsh-you-should-use.git" "$ZSH_PLUGINS_DIR/zsh-you-should-use" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-you-should-use"
    return 1
  fi
  return 0
}

install_you_should_use() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
    log_info "zsh-you-should-use already installed"
    return 0
  fi

  _you_should_use_dependencies

  _install_you_should_use_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_you_should_use_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-you-should-use" ]]; then
    log_info "zsh-you-should-use is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-you-should-use"
}

uninstall_you_should_use() {
  loading "Uninstalling zsh-you-should-use" _uninstall_you_should_use_impl
}

_update_you_should_use_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-you-should-use/.git" ]]; then
    log_warn "zsh-you-should-use not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-you-should-use" pull &>>"$LOG_FILE"
}

update_you_should_use() {
  loading "Updating zsh-you-should-use" _update_you_should_use_impl
}

reinstall_you_should_use() {
  uninstall_you_should_use
  install_you_should_use
}
