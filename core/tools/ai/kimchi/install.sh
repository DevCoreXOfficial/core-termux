#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
KIMCHI_DATA_DIR="$HOME/.local/share/core-termux-data/kimchi"

_kimchi_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_kimchi_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_kimchi_version() {
  curl -fsSL https://api.github.com/repos/getkimchi/kimchi/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_kimchi_install_deps_native() {
  loading "Installing glibc and dependencies" _kimchi_install_deps_native_impl
}

_kimchi_install_deps_native_impl() {
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

_download_kimchi_binary() {
  loading "Downloading Kimchi" _download_kimchi_binary_impl
}

_download_kimchi_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_kimchi_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kimchi version"
    return 1
  fi

  mkdir -p "$KIMCHI_DATA_DIR"

  local tarball="kimchi_linux_arm64.tar.gz"
  local download_url="https://github.com/getkimchi/kimchi/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$KIMCHI_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Kimchi binary"
    return 1
  fi

  if ! tar -zxf "$KIMCHI_DATA_DIR/$tarball" -C "$KIMCHI_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Kimchi binary"
    return 1
  fi

  rm -f "$KIMCHI_DATA_DIR/$tarball"

  if [ ! -f "$KIMCHI_DATA_DIR/bin/kimchi" ]; then
    log_error "Kimchi binary not found after extraction"
    return 1
  fi

  chmod +x "$KIMCHI_DATA_DIR/bin/kimchi"

  # Kimchi expects auxiliary files at ~/.local/share/kimchi
  local kimchi_share_src="$KIMCHI_DATA_DIR/share/kimchi"
  local kimchi_share_dst="$HOME/.local/share/kimchi"
  if [ -d "$kimchi_share_src" ]; then
    rm -rf "$kimchi_share_dst"
    ln -sf "$kimchi_share_src" "$kimchi_share_dst"
  fi

  return 0
}

_compile_kimchi_helper() {
  loading "Compiling helper" _compile_kimchi_helper_impl
}

_compile_kimchi_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/kimchi/helper/kimchi_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/kimchi" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile kimchi helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/kimchi"
  return 0
}

_install_kimchi_native() {
  _kimchi_install_deps_native || return 1
  _download_kimchi_binary || return 1
  _compile_kimchi_helper || return 1
  log_success "Kimchi installed natively"
  return 0
}

_install_kimchi_proot() {
  loading "Installing Kimchi (proot-distro)" _install_kimchi_proot_impl
}

_install_kimchi_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_kimchi_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _kimchi_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"

  local latest_version
  latest_version=$(_get_latest_kimchi_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kimchi version"
    return 1
  fi

  local download_url="https://github.com/getkimchi/kimchi/releases/download/$latest_version/kimchi_linux_arm64.tar.gz"

  _kimchi_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/kimchi-install &&
    curl -fsSL '$download_url' -o /tmp/kimchi-install/kimchi.tar.gz &&
    tar -zxf /tmp/kimchi-install/kimchi.tar.gz -C /tmp/kimchi-install &&
    mkdir -p /usr/local/bin /usr/local/share &&
    mv /tmp/kimchi-install/bin/kimchi /usr/local/bin/kimchi &&
    chmod +x /usr/local/bin/kimchi &&
    rm -rf /usr/local/share/kimchi &&
    mv /tmp/kimchi-install/share/kimchi /usr/local/share/kimchi &&
    rm -rf /tmp/kimchi-install
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_kimchi_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local kimchi_bin="$ubuntu_root/usr/local/bin/kimchi"

  if [ ! -f "$kimchi_bin" ]; then
    log_error "Kimchi binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/kimchi/bin/kimchi"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/kimchi"
  chmod +x "$PREFIX/bin/kimchi"

  return 0
}

install_kimchi() {
  if command -v kimchi &>/dev/null; then
    log_info "Kimchi is already installed"
    return 2
  fi

  log_info "Select installation method for Kimchi:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_kimchi_native
    ;;
  *Proot-distro*)
    _install_kimchi_proot
    ;;
  esac
}

uninstall_kimchi() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/kimchi" ]; then
    log_warn "Kimchi is not installed"
    return 1
  fi

  loading "Uninstalling Kimchi" _uninstall_kimchi_impl
}

_uninstall_kimchi_impl() {
  if [ -f "$KIMCHI_DATA_DIR/bin/kimchi" ]; then
    rm -f "$PREFIX/bin/kimchi"
    rm -rf "$KIMCHI_DATA_DIR"
    rm -f "$HOME/.local/share/kimchi"
    log_success "Kimchi (native) uninstalled"
    return 0
  fi

  _kimchi_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/kimchi && rm -rf /usr/local/share/kimchi' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/kimchi" &>>"$LOG_FILE"; then
    log_success "Kimchi (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Kimchi"
    return 1
  fi
}

update_kimchi() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$KIMCHI_DATA_DIR/bin/kimchi" ]; then
    _install_kimchi_native
    return $?
  fi

  loading "Updating Kimchi (proot-distro)" _update_kimchi_proot_impl
}

_update_kimchi_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_kimchi_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Kimchi version"
    return 1
  fi

  local download_url="https://github.com/getkimchi/kimchi/releases/download/$latest_version/kimchi_linux_arm64.tar.gz"

  _kimchi_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/kimchi-install &&
    curl -fsSL '$download_url' -o /tmp/kimchi-install/kimchi.tar.gz &&
    tar -zxf /tmp/kimchi-install/kimchi.tar.gz -C /tmp/kimchi-install &&
    rm -f /usr/local/bin/kimchi &&
    mv /tmp/kimchi-install/bin/kimchi /usr/local/bin/kimchi &&
    chmod +x /usr/local/bin/kimchi &&
    rm -rf /usr/local/share/kimchi &&
    mv /tmp/kimchi-install/share/kimchi /usr/local/share/kimchi &&
    rm -rf /tmp/kimchi-install
  " &>>"$LOG_FILE"

  local kimchi_bin
  kimchi_bin="$(_kimchi_detect_ubuntu_root)/usr/local/bin/kimchi"

  if [ ! -f "$kimchi_bin" ]; then
    log_error "Kimchi binary not found after update"
    return 1
  fi

  log_success "Kimchi (proot-distro) updated"
  return 0
}

reinstall_kimchi() {
  uninstall_kimchi
  install_kimchi
}
