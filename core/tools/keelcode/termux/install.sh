#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"
KEELCODE_DATA_DIR="$HOME/.local/share/core-termux-data/keelcode"

_keelcode_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_keelcode_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_keelcode_version() {
  local raw
  raw=$(_spin_capture "Checking npm registry" curl -fsSL "https://registry.npmjs.org/-/package/@keelcode-ai/keelcode/dist-tags" 2>/dev/null)
  echo "$raw" | jq -r '.["native-linux-arm64"]'
}

_get_latest_keelcode_version_silent() {
  local raw
  raw=$(curl -fsSL "https://registry.npmjs.org/-/package/@keelcode-ai/keelcode/dist-tags" 2>/dev/null)
  echo "$raw" | jq -r '.["native-linux-arm64"]'
}

_get_remote_keelcode_version() {
  _parse_version "$(_get_latest_keelcode_version_silent)"
}

_keelcode_install_deps_native() {
  loading "Installing glibc and dependencies" _keelcode_install_deps_native_impl
}

_keelcode_install_deps_native_impl() {
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

_download_keelcode_binary() {
  loading "Downloading KeelCode" _download_keelcode_binary_impl
}

_download_keelcode_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_keelcode_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest KeelCode version"
    return 1
  fi

  mkdir -p "$KEELCODE_DATA_DIR"

  local tarball="keelcode-$latest_version.tgz"
  local download_url="https://registry.npmjs.org/@keelcode-ai/keelcode/-/keelcode-$latest_version.tgz"

  if ! curl -fsSL "$download_url" -o "$KEELCODE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download KeelCode binary"
    return 1
  fi

  # Native package layout: package/bin/keelcode + package/bin/rg
  if ! tar -zxf "$KEELCODE_DATA_DIR/$tarball" -C "$KEELCODE_DATA_DIR" --strip-components=2 package/bin &>>"$LOG_FILE"; then
    log_error "Failed to extract KeelCode binary"
    return 1
  fi

  rm -f "$KEELCODE_DATA_DIR/$tarball"

  if [ ! -f "$KEELCODE_DATA_DIR/keelcode" ]; then
    log_error "KeelCode binary not found after extraction"
    return 1
  fi

  chmod +x "$KEELCODE_DATA_DIR/keelcode" "$KEELCODE_DATA_DIR/rg"
  return 0
}

_compile_keelcode_helper() {
  loading "Compiling helper" _compile_keelcode_helper_impl
}

_compile_keelcode_helper_impl() {
  local HELPER_SRC="$CORE_TOOL_DIR/helper/keelcode_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/keelcode" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile keelcode helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/keelcode"

  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kc"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kcode"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/keel"

  return 0
}

_install_keelcode_native() {
  _keelcode_install_deps_native || return 1
  _download_keelcode_binary || return 1
  _compile_keelcode_helper || return 1
  log_success "KeelCode installed natively"
  return 0
}

_install_keelcode_proot_glibc() {
  _keelcode_install_deps_native || return 1
  loading "Installing proot" _keelcode_install_proot_pkg || return 1
  _download_keelcode_binary || return 1
  loading "Creating proot wrapper" _keelcode_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$KEELCODE_DATA_DIR/.install-method"
  log_success "KeelCode installed with glibc + proot"
  return 0
}

_keelcode_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_keelcode_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/keelcode.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$KEELCODE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/keelcode"
  chmod +x "$PREFIX/bin/keelcode"

  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kc"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kcode"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/keel"
  return 0
}

_install_keelcode_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _keelcode_install_proot_distro || return 1
  loading "Installing Ubuntu container" _keelcode_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _keelcode_ubuntu_deps || return 1
  loading "Downloading KeelCode (Ubuntu)" _keelcode_ubuntu_install_bin || return 1
  loading "Creating wrapper" _keelcode_create_ubuntu_wrapper || return 1

  log_success "KeelCode installed (proot-distro)"
  return 0
}

