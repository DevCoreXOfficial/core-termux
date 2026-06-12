#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

_better_npm_dependencies() {
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

install_better_npm() {
  if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
    log_info "zsh-better-npm-completion ${D_GREEN}already installed${NC}"
    return 0
  fi

  _better_npm_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/lukechilds/zsh-better-npm-completion.git" "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" &>>"$LOG_FILE"; then
    log_success "zsh-better-npm-completion installed"
    return 0
  else
    log_error "Failed to install zsh-better-npm-completion"
    return 1
  fi
}

uninstall_better_npm() {
  log_info "Uninstalling zsh-better-npm-completion..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/zsh-better-npm-completion"
    log_success "zsh-better-npm-completion uninstalled"
  else
    log_warn "zsh-better-npm-completion not installed"
  fi
}

update_better_npm() {
  log_info "Updating zsh-better-npm-completion..."

  if [[ -d "$ZSH_PLUGINS_DIR/zsh-better-npm-completion/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/zsh-better-npm-completion" pull &>>"$LOG_FILE"
    log_success "zsh-better-npm-completion updated"
  else
    log_warn "zsh-better-npm-completion not installed"
  fi
}

