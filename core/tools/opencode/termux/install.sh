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
  local HELPER_SRC="$CORE_TOOL_DIR/helper/opencode_helper.c"
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

_install_opencode_proot_glibc() {
  _opencode_install_deps_native || return 1
  loading "Installing proot" _opencode_install_proot_pkg || return 1
  _download_opencode_binary || return 1
  loading "Creating proot wrapper" _opencode_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$OPENCODE_DATA_DIR/.install-method"
  log_success "OpenCode installed with glibc + proot"
  return 0
}

_opencode_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_opencode_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/opencode.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$OPENCODE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/opencode"
  chmod +x "$PREFIX/bin/opencode"
  return 0
}

_install_opencode_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _opencode_install_proot_distro || return 1
  loading "Installing Ubuntu container" _opencode_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _opencode_ubuntu_deps || return 1
  loading "Downloading OpenCode (Ubuntu)" _opencode_ubuntu_install_bin || return 1
  loading "Creating wrapper" _opencode_create_ubuntu_wrapper || return 1

  log_success "OpenCode installed (proot-distro)"
  return 0
}

_opencode_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_opencode_install_ubuntu() {
  if [ ! -d "$(_opencode_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_opencode_ubuntu_deps() {
  _opencode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_opencode_ubuntu_install_bin() {
  _opencode_proot_ubuntu /bin/bash -c '
		export SHELL=/bin/bash
		export TMPDIR=/tmp
		export HOME=/root
		curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
	' &>>"$LOG_FILE"

  local opencode_bin
  opencode_bin="$(_opencode_detect_ubuntu_root)/root/.opencode/bin/opencode"
  if [ ! -f "$opencode_bin" ]; then
    log_error "OpenCode binary not found after install"
    return 1
  fi
  return 0
}

_opencode_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_opencode_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/opencode"
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

  separator
  box_large "Installing OpenCode"
  separator
  echo

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_opencode_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_opencode_native
    ;;
  *proot-distro*)
    _install_opencode_proot
    ;;
  esac
}

uninstall_opencode() {
  _walkie_remove_wrapper opencode
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/opencode" ]; then
    log_warn "OpenCode is not installed"
    return 1
  fi

  separator
  box_large "Uninstalling OpenCode"
  separator
  echo

  confirm_remove_configs "OpenCode" \
    "$HOME/.config/opencode" \
    "$HOME/.local/share/opencode" \
    "$HOME/.local/state/opencode" \
    "$HOME/.cache/opencode"

  loading "Uninstalling OpenCode" _uninstall_opencode_impl
}

_uninstall_opencode_impl() {
  if [ -f "$OPENCODE_DATA_DIR/opencode" ]; then
    local method="native"
    if [ -f "$OPENCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$OPENCODE_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/opencode"
    rm -rf "$OPENCODE_DATA_DIR"
    log_success "OpenCode ($method) uninstalled"
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

_update_opencode() {
	_update_opencode_impl
}

_update_opencode_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$OPENCODE_DATA_DIR/opencode" ]; then
    local method="native"
    if [ -f "$OPENCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$OPENCODE_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_opencode_proot_glibc
    else
      _install_opencode_native
    fi
    return $?
  fi

  loading "Updating OpenCode (proot-distro)" _update_opencode_proot_impl
}

update_opencode() {
  _check_update_needed "OpenCode" "$(_get_installed_version opencode)" "$(_get_remote_github_version anomalyco/opencode)" _update_opencode
}

_update_opencode_proot_impl() {
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

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_opencode; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_opencode; fi
if [[ "${1:-}" == "update" ]]; then update_opencode; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_opencode; fi
