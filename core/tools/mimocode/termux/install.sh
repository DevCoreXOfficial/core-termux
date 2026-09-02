#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

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
  local HELPER_SRC="$CORE_TOOL_DIR/helper/mimocode_helper.c"
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

_install_mimocode_proot_glibc() {
  _mimocode_install_deps || return 1
  loading "Installing proot" _mimocode_install_proot_pkg || return 1
  _download_mimocode_binary || return 1
  loading "Creating proot wrapper" _mimocode_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$MIMOCODE_DATA_DIR/.install-method"
  log_success "mimocode installed with glibc + proot"
  return 0
}

_mimocode_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_mimocode_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/mimo.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$MIMOCODE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/mimo"
  chmod +x "$PREFIX/bin/mimo"
  return 0
}

_install_mimocode_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _mimocode_install_proot_distro || return 1
  loading "Installing Ubuntu container" _mimocode_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _mimocode_ubuntu_deps || return 1
  loading "Downloading mimocode (Ubuntu)" _mimocode_ubuntu_install_bin || return 1
  loading "Creating wrapper" _mimocode_create_ubuntu_wrapper || return 1

  log_success "mimocode installed (proot-distro)"
  return 0
}

_mimocode_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_mimocode_install_ubuntu() {
  if [ ! -d "$(_mimocode_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_mimocode_ubuntu_deps() {
  _mimocode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_mimocode_ubuntu_install_bin() {
  _mimocode_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://mimo.xiaomi.com/install | bash
  ' &>>"$LOG_FILE"

  local mimo_bin
  mimo_bin="$(_mimocode_detect_ubuntu_root)/root/.mimocode/bin/mimo"
  if [ ! -f "$mimo_bin" ]; then
    log_error "mimocode binary not found after install"
    return 1
  fi
  return 0
}

_mimocode_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_mimocode_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/mimo"
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

  separator
  box_large "Installing MimoCode"
  separator
  echo

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_mimocode_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_mimocode_native
    ;;
  *proot-distro*)
    _install_mimocode_proot
    ;;
  esac
}

uninstall_mimocode() {
  _walkie_remove_wrapper mimo mimocode
  log_info "Uninstalling mimocode..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/mimo" ]; then
    log_warn "mimocode is not installed"
    return 1
  fi

  separator
  box_large "Uninstalling MimoCode"
  separator
  echo

  confirm_remove_configs "MimoCode" \
    "$HOME/.mimocode" \
    "$HOME/.config/mimocode" \
    "$HOME/.local/share/mimocode" \
    "$HOME/.local/state/mimocode" \
    "$HOME/.cache/mimocode"

  if [ -f "$MIMOCODE_DATA_DIR/mimocode" ]; then
    local method="native"
    if [ -f "$MIMOCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$MIMOCODE_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/mimo"
    rm -rf "$MIMOCODE_DATA_DIR"
    log_success "mimocode ($method) uninstalled"
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

_update_mimocode() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$MIMOCODE_DATA_DIR/mimocode" ]; then
    local method="native"
    if [ -f "$MIMOCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$MIMOCODE_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_mimocode_proot_glibc
    else
      _install_mimocode_native
    fi
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

update_mimocode() {
  _check_update_needed "MiMoCode" "$(_get_installed_version mimo)" "$(_get_remote_github_version XiaomiMiMo/MiMo-Code)" _update_mimocode
}

reinstall_mimocode() {
  uninstall_mimocode
  install_mimocode
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_mimocode; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_mimocode; fi
if [[ "${1:-}" == "update" ]]; then update_mimocode; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_mimocode; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version mimo; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_github_version XiaomiMiMo/MiMo-Code; fi
