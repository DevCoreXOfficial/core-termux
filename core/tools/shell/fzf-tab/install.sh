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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Shell dependencies installed"
  return 0
}

install_fzf_tab() {
  if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
    log_info "fzf-tab already installed"
    return 0
  fi

  _fzf_tab_dependencies

  log_info "Installing shell prerequisites..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --depth=1 "https://github.com/Aloxaf/fzf-tab.git" "$ZSH_PLUGINS_DIR/fzf-tab" &>>"$LOG_FILE"; then
    log_success "fzf-tab installed"
    return 0
  else
    log_error "Failed to install fzf-tab"
    return 1
  fi
}

uninstall_fzf_tab() {
  if [[ ! -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
    log_info "fzf-tab is not installed"
    return 0
  fi

  log_info "Uninstalling fzf-tab..."

  if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
    rm -rf "$ZSH_PLUGINS_DIR/fzf-tab"
    log_success "fzf-tab uninstalled"
  else
    log_warn "fzf-tab not installed"
  fi
}

update_fzf_tab() {
  log_info "Updating fzf-tab..."

  if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab/.git" ]]; then
    git -C "$ZSH_PLUGINS_DIR/fzf-tab" pull &>>"$LOG_FILE"
    log_success "fzf-tab updated"
  else
    log_warn "fzf-tab not installed"
  fi
}

reinstall_fzf_tab() {
  uninstall_fzf_tab
  install_fzf_tab
}
