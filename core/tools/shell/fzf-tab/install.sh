#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_fzf_tab_dependencies() {
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

_install_fzf_tab_git() {
  loading "Installing fzf-tab" _install_fzf_tab_git_impl
}

_install_fzf_tab_git_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if ! git clone --depth=1 "https://github.com/Aloxaf/fzf-tab.git" "$ZSH_PLUGINS_DIR/fzf-tab" &>>"$LOG_FILE"; then
    log_error "Failed to install fzf-tab"
    return 1
  fi
  return 0
}

install_fzf_tab() {
  if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
    log_info "fzf-tab already installed"
    return 0
  fi

  _fzf_tab_dependencies

  _install_fzf_tab_git || return 1
  log_success "Installed"
  return 0
}

_uninstall_fzf_tab_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
    log_info "fzf-tab is not installed"
    return 0
  fi

  rm -rf "$ZSH_PLUGINS_DIR/fzf-tab"
}

uninstall_fzf_tab() {
  loading "Uninstalling fzf-tab" _uninstall_fzf_tab_impl
}

_update_fzf_tab_impl() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/fzf-tab/.git" ]]; then
    log_warn "fzf-tab not installed"
    return 0
  fi

  git -C "$ZSH_PLUGINS_DIR/fzf-tab" pull &>>"$LOG_FILE"
}

update_fzf_tab() {
  loading "Updating fzf-tab" _update_fzf_tab_impl
}

reinstall_fzf_tab() {
  uninstall_fzf_tab
  install_fzf_tab
}
