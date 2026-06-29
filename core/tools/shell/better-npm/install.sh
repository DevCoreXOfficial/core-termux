#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_better_npm_dependencies() {
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

_install_better_npm_git() {
  loading "Installing zsh-better-npm-completion" _install_better_npm_git_impl
}

_install_better_npm_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/lukechilds/zsh-better-npm-completion.git" "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-better-npm-completion"
    return 1
  fi
  return 0
}

install_better_npm() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
    log_info "zsh-better-npm-completion already installed"
    return 0
  fi

  _better_npm_dependencies

  _install_better_npm_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_better_npm_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
    log_info "zsh-better-npm-completion is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-better-npm-completion"
}

uninstall_better_npm() {
  loading "Uninstalling zsh-better-npm-completion" _uninstall_better_npm_impl
}

_update_better_npm_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion/.git" ]]; then
    log_warn "zsh-better-npm-completion not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" pull &>>"$LOG_FILE"
}

update_better_npm() {
  loading "Updating zsh-better-npm-completion" _update_better_npm_impl
}

reinstall_better_npm() {
  uninstall_better_npm
  install_better_npm
}
