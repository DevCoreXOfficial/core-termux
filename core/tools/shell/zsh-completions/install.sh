#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_completions_dependencies() {
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

_install_zsh_completions_git() {
  loading "Installing zsh-completions" _install_zsh_completions_git_impl
}

_install_zsh_completions_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/zsh-users/zsh-completions.git" "$ZSH_PLUGINS_DIR/zsh-completions" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-completions"
    return 1
  fi
  return 0
}

install_zsh_completions() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    log_info "zsh-completions already installed"
    return 0
  fi

  _zsh_completions_dependencies

  _install_zsh_completions_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_zsh_completions_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    log_info "zsh-completions is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-completions"
}

uninstall_zsh_completions() {
  loading "Uninstalling zsh-completions" _uninstall_zsh_completions_impl
}

_update_zsh_completions_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-completions/.git" ]]; then
    log_warn "zsh-completions not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-completions" pull &>>"$LOG_FILE"
}

update_zsh_completions() {
  loading "Updating zsh-completions" _update_zsh_completions_impl
}

reinstall_zsh_completions() {
  uninstall_zsh_completions
  install_zsh_completions
}
