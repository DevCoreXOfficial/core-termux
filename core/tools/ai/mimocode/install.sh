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
  loading "Installing glibc and dependencies" _mimocode_install_deps_impl
}

_mimocode_install_deps_impl() {
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
    ["clang"]="clang"
    ["curl"]="curl"
    ["tar"]="tar"
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

_download_mimocode_binary() {
  loading "Downloading mimocode binary" _download_mimocode_binary_impl
}

_download_mimocode_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_mimocode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest mimocode version, falling back to $MIMOCODE_VERSION"
    latest_version="$MIMOCODE_VERSION"
  fi

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
  return 0
}

_compile_mimocode_helper() {
  loading "Compiling helper" _compile_mimocode_helper_impl
}

_compile_mimocode_helper_impl() {
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
  return 0
}

_mimocode_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_mimocode_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_install_mimocode_native() {
  _mimocode_install_deps || return 1
  _download_mimocode_binary || return 1
  _compile_mimocode_helper || return 1
  log_success "mimocode installed natively"
  return 0
}

_install_mimocode_proot() {
  loading "Installing mimocode (proot-distro)" _install_mimocode_proot_impl
}

_install_mimocode_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_mimocode_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _mimocode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"

  _mimocode_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://mimo.xiaomi.com/install | bash
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_mimocode_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local mimo_bin="$ubuntu_root/root/.mimocode/bin/mimo"

  if [ ! -f "$mimo_bin" ]; then
    log_error "mimocode binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/mimocode/bin/mimo"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/mimo"
  chmod +x "$PREFIX/bin/mimo"

  if ! grep -q '.mimocode/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# mimocode\nexport PATH=/root/.mimocode/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_mimocode() {
  if command -v mimo &>/dev/null; then
    log_info "mimocode is already installed"
    return 2
  fi

  log_info "Select installation method for mimocode:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_mimocode_native
    ;;
  *Proot-distro*)
    _install_mimocode_proot
    ;;
  esac
}

uninstall_mimocode() {
  log_info "Uninstalling mimocode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/mimo" ]; then
    log_warn "mimocode is not installed"
    return 1
  fi

  if [ -f "$MIMOCODE_DATA_DIR/mimocode" ]; then
    rm -f "$PREFIX/bin/mimo"
    rm -rf "$MIMOCODE_DATA_DIR"
    log_success "mimocode (native) uninstalled"
    return 0
  fi

  _mimocode_proot_ubuntu /bin/bash -c 'rm -rf /root/.mimocode' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_mimocode_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# mimocode/d; /export PATH=\/root\/.mimocode\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/mimo" &>>"$LOG_FILE"; then
    log_success "mimocode (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall mimocode"
    return 1
  fi
}

update_mimocode() {
  log_info "Updating mimocode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$MIMOCODE_DATA_DIR/mimocode" ]; then
    _install_mimocode_native
    return $?
  fi

  _mimocode_proot_ubuntu /bin/bash -c 'rm -rf /root/.mimocode' &>>"$LOG_FILE"

  _mimocode_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://mimo.xiaomi.com/install | bash
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_mimocode_detect_ubuntu_root)"
  local mimo_bin="$ubuntu_root/root/.mimocode/bin/mimo"

  if [ ! -f "$mimo_bin" ]; then
    log_error "mimocode binary not found after update"
    return 1
  fi

  log_success "mimocode (proot-distro) updated"
  return 0
}

reinstall_mimocode() {
  uninstall_mimocode
  install_mimocode
}
