#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_history_substring_dependencies() {
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

_install_history_substring_git() {
  loading "Installing zsh-history-substring-search" _install_history_substring_git_impl
}

_install_history_substring_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/zsh-users/zsh-history-substring-search.git" "$ZSH_PLUGINS_DIR/zsh-history-substring-search" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-history-substring-search"
    return 1
  fi
  return 0
}

install_history_substring() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
    log_info "zsh-history-substring-search already installed"
    return 0
  fi

  _history_substring_dependencies

  _install_history_substring_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_history_substring_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
    log_info "zsh-history-substring-search is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
}

uninstall_history_substring() {
  loading "Uninstalling zsh-history-substring-search" _uninstall_history_substring_impl
}

_update_history_substring_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search/.git" ]]; then
    log_warn "zsh-history-substring-search not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-history-substring-search" pull &>>"$LOG_FILE"
}

update_history_substring() {
  loading "Updating zsh-history-substring-search" _update_history_substring_impl
}

reinstall_history_substring() {
  uninstall_history_substring
  install_history_substring
}
