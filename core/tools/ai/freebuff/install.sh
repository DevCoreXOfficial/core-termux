#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
FREEBUFF_DATA_DIR="$HOME/.local/share/core-termux-data/freebuff"

_freebuff_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_freebuff_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_freebuff_version() {
  curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"freebuff-v([^"]+)".*/\1/'
}

_freebuff_install_deps_native() {
  loading "Installing glibc and dependencies" _freebuff_install_deps_native_impl
}

_freebuff_install_deps_native_impl() {
  if [[ ! -f $PREFIX/etc/apt/sources.list.d/glibc.list ]]; then
    if ! yes | pkg install glibc-repo &>>"$LOG_FILE"; then
      log_error "Failed to install glibc-repo"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/lib/libc.so.6 ]]; then
    if ! yes | pkg install glibc &>>"$LOG_FILE"; then
      log_error "Failed to install glibc"
      return 1
    fi
  fi

  declare -A DEPS=(
    ["git"]="git"
    ["curl"]="curl"
    ["tar"]="tar"
    ["clang"]="clang"
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

_download_freebuff_binary() {
  loading "Downloading Freebuff" _download_freebuff_binary_impl
}

_download_freebuff_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_freebuff_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Freebuff version"
    return 1
  fi

  mkdir -p "$FREEBUFF_DATA_DIR"

  local tarball="freebuff-linux-arm64.tar.gz"
  local download_url="https://codebuff.com/api/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$FREEBUFF_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Freebuff binary"
    return 1
  fi

  if ! tar -zxf "$FREEBUFF_DATA_DIR/$tarball" -C "$FREEBUFF_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Freebuff binary"
    return 1
  fi

  rm -f "$FREEBUFF_DATA_DIR/$tarball"

  if [ ! -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    log_error "Freebuff binary not found after extraction"
    return 1
  fi

  chmod +x "$FREEBUFF_DATA_DIR/freebuff"
  return 0
}

_compile_freebuff_helper() {
  loading "Compiling helper" _compile_freebuff_helper_impl
}

_compile_freebuff_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/freebuff/helper/freebuff_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/freebuff" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile freebuff helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/freebuff"
  return 0
}

_install_freebuff_native() {
  _freebuff_install_deps_native || return 1
  _download_freebuff_binary || return 1
  _compile_freebuff_helper || return 1
  log_success "Freebuff installed natively"
  return 0
}

_install_freebuff_proot() {
  loading "Installing Freebuff (proot-distro)" _install_freebuff_proot_impl
}

_install_freebuff_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_freebuff_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _freebuff_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"

  _freebuff_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    LATEST=$(curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest | grep '"'"'tag_name'"'"' | sed -E '"'"'s/.*"freebuff-v([^"]+)".*/\1/'"'"')
    curl -fsSL "https://codebuff.com/api/releases/download/${LATEST}/freebuff-linux-arm64.tar.gz" -o /tmp/freebuff.tar.gz
    mkdir -p /root/.freebuff
    tar -zxf /tmp/freebuff.tar.gz -C /root/.freebuff
    rm -f /tmp/freebuff.tar.gz
    chmod +x /root/.freebuff/freebuff
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_freebuff_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local freebuff_bin="$ubuntu_root/root/.freebuff/freebuff"

  if [ ! -f "$freebuff_bin" ]; then
    log_error "Freebuff binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/freebuff/bin/freebuff"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/freebuff"
  chmod +x "$PREFIX/bin/freebuff"

  if ! grep -q '.freebuff' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# freebuff\nexport PATH=/root/.freebuff:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_freebuff() {
  if command -v freebuff &>/dev/null; then
    log_info "Freebuff is already installed"
    return 2
  fi

  log_info "Select installation method for Freebuff:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_freebuff_native
    ;;
  *Proot-distro*)
    _install_freebuff_proot
    ;;
  esac
}

uninstall_freebuff() {
  log_info "Uninstalling Freebuff..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/freebuff" ]; then
    log_warn "Freebuff is not installed"
    return 1
  fi

  if [ -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    rm -f "$PREFIX/bin/freebuff"
    rm -rf "$FREEBUFF_DATA_DIR"
    log_success "Freebuff (native) uninstalled"
    return 0
  fi

  _freebuff_proot_ubuntu /bin/bash -c 'rm -rf /root/.freebuff' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_freebuff_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# freebuff/d; /export PATH=\/root\/.freebuff/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/freebuff" &>>"$LOG_FILE"; then
    log_success "Freebuff (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Freebuff"
    return 1
  fi
}

update_freebuff() {
  log_info "Updating Freebuff..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    _install_freebuff_native
    return $?
  fi

  _freebuff_proot_ubuntu /bin/bash -c 'rm -rf /root/.freebuff' &>>"$LOG_FILE"

  _freebuff_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    LATEST=$(curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest | grep '"'"'tag_name'"'"' | sed -E '"'"'s/.*"freebuff-v([^"]+)".*/\1/'"'"')
    curl -fsSL "https://codebuff.com/api/releases/download/${LATEST}/freebuff-linux-arm64.tar.gz" -o /tmp/freebuff.tar.gz
    mkdir -p /root/.freebuff
    tar -zxf /tmp/freebuff.tar.gz -C /root/.freebuff
    rm -f /tmp/freebuff.tar.gz
    chmod +x /root/.freebuff/freebuff
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_freebuff_detect_ubuntu_root)"
  local freebuff_bin="$ubuntu_root/root/.freebuff/freebuff"

  if [ ! -f "$freebuff_bin" ]; then
    log_error "Freebuff binary not found after update"
    return 1
  fi

  log_success "Freebuff (proot-distro) updated"
  return 0
}

reinstall_freebuff() {
  uninstall_freebuff
  install_freebuff
}
