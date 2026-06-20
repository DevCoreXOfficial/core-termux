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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Shell dependencies installed"
  return 0
}

install_history_substring() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
    log_info "zsh-history-substring-search already installed"
    return 0
  fi

  _history_substring_dependencies

  log_info "Installing shell prerequisites..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/zsh-users/zsh-history-substring-search.git" "$ZSH_PLUGINS_DIR/zsh-history-substring-search" &>>"$LOG_FILE"; then
    log_success "zsh-history-substring-search installed"
    return 0
  else
    log_error "Failed to install zsh-history-substring-search"
    return 1
  fi
}

uninstall_history_substring() {
  log_info "Uninstalling zsh-history-substring-search..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
    log_success "zsh-history-substring-search uninstalled"
  else
    log_warn "zsh-history-substring-search not installed"
  fi
}

update_history_substring() {
  log_info "Updating zsh-history-substring-search..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/zsh-history-substring-search" pull &>>"$LOG_FILE"
    log_success "zsh-history-substring-search updated"
  else
    log_warn "zsh-history-substring-search not installed"
  fi
}

reinstall_history_substring() {
  uninstall_history_substring
  install_history_substring
}
