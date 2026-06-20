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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Shell dependencies installed"
  return 0
}

install_zsh_completions() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    log_info "zsh-completions already installed"
    return 0
  fi

  _zsh_completions_dependencies

  log_info "Installing shell prerequisites..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/zsh-users/zsh-completions.git" "$ZSH_PLUGINS_DIR/zsh-completions" &>>"$LOG_FILE"; then
    log_success "zsh-completions installed"
    return 0
  else
    log_error "Failed to install zsh-completions"
    return 1
  fi
}

uninstall_zsh_completions() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    log_info "zsh-completions is not installed"
    return 0
  fi

  log_info "Uninstalling zsh-completions..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/zsh-completions"
    log_success "zsh-completions uninstalled"
  else
    log_warn "zsh-completions not installed"
  fi
}

update_zsh_completions() {
  log_info "Updating zsh-completions..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/zsh-completions" pull &>>"$LOG_FILE"
    log_success "zsh-completions updated"
  else
    log_warn "zsh-completions not installed"
  fi
}

reinstall_zsh_completions() {
  uninstall_zsh_completions
  install_zsh_completions
}
