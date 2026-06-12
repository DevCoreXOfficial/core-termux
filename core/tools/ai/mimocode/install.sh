#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
MIMOCODE_DATA_DIR="$HOME/.local/share/core-termux-data/mimocode"
MIMOCODE_VERSION="v0.1.0"

_get_latest_mimocode_version() {
  curl -fsSL https://api.github.com/repos/XiaomiMiMo/MiMo-Code/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_mimocode_install_deps() {
  if [[ ! -f $PREFIX/etc/apt/sources.list.d/glibc.list ]]; then
    if ! pkg install glibc-repo -y &>>"$LOG_FILE"; then
      log_error "Failed to install glibc-repo"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/lib/libc.so.6 ]]; then
    if ! pkg install glibc -y &>>"$LOG_FILE"; then
      log_error "Failed to install glibc"
      return 1
    fi
  fi

  declare -A DEPS=(
    ["clang"]="clang"
    ["curl"]="curl"
    ["tar"]="tar"
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

  log_success "Dependencies installed"
  return 0
}

_download_mimocode_binary() {
  local latest_version
  latest_version=$(_get_latest_mimocode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest mimocode version, falling back to $MIMOCODE_VERSION"
    latest_version="$MIMOCODE_VERSION"
  fi

  log_info "Latest version: ${D_CYAN}$latest_version${NC}"

  mkdir -p "$MIMOCODE_DATA_DIR"

  local tarball="mimocode-linux-arm64.tar.gz"
  local download_url="https://github.com/XiaomiMiMo/MiMo-Code/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$MIMOCODE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download mimocode binary"
    return 1
  fi

  if ! tar -zxf "$MIMOCODE_DATA_DIR/$tarball" -C "$MIMOCODE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract mimocode binary"
    return 1
  fi

  rm -f "$MIMOCODE_DATA_DIR/$tarball"

  if [ ! -f "$MIMOCODE_DATA_DIR/mimo" ]; then
    log_error "mimocode binary not found after extraction"
    return 1
  fi

  mv "$MIMOCODE_DATA_DIR/mimo" "$MIMOCODE_DATA_DIR/mimocode"
  chmod +x "$MIMOCODE_DATA_DIR/mimocode"
  log_success "mimocode binary downloaded"
  return 0
}

_compile_mimocode_helper() {
  local HELPER_SRC="$CORE_PATH/tools/ai/mimocode/helper/mimocode_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/mimo" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile mimocode helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/mimo"
  log_success "Bootstrapper compiled"
  return 0
}

_install_mimocode_native() {
  if ! loading "Installing dependencies" _mimocode_install_deps; then
    return 1
  fi

  if ! loading "Downloading mimocode" _download_mimocode_binary; then
    return 1
  fi

  if ! loading "Compiling bootstrapper" _compile_mimocode_helper; then
    return 1
  fi

  log_success "mimocode installed natively"
  return 0
}

install_mimocode() {
  if command -v mimo &>/dev/null; then
    log_success "mimocode is already installed"
    return 0
  fi

  _install_mimocode_native
}

uninstall_mimocode() {
  log_info "Uninstalling mimocode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$PREFIX/bin/mimo" ]; then
    rm -f "$PREFIX/bin/mimo"
    rm -rf "$MIMOCODE_DATA_DIR"
    log_success "mimocode uninstalled"
    return 0
  fi

  log_warn "mimocode is not installed"
  return 1
}

update_mimocode() {
  log_info "Updating mimocode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$PREFIX/bin/mimo" ]; then
    rm -f "$PREFIX/bin/mimo"
    rm -rf "$MIMOCODE_DATA_DIR"
  fi

  _install_mimocode_native
}
