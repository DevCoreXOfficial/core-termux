#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_powerlevel10k_dependencies() {
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

_install_powerlevel10k_git() {
  loading "Installing powerlevel10k" _install_powerlevel10k_git_impl
}

_install_powerlevel10k_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$ZSH_PLUGINS_DIR/powerlevel10k" &>>"$LOG_FILE"; then
    log_error "Failed to install powerlevel10k"
    return 1
  fi
  return 0
}

install_powerlevel10k() {
  if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
    log_info "powerlevel10k already installed"
    return 0
  fi

  _powerlevel10k_dependencies

  _install_powerlevel10k_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_powerlevel10k_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
    log_info "powerlevel10k is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/powerlevel10k"
}

uninstall_powerlevel10k() {
  loading "Uninstalling powerlevel10k" _uninstall_powerlevel10k_impl
}

_update_powerlevel10k_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/powerlevel10k/.git" ]]; then
    log_warn "powerlevel10k not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/powerlevel10k" pull &>>"$LOG_FILE"
}

update_powerlevel10k() {
  loading "Updating powerlevel10k" _update_powerlevel10k_impl
}

reinstall_powerlevel10k() {
  uninstall_powerlevel10k
  install_powerlevel10k
}
