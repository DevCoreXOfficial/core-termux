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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Shell dependencies installed"
  return 0
}

install_powerlevel10k() {
  if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
    log_info "powerlevel10k already installed"
    return 0
  fi
  log_info "Installing powerlevel10k..."

  _powerlevel10k_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$ZSH_PLUGINS_DIR/powerlevel10k" &>>"$LOG_FILE"; then
    log_success "powerlevel10k installed"
    return 0
  else
    log_error "Failed to install powerlevel10k"
    return 1
  fi
}

uninstall_powerlevel10k() {
  log_info "Uninstalling powerlevel10k..."

  if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/powerlevel10k"
    log_success "powerlevel10k uninstalled"
  else
    log_warn "powerlevel10k not installed"
  fi
}

update_powerlevel10k() {
  log_info "Updating powerlevel10k..."

  if [[ -d "$ZSH_PLUGINS_DIR/powerlevel10k/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/powerlevel10k" pull &>>"$LOG_FILE"
    log_success "powerlevel10k updated"
  else
    log_warn "powerlevel10k not installed"
  fi
}

reinstall_powerlevel10k() {
  uninstall_powerlevel10k
  install_powerlevel10k
}
