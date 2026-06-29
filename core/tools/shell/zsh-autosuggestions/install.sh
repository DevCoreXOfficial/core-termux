#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_autosuggestions_dependencies() {
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

_install_zsh_autosuggestions_git() {
  loading "Installing zsh-autosuggestions" _install_zsh_autosuggestions_git_impl
}

_install_zsh_autosuggestions_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_PLUGINS_DIR/zsh-autosuggestions" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-autosuggestions"
    return 1
  fi
  return 0
}

install_zsh_autosuggestions() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
    log_info "zsh-autosuggestions already installed"
    return 0
  fi

  _zsh_autosuggestions_dependencies

  _install_zsh_autosuggestions_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_zsh_autosuggestions_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
    log_info "zsh-autosuggestions is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
}

uninstall_zsh_autosuggestions() {
  loading "Uninstalling zsh-autosuggestions" _uninstall_zsh_autosuggestions_impl
}

_update_zsh_autosuggestions_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions/.git" ]]; then
    log_warn "zsh-autosuggestions not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-autosuggestions" pull &>>"$LOG_FILE"
}

update_zsh_autosuggestions() {
  loading "Updating zsh-autosuggestions" _update_zsh_autosuggestions_impl
}

reinstall_zsh_autosuggestions() {
  uninstall_zsh_autosuggestions
  install_zsh_autosuggestions
}
