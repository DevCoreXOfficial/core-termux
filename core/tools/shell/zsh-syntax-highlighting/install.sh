#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_zsh_syntax_highlighting_dependencies() {
  if command -v git &>/dev/null && command -v zsh &>/dev/null; then
    return 0
  fi

  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg install zsh zoxide git &>>"$LOG_FILE"
}

_install_zsh_syntax_highlighting_git() {
  loading "Installing zsh-syntax-highlighting" _install_zsh_syntax_highlighting_git_impl
}

_install_zsh_syntax_highlighting_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" &>>"$LOG_FILE"; then
    log_error "Failed to install zsh-syntax-highlighting"
    return 1
  fi
  return 0
}

install_zsh_syntax_highlighting() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
    log_info "zsh-syntax-highlighting already installed"
    return 0
  fi

  _zsh_syntax_highlighting_dependencies

  _install_zsh_syntax_highlighting_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_zsh_syntax_highlighting_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
    log_info "zsh-syntax-highlighting is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
}

uninstall_zsh_syntax_highlighting() {
  loading "Uninstalling zsh-syntax-highlighting" _uninstall_zsh_syntax_highlighting_impl
}

_update_zsh_syntax_highlighting_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/.git" ]]; then
    log_warn "zsh-syntax-highlighting not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" pull &>>"$LOG_FILE"
}

update_zsh_syntax_highlighting() {
  loading "Updating zsh-syntax-highlighting" _update_zsh_syntax_highlighting_impl
}

reinstall_zsh_syntax_highlighting() {
  uninstall_zsh_syntax_highlighting
  install_zsh_syntax_highlighting
}