_keelcode_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_keelcode_install_ubuntu() {
  if [ ! -d "$(_keelcode_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_keelcode_ubuntu_deps() {
  _keelcode_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar jq' \
    &>>"$LOG_FILE"
}

_keelcode_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_keelcode_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest KeelCode version"
    return 1
  fi

  local download_url="https://registry.npmjs.org/@keelcode-ai/keelcode/-/keelcode-$latest_version.tgz"

  _keelcode_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/keelcode-install &&
    curl -fsSL '$download_url' -o /tmp/keelcode-install/keelcode.tgz &&
    tar -zxf /tmp/keelcode-install/keelcode.tgz -C /tmp/keelcode-install --strip-components=2 package/bin &&
    mkdir -p /usr/local/bin &&
    mv /tmp/keelcode-install/keelcode /usr/local/bin/keelcode &&
    chmod +x /usr/local/bin/keelcode &&
    mv /tmp/keelcode-install/rg /usr/local/bin/rg &&
    chmod +x /usr/local/bin/rg &&
    rm -rf /tmp/keelcode-install
  " &>>"$LOG_FILE"

  local keelcode_bin="$(_keelcode_detect_ubuntu_root)/usr/local/bin/keelcode"
  if [ ! -f "$keelcode_bin" ]; then
    log_error "KeelCode binary not found after install"
    return 1
  fi
  return 0
}

_keelcode_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_keelcode_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/keelcode"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/keelcode"
  chmod +x "$PREFIX/bin/keelcode"

  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kc"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/kcode"
  ln -sf "$PREFIX/bin/keelcode" "$PREFIX/bin/keel"
  return 0
}

install_keelcode() {
  if command -v keelcode &>/dev/null; then
    log_info "KeelCode is already installed"
    return 2
  fi

  log_info "Select installation method for KeelCode:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_keelcode_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_keelcode_native
    ;;
  *proot-distro*)
    _install_keelcode_proot
    ;;
  esac
}

uninstall_keelcode() {
  _walkie_remove_wrapper keelcode
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/keelcode" ]; then
    log_warn "KeelCode is not installed"
    return 1
  fi

  confirm_remove_configs "KeelCode" \
    "$HOME/.keelcode"

  loading "Uninstalling KeelCode" _uninstall_keelcode_impl
}

_uninstall_keelcode_impl() {
  if [ -f "$KEELCODE_DATA_DIR/keelcode" ]; then
    local method="native"
    if [ -f "$KEELCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$KEELCODE_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/keelcode" "$PREFIX/bin/kc" "$PREFIX/bin/kcode" "$PREFIX/bin/keel"
    rm -rf "$KEELCODE_DATA_DIR"
    log_success "KeelCode ($method) uninstalled"
    return 0
  fi

  _keelcode_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/keelcode /usr/local/bin/rg' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/keelcode" "$PREFIX/bin/kc" "$PREFIX/bin/kcode" "$PREFIX/bin/keel" &>>"$LOG_FILE"; then
    log_success "KeelCode (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall KeelCode"
    return 1
  fi
}

_update_keelcode() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$KEELCODE_DATA_DIR/keelcode" ]; then
    local method="native"
    if [ -f "$KEELCODE_DATA_DIR/.install-method" ]; then
      method="$(cat "$KEELCODE_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_keelcode_proot_glibc
    else
      _install_keelcode_native
    fi
    return $?
  fi

  loading "Updating KeelCode (proot-distro)" _update_keelcode_proot_impl
}

update_keelcode() {
  _check_update_needed "KeelCode" "$(_get_installed_version keelcode)" "$(_get_remote_keelcode_version)" _update_keelcode
}

_update_keelcode_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_keelcode_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest KeelCode version"
    return 1
  fi

  local download_url="https://registry.npmjs.org/@keelcode-ai/keelcode/-/keelcode-$latest_version.tgz"

  _keelcode_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/keelcode-install &&
    curl -fsSL '$download_url' -o /tmp/keelcode-install/keelcode.tgz &&
    tar -zxf /tmp/keelcode-install/keelcode.tgz -C /tmp/keelcode-install --strip-components=2 package/bin &&
    rm -f /usr/local/bin/keelcode /usr/local/bin/rg &&
    mv /tmp/keelcode-install/keelcode /usr/local/bin/keelcode &&
    chmod +x /usr/local/bin/keelcode &&
    mv /tmp/keelcode-install/rg /usr/local/bin/rg &&
    chmod +x /usr/local/bin/rg &&
    rm -rf /tmp/keelcode-install
  " &>>"$LOG_FILE"

  local keelcode_bin
  keelcode_bin="$(_keelcode_detect_ubuntu_root)/usr/local/bin/keelcode"

  if [ ! -f "$keelcode_bin" ]; then
    log_error "KeelCode binary not found after update"
    return 1
  fi

  log_success "KeelCode (proot-distro) updated"
  return 0
}

reinstall_keelcode() {
  uninstall_keelcode
  install_keelcode
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_keelcode; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_keelcode; fi
if [[ "${1:-}" == "update" ]]; then update_keelcode; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_keelcode; fi
