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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Shell dependencies installed"
  return 0
}

install_zsh_autosuggestions() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
    log_info "zsh-autosuggestions already installed"
    return 0
  fi

  _zsh_autosuggestions_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_PLUGINS_DIR/zsh-autosuggestions" &>>"$LOG_FILE"; then
    log_success "zsh-autosuggestions installed"
    return 0
  else
    log_error "Failed to install zsh-autosuggestions"
    return 1
  fi
}

uninstall_zsh_autosuggestions() {
  log_info "Uninstalling zsh-autosuggestions..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    log_success "zsh-autosuggestions uninstalled"
  else
    log_warn "zsh-autosuggestions not installed"
  fi
}

update_zsh_autosuggestions() {
  log_info "Updating zsh-autosuggestions..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/zsh-autosuggestions" pull &>>"$LOG_FILE"
    log_success "zsh-autosuggestions updated"
  else
    log_warn "zsh-autosuggestions not installed"
  fi
}

reinstall_zsh_autosuggestions() {
  uninstall_zsh_autosuggestions
  install_zsh_autosuggestions
}
