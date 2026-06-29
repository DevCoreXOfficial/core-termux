#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_autopair_dependencies() {
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

_install_zsh_autopair_git() {
  loading "Installing zsh-autopair" _install_zsh_autopair_git_impl
}

_install_zsh_autopair_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/hlissner/zsh-autopair.git" "$ZSH_PLUGINS_DIR/zsh-autopair" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-autopair"
    return 1
  fi
  return 0
}

install_zsh_autopair() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
    log_info "zsh-autopair already installed"
    return 0
  fi

  _zsh_autopair_dependencies

  _install_zsh_autopair_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_zsh_autopair_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-autopair" ]]; then
    log_info "zsh-autopair is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-autopair"
}

uninstall_zsh_autopair() {
  loading "Uninstalling zsh-autopair" _uninstall_zsh_autopair_impl
}

_update_zsh_autopair_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-autopair/.git" ]]; then
    log_warn "zsh-autopair not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-autopair" pull &>>"$LOG_FILE"
}

update_zsh_autopair() {
  loading "Updating zsh-autopair" _update_zsh_autopair_impl
}

reinstall_zsh_autopair() {
  uninstall_zsh_autopair
  install_zsh_autopair
}
