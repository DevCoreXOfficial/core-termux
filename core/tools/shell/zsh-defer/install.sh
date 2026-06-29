#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_defer_dependencies() {
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

_install_zsh_defer_git() {
  loading "Installing zsh-defer" _install_zsh_defer_git_impl
}

_install_zsh_defer_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/romkatv/zsh-defer.git" "$ZSH_PLUGINS_DIR/zsh-defer" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-defer"
    return 1
  fi
  return 0
}

install_zsh_defer() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-defer" ]]; then
    log_info "zsh-defer already installed"
    return 0
  fi

  _zsh_defer_dependencies

  _install_zsh_defer_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_zsh_defer_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-defer" ]]; then
    log_info "zsh-defer is not installed"
    return 2
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-defer"
}

uninstall_zsh_defer() {
  loading "Uninstalling zsh-defer" _uninstall_zsh_defer_impl
}

_update_zsh_defer_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-defer/.git" ]]; then
    log_warn "zsh-defer not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-defer" pull &>>"$LOG_FILE"
}

update_zsh_defer() {
  loading "Updating zsh-defer" _update_zsh_defer_impl
}

reinstall_zsh_defer() {
  uninstall_zsh_defer
  install_zsh_defer
}
