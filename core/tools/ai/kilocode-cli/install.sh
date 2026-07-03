#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
KILOCODE_DATA_DIR="$HOME/.local/share/core-termux-data/kilocode"

_kilocode_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_kilocode_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_kilocode_version() {
  curl -fsSL https://api.github.com/repos/Kilo-Org/kilocode/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_kilocode_install_deps_native() {
  loading "Installing glibc and dependencies" _kilocode_install_deps_native_impl
}

_kilocode_install_deps_native_impl() {
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
    ["ripgrep"]="rg"
    ["python"]="python"
    ["clang"]="clang"
    ["jq"]="jq"
    ["nodejs-lts"]="node"
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

_download_kilocode_binary() {
  loading "Downloading Kilo Code CLI" _download_kilocode_binary_impl
}

_download_kilocode_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_kilocode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kilo Code CLI version"
    return 1
  fi

  mkdir -p "$KILOCODE_DATA_DIR"

  local tarball="kilo-linux-arm64.tar.gz"
  local download_url="https://github.com/Kilo-Org/kilocode/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$KILOCODE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Kilo Code CLI binary"
    return 1
  fi

  if ! tar -zxf "$KILOCODE_DATA_DIR/$tarball" -C "$KILOCODE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Kilo Code CLI binary"
    return 1
  fi

  rm -f "$KILOCODE_DATA_DIR/$tarball"

  if [ ! -f "$KILOCODE_DATA_DIR/kilo" ]; then
    log_error "Kilo Code CLI binary not found after extraction"
    return 1
  fi

  chmod +x "$KILOCODE_DATA_DIR/kilo"
  return 0
}

_compile_kilocode_helper() {
  loading "Compiling helper" _compile_kilocode_helper_impl
}

_compile_kilocode_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/kilocode-cli/helper/kilocode_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/kilocode" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile kilocode helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/kilocode"

  ln -sf "$PREFIX/bin/kilocode" "$PREFIX/bin/kilo"

  return 0
}

_install_kilocode_native() {
  _kilocode_install_deps_native || return 1
  _download_kilocode_binary || return 1
  _compile_kilocode_helper || return 1
  log_success "Kilo Code CLI installed natively"
  return 0
}

_install_kilocode_proot() {
  loading "Installing Kilo Code CLI (proot-distro)" _install_kilocode_proot_impl
}

_install_kilocode_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_kilocode_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _kilocode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"

  local latest_version
  latest_version=$(_get_latest_kilocode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kilo Code CLI version"
    return 1
  fi

  local download_url="https://github.com/Kilo-Org/kilocode/releases/download/$latest_version/kilo-linux-arm64.tar.gz"

  _kilocode_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/kilocode-install &&
    curl -fsSL '$download_url' -o /tmp/kilocode-install/kilo.tar.gz &&
    tar -zxf /tmp/kilocode-install/kilo.tar.gz -C /tmp/kilocode-install &&
    mkdir -p /usr/local/bin &&
    mv /tmp/kilocode-install/kilo /usr/local/bin/kilo &&
    chmod +x /usr/local/bin/kilo &&
    rm -rf /tmp/kilocode-install
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_kilocode_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local kilocode_bin="$ubuntu_root/usr/local/bin/kilo"

  if [ ! -f "$kilocode_bin" ]; then
    log_error "Kilo Code CLI binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/kilocode-cli/bin/kilocode"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/kilocode"
  chmod +x "$PREFIX/bin/kilocode"

  ln -sf "$PREFIX/bin/kilocode" "$PREFIX/bin/kilo"

  return 0
}

install_kilocode_cli() {
  if command -v kilocode &>/dev/null; then
    log_info "Kilo Code CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Kilo Code CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_kilocode_native
    ;;
  *Proot-distro*)
    _install_kilocode_proot
    ;;
  esac
}

uninstall_kilocode_cli() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/kilocode" ]; then
    log_warn "Kilo Code CLI is not installed"
    return 1
  fi

  loading "Uninstalling Kilo Code CLI" _uninstall_kilocode_cli_impl
}

_uninstall_kilocode_cli_impl() {
  if [ -f "$KILOCODE_DATA_DIR/kilo" ]; then
    rm -f "$PREFIX/bin/kilocode" "$PREFIX/bin/kilo"
    rm -rf "$KILOCODE_DATA_DIR"
    log_success "Kilo Code CLI (native) uninstalled"
    return 0
  fi

  _kilocode_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/kilo' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/kilocode" "$PREFIX/bin/kilo" &>>"$LOG_FILE"; then
    log_success "Kilo Code CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Kilo Code CLI"
    return 1
  fi
}

update_kilocode_cli() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$KILOCODE_DATA_DIR/kilo" ]; then
    _install_kilocode_native
    return $?
  fi

  loading "Updating Kilo Code CLI (proot-distro)" _update_kilocode_proot_impl
}

_update_kilocode_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_kilocode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kilo Code CLI version"
    return 1
  fi

  local download_url="https://github.com/Kilo-Org/kilocode/releases/download/$latest_version/kilo-linux-arm64.tar.gz"

  _kilocode_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/kilocode-install &&
    curl -fsSL '$download_url' -o /tmp/kilocode-install/kilo.tar.gz &&
    tar -zxf /tmp/kilocode-install/kilo.tar.gz -C /tmp/kilocode-install &&
    rm -f /usr/local/bin/kilo &&
    mv /tmp/kilocode-install/kilo /usr/local/bin/kilo &&
    chmod +x /usr/local/bin/kilo &&
    rm -rf /tmp/kilocode-install
  " &>>"$LOG_FILE"

  local kilocode_bin
  kilocode_bin="$(_kilocode_detect_ubuntu_root)/usr/local/bin/kilo"

  if [ ! -f "$kilocode_bin" ]; then
    log_error "Kilo Code CLI binary not found after update"
    return 1
  fi

  log_success "Kilo Code CLI (proot-distro) updated"
  return 0
}

reinstall_kilocode_cli() {
  uninstall_kilocode_cli
  install_kilocode_cli
}
