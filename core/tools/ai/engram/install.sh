#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_engram_dependencies() {
  declare -A DEPS=(
    ["golang"]="go"
    ["git"]="git"
    ["sqlite"]="sqlite"
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

}

install_engram() {
  if command -v engram &>/dev/null; then
    log_info "Engram is already installed"
    return 0
  fi
  log_info "Installing Engram..."

  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  _engram_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  if git clone --quiet https://github.com/Gentleman-Programming/engram "$CORE_DATA/engram" && go build -C "$CORE_DATA/engram/cmd/engram" -o $PREFIX/bin/engram &>>"$LOG_FILE"; then
    log_success "Engram installed"
    return 0
  else
    log_error "Failed to install Engram"
    return 1
  fi
}

uninstall_engram() {
  log_info "Uninstalling Engram..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if rm -rf "$CORE_DATA/engram" && rm "$PREFIX/bin/engram" &>>"$LOG_FILE"; then
    log_success "Engram uninstalled"
    return 0
  else
    log_error "Failed to uninstall Engram"
    return 1
  fi
}

update_engram() {
  log_info "Updating Engram..."
  mkdir -p "$(dirname "$LOG_FILE")"
  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  if git -C "$CORE_DATA/engram" pull &>>"$LOG_FILE" && go build -C "$CORE_DATA/engram/cmd/engram" -o $PREFIX/bin/engram &>>"$LOG_FILE"; then
    log_success "Engram updated"
    return 0
  else
    log_error "Failed to update Engram"
    return 1
  fi
}

reinstall_engram() {
  uninstall_engram
  install_engram
}

