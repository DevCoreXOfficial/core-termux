#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_engram_dependencies() {
  loading "Installing dependencies" _engram_dependencies_impl
}

_engram_dependencies_impl() {
  declare -A DEPS=(
    ["golang"]="go"
    ["git"]="git"
    ["sqlite"]="sqlite3"
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

  return 0
}

_clone_engram_repo() {
  loading "Cloning engram repository" _clone_engram_repo_impl
}

_clone_engram_repo_impl() {
  if ! git clone --quiet https://github.com/Gentleman-Programming/engram "$CORE_DATA/engram" &>>"$LOG_FILE"; then
    log_error "Failed to clone engram repository"
    return 1
  fi

  return 0
}

_build_engram() {
  loading "Building engram binary" _build_engram_impl
}

_build_engram_impl() {
  if ! go build -C "$CORE_DATA/engram/cmd/engram" -o $PREFIX/bin/engram &>>"$LOG_FILE"; then
    log_error "Failed to build engram"
    return 1
  fi

  return 0
}

install_engram() {
  if command -v engram &>/dev/null; then
    log_info "Engram is already installed"
    return 2
  fi
  log_info "Installing Engram..."

  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  mkdir -p "$(dirname "$LOG_FILE")"

  _engram_dependencies || return 1
  _clone_engram_repo || return 1
  _build_engram || return 1

  log_success "Engram installed"
  return 0
}

uninstall_engram() {
  if ! command -v engram &>/dev/null; then
    log_info "Engram is not installed"
    return 2
  fi
  log_info "Uninstalling Engram..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Engram" _uninstall_engram_impl

  log_success "Engram uninstalled"
  return 0
}

_uninstall_engram_impl() {
  if rm -rf "$CORE_DATA/engram" && rm "$PREFIX/bin/engram" &>>"$LOG_FILE"; then
    return 0
  else
    log_error "Failed to uninstall Engram"
    return 1
  fi
}

update_engram() {
  log_info "Updating Engram..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating Engram" _update_engram_impl

  log_success "Engram updated"
  return 0
}

_update_engram_impl() {
  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  if ! git -C "$CORE_DATA/engram" pull &>>"$LOG_FILE"; then
    log_error "Failed to update Engram repository"
    return 1
  fi

  rm -f "$PREFIX/bin/engram"
  go clean -C "$CORE_DATA/engram" -cache &>>"$LOG_FILE"
  go mod tidy -C "$CORE_DATA/engram" &>>"$LOG_FILE"
  go mod download -C "$CORE_DATA/engram" &>>"$LOG_FILE"

  if ! go build -C "$CORE_DATA/engram/cmd/engram" -o "$PREFIX/bin/engram" &>>"$LOG_FILE"; then
    log_error "Failed to build Engram"
    return 1
  fi
  return 0
}

reinstall_engram() {
  uninstall_engram
  install_engram
}
