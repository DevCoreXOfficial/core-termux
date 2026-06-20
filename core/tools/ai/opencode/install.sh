#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
OPENCODE_DATA_DIR="$HOME/.local/share/core-termux-data/opencode"

_opencode_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_opencode_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_opencode_version() {
  curl -fsSL https://api.github.com/repos/anomalyco/opencode/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_opencode_install_deps_native() {
  loading "Installing glibc and dependencies" _opencode_install_deps_native_impl
}

_opencode_install_deps_native_impl() {
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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  return 0
}

_download_opencode_binary() {
  loading "Downloading OpenCode" _download_opencode_binary_impl
}

_download_opencode_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_opencode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest OpenCode version"
    return 1
  fi

  mkdir -p "$OPENCODE_DATA_DIR"

  local tarball="opencode-linux-arm64.tar.gz"
  local download_url="https://github.com/anomalyco/opencode/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$OPENCODE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download OpenCode binary"
    return 1
  fi

  if ! tar -zxf "$OPENCODE_DATA_DIR/$tarball" -C "$OPENCODE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract OpenCode binary"
    return 1
  fi

  rm -f "$OPENCODE_DATA_DIR/$tarball"

  if [ ! -f "$OPENCODE_DATA_DIR/opencode" ]; then
    log_error "OpenCode binary not found after extraction"
    return 1
  fi

  chmod +x "$OPENCODE_DATA_DIR/opencode"
  return 0
}

_compile_opencode_helper() {
  loading "Compiling helper" _compile_opencode_helper_impl
}

_compile_opencode_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/opencode/helper/opencode_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/opencode" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile opencode helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/opencode"
  return 0
}

_install_opencode_native() {
  _opencode_install_deps_native || return 1
  _download_opencode_binary || return 1
  _compile_opencode_helper || return 1
  log_success "OpenCode installed natively"
  return 0
}

_install_opencode_proot() {
  loading "Installing OpenCode (proot-distro)" _install_opencode_proot_impl
}

_install_opencode_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    pkg install proot-distro -y &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_opencode_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _opencode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"

  _opencode_proot_ubuntu /bin/bash -c '
		export SHELL=/bin/bash
		export TMPDIR=/tmp
		export HOME=/root
		curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
	' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_opencode_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local opencode_bin="$ubuntu_root/root/.opencode/bin/opencode"

  if [ ! -f "$opencode_bin" ]; then
    log_error "OpenCode binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/opencode/bin/opencode"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/opencode"
  chmod +x "$PREFIX/bin/opencode"

  if ! grep -q '.opencode/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# opencode\nexport PATH=/root/.opencode/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_opencode() {
  if command -v opencode &>/dev/null; then
    log_info "OpenCode is already installed"
    return 2
  fi

  log_info "Select installation method for OpenCode:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_opencode_native
    ;;
  *Proot-distro*)
    _install_opencode_proot
    ;;
  esac
}

uninstall_opencode() {
  log_info "Uninstalling OpenCode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/opencode" ]; then
    log_warn "OpenCode is not installed"
    return 1
  fi

  if [ -f "$OPENCODE_DATA_DIR/opencode" ]; then
    rm -f "$PREFIX/bin/opencode"
    rm -rf "$OPENCODE_DATA_DIR"
    log_success "OpenCode (native) uninstalled"
    return 0
  fi

  _opencode_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_opencode_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# opencode/d; /export PATH=\/root\/.opencode\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/opencode" &>>"$LOG_FILE"; then
    log_success "OpenCode (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall OpenCode"
    return 1
  fi
}

update_opencode() {
  log_info "Updating OpenCode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$OPENCODE_DATA_DIR/opencode" ]; then
    _install_opencode_native
    return $?
  fi

  _opencode_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode' &>>"$LOG_FILE"

  _opencode_proot_ubuntu /bin/bash -c '
		export SHELL=/bin/bash
		export TMPDIR=/tmp
		export HOME=/root
		curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
	' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_opencode_detect_ubuntu_root)"
  local opencode_bin="$ubuntu_root/root/.opencode/bin/opencode"

  if [ ! -f "$opencode_bin" ]; then
    log_error "OpenCode binary not found after update"
    return 1
  fi

  log_success "OpenCode (proot-distro) updated"
  return 0
}

reinstall_opencode() {
  uninstall_opencode
  install_opencode
}
