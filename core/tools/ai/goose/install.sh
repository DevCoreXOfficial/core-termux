#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"
GOOSE_DATA_DIR="$HOME/.local/share/core-termux-data/goose"

_goose_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_goose_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_goose_version() {
  local raw
  raw=$(_spin_capture "Checking GitHub" curl -fsSL "https://api.github.com/repos/aaif-goose/goose/releases/latest" 2>/dev/null)
  echo "$raw" | jq -r '.tag_name'
}

_get_latest_goose_version_silent() {
  local raw
  raw=$(curl -fsSL "https://api.github.com/repos/aaif-goose/goose/releases/latest" 2>/dev/null)
  echo "$raw" | jq -r '.tag_name'
}

_goose_install_deps_native() {
  loading "Installing glibc and dependencies" _goose_install_deps_native_impl
}

_goose_install_deps_native_impl() {
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
    ["bzip2"]="bzip2"
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

_download_goose_binary() {
  loading "Downloading Goose CLI" _download_goose_binary_impl
}

_download_goose_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_goose_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Goose CLI version"
    return 1
  fi

  mkdir -p "$GOOSE_DATA_DIR"

  local tarball="goose-aarch64-unknown-linux-gnu.tar.bz2"
  local download_url="https://github.com/aaif-goose/goose/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$GOOSE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Goose CLI binary"
    return 1
  fi

  if ! tar -xjf "$GOOSE_DATA_DIR/$tarball" -C "$GOOSE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Goose CLI binary"
    return 1
  fi

  rm -f "$GOOSE_DATA_DIR/$tarball"

  if [ ! -f "$GOOSE_DATA_DIR/goose" ]; then
    log_error "Goose CLI binary not found after extraction"
    return 1
  fi

  chmod +x "$GOOSE_DATA_DIR/goose"
  return 0
}

_compile_goose_helper() {
  loading "Compiling helper" _compile_goose_helper_impl
}

_compile_goose_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/goose/helper/goose_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/goose" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile goose helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/goose"

  return 0
}

_install_goose_native() {
  _goose_install_deps_native || return 1
  _download_goose_binary || return 1
  _compile_goose_helper || return 1
  log_success "Goose CLI installed natively"
  return 0
}

_install_goose_proot_glibc() {
  _goose_install_deps_native || return 1
  loading "Installing proot" _goose_install_proot_pkg || return 1
  _download_goose_binary || return 1
  loading "Creating proot wrapper" _goose_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$GOOSE_DATA_DIR/.install-method"
  log_success "Goose CLI installed with glibc + proot"
  return 0
}

_goose_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_goose_create_proot_wrapper() {
  local wrapper_src="$CORE_PATH/tools/ai/goose/bin/goose.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$GOOSE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/goose"
  chmod +x "$PREFIX/bin/goose"
  return 0
}

_install_goose_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _goose_install_proot_distro || return 1
  loading "Installing Ubuntu container" _goose_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _goose_ubuntu_deps || return 1
  loading "Downloading Goose CLI (Ubuntu)" _goose_ubuntu_install_bin || return 1
  loading "Creating wrapper" _goose_create_ubuntu_wrapper || return 1

  log_success "Goose CLI installed (proot-distro)"
  return 0
}

_goose_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_goose_install_ubuntu() {
  if [ ! -d "$(_goose_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_goose_ubuntu_deps() {
  _goose_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar bzip2' \
    &>>"$LOG_FILE"
}

_goose_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_goose_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Goose CLI version"
    return 1
  fi

  local download_url="https://github.com/aaif-goose/goose/releases/download/$latest_version/goose-aarch64-unknown-linux-gnu.tar.bz2"

  _goose_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/goose-install &&
    curl -fsSL '$download_url' -o /tmp/goose-install/goose.tar.bz2 &&
    tar -xjf /tmp/goose-install/goose.tar.bz2 -C /tmp/goose-install &&
    mkdir -p /usr/local/bin &&
    mv /tmp/goose-install/goose /usr/local/bin/goose &&
    chmod +x /usr/local/bin/goose &&
    rm -rf /tmp/goose-install
  " &>>"$LOG_FILE"

  local goose_bin="$(_goose_detect_ubuntu_root)/usr/local/bin/goose"
  if [ ! -f "$goose_bin" ]; then
    log_error "Goose CLI binary not found after install"
    return 1
  fi
  return 0
}

_goose_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_goose_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/goose/bin/goose"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/goose"
  chmod +x "$PREFIX/bin/goose"
  return 0
}

install_goose() {
  if command -v goose &>/dev/null; then
    log_info "Goose CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Goose CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_goose_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_goose_native
    ;;
  *proot-distro*)
    _install_goose_proot
    ;;
  esac
}

uninstall_goose() {
  _walkie_remove_wrapper goose
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/goose" ]; then
    log_warn "Goose CLI is not installed"
    return 1
  fi

  confirm_remove_configs "Goose" \
    "$HOME/.goose" \
    "$HOME/.config/goose" \
    "$HOME/.local/share/goose" \
    "$HOME/.cache/goose"

  loading "Uninstalling Goose CLI" _uninstall_goose_impl
}

_uninstall_goose_impl() {
  if [ -f "$GOOSE_DATA_DIR/goose" ]; then
    local method="native"
    if [ -f "$GOOSE_DATA_DIR/.install-method" ]; then
      method="$(cat "$GOOSE_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/goose"
    rm -rf "$GOOSE_DATA_DIR"
    log_success "Goose CLI ($method) uninstalled"
    return 0
  fi

  _goose_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/goose' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/goose" &>>"$LOG_FILE"; then
    log_success "Goose CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Goose CLI"
    return 1
  fi
}

_update_goose_cli() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$GOOSE_DATA_DIR/goose" ]; then
    local method="native"
    if [ -f "$GOOSE_DATA_DIR/.install-method" ]; then
      method="$(cat "$GOOSE_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_goose_proot_glibc
    else
      _install_goose_native
    fi
    return $?
  fi

  loading "Updating Goose CLI (proot-distro)" _update_goose_proot_impl
}

update_goose() {
  _check_update_needed "Goose CLI" "$(_get_installed_version goose)" "$(_parse_version "$(_get_latest_goose_version)")" _update_goose_cli
}

_update_goose_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_goose_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Goose CLI version"
    return 1
  fi

  local download_url="https://github.com/aaif-goose/goose/releases/download/$latest_version/goose-aarch64-unknown-linux-gnu.tar.bz2"

  _goose_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/goose-install &&
    curl -fsSL '$download_url' -o /tmp/goose-install/goose.tar.bz2 &&
    tar -xjf /tmp/goose-install/goose.tar.bz2 -C /tmp/goose-install &&
    rm -f /usr/local/bin/goose &&
    mv /tmp/goose-install/goose /usr/local/bin/goose &&
    chmod +x /usr/local/bin/goose &&
    rm -rf /tmp/goose-install
  " &>>"$LOG_FILE"

  local goose_bin
  goose_bin="$(_goose_detect_ubuntu_root)/usr/local/bin/goose"

  if [ ! -f "$goose_bin" ]; then
    log_error "Goose CLI binary not found after update"
    return 1
  fi

  log_success "Goose CLI (proot-distro) updated"
  return 0
}

reinstall_goose() {
  uninstall_goose
  install_goose
}
