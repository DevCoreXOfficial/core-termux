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

: "${CORE_CACHE:=$HOME/.cache/core-termux}"
: "${CORE_PATH:=$HOME/core-termux/core}"
: "${PREFIX:=/data/data/com.termux/files/usr}"

LOG_FILE="$CORE_CACHE/install_ai.log"
DROID_DATA_DIR="$HOME/.local/share/core-termux-data/droid-factory"

# ===== PROOT HELPERS =====

_droid_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_droid_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

# ===== VERSION DETECTION =====
# The official installer hardcodes VER inside https://app.factory.ai/cli

_get_latest_droid_version() {
  local raw
  raw=$(_spin_capture "Checking Factory" curl -fsSL "https://app.factory.ai/cli" 2>/dev/null)
  echo "$raw" | grep -oE 'VER="[^"]+"' | head -1 | cut -d'"' -f2
}

_get_latest_droid_version_silent() {
  local raw
  raw=$(curl -fsSL "https://app.factory.ai/cli" 2>/dev/null)
  echo "$raw" | grep -oE 'VER="[^"]+"' | head -1 | cut -d'"' -f2
}

# ===== NATIVE INSTALL (glibc) =====

_droid_install_deps_native() {
  loading "Installing glibc and dependencies" _droid_install_deps_native_impl
}

_droid_install_deps_native_impl() {
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
    ["jq"]="jq"
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

_download_droid_binary() {
  loading "Downloading Droid Factory binary" _download_droid_binary_impl
}

_download_droid_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_droid_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Droid Factory version"
    return 1
  fi

  mkdir -p "$DROID_DATA_DIR"

  local binary_url="https://downloads.factory.ai/factory-cli/releases/$latest_version/linux/arm64/droid"
  local sha_url="$binary_url.sha256"

  if ! curl -fsSL "$binary_url" -o "$DROID_DATA_DIR/droid" &>>"$LOG_FILE"; then
    log_error "Failed to download Droid Factory binary"
    return 1
  fi

  local expected actual
  expected="$(curl -fsSL "$sha_url" 2>/dev/null | awk '{print $1}')"
  if [ -n "$expected" ] && command -v sha256sum &>/dev/null; then
    actual="$(sha256sum "$DROID_DATA_DIR/droid" | awk '{print $1}')"
    if [ "$actual" != "$expected" ]; then
      log_error "Checksum verification failed"
      rm -f "$DROID_DATA_DIR/droid"
      return 1
    fi
  fi

  chmod +x "$DROID_DATA_DIR/droid"

  # Save version for update checks
  echo "$latest_version" > "$DROID_DATA_DIR/version"

  return 0
}

_compile_droid_helper() {
  loading "Compiling droid helper" _compile_droid_helper_impl
}

_compile_droid_helper_impl() {
  local HELPER_SRC="$CORE_TOOL_DIR/helper/droid_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/droid" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile droid helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/droid"

  return 0
}

_install_droid_native() {
  _droid_install_deps_native || return 1
  _download_droid_binary || return 1
  _compile_droid_helper || return 1
  log_success "Droid Factory installed natively"
  return 0
}

_install_droid_proot_glibc() {
  _droid_install_deps_native || return 1
  loading "Installing proot" _droid_install_proot_pkg || return 1
  _download_droid_binary || return 1
  loading "Creating proot wrapper" _droid_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$DROID_DATA_DIR/.install-method"
  log_success "Droid Factory installed with glibc + proot"
  return 0
}

_droid_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_droid_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/droid.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$DROID_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/droid"
  chmod +x "$PREFIX/bin/droid"
  return 0
}

# ===== PROOT-DISTRO INSTALL =====

_install_droid_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _droid_install_proot_distro || return 1
  loading "Installing Ubuntu container" _droid_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _droid_ubuntu_deps || return 1
  loading "Downloading Droid Factory (Ubuntu)" _droid_ubuntu_install_bin || return 1
  loading "Creating wrapper" _droid_create_ubuntu_wrapper || return 1

  log_success "Droid Factory installed (proot-distro)"
  return 0
}

_droid_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_droid_install_ubuntu() {
  if [ ! -d "$(_droid_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_droid_ubuntu_deps() {
  _droid_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_droid_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_droid_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Droid Factory version"
    return 1
  fi

  local binary_url="https://downloads.factory.ai/factory-cli/releases/$latest_version/linux/arm64/droid"

  _droid_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/droid-install &&
    curl -fsSL '$binary_url' -o /tmp/droid-install/droid &&
    mkdir -p /usr/local/bin &&
    mv /tmp/droid-install/droid /usr/local/bin/droid &&
    chmod +x /usr/local/bin/droid &&
    rm -rf /tmp/droid-install
  " &>>"$LOG_FILE"

  local droid_bin="$(_droid_detect_ubuntu_root)/usr/local/bin/droid"
  if [ ! -f "$droid_bin" ]; then
    log_error "Droid Factory binary not found after install"
    return 1
  fi
  return 0
}

_droid_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_droid_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/droid"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/droid"
  chmod +x "$PREFIX/bin/droid"
  return 0
}

# ===== MAIN INSTALL =====

install_droid_factory() {
  if command -v droid &>/dev/null; then
    log_info "Droid Factory (droid) is already installed"
    return 2
  fi

  log_info "Select installation method for Droid Factory:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_droid_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_droid_native
    ;;
  *proot-distro*)
    _install_droid_proot
    ;;
  esac
}

# ===== UNINSTALL =====

_droid_is_native() {
  [ -d "$DROID_DATA_DIR" ] && [ -f "$DROID_DATA_DIR/droid" ] && [ ! -f "$DROID_DATA_DIR/.install-method" ]
}

_droid_is_proot_glibc() {
  [ -f "$DROID_DATA_DIR/.install-method" ] && [ "$(cat "$DROID_DATA_DIR/.install-method")" = "proot-glibc" ]
}

_droid_is_proot() {
  local root
  root="$(_droid_detect_ubuntu_root)"
  [ -n "$root" ] && [ -f "$root/usr/local/bin/droid" ]
}

_uninstall_droid_native_impl() {
  rm -f "$PREFIX/bin/droid"
  rm -rf "$DROID_DATA_DIR"
}

uninstall_droid_factory() {
  _walkie_remove_wrapper droid
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! _droid_is_proot_glibc && ! _droid_is_native && ! _droid_is_proot; then
    log_info "Droid Factory is not installed"
    return 2
  fi

  confirm_remove_configs "Droid Factory" \
    "$HOME/.factory"

  if _droid_is_proot_glibc; then
    loading "Uninstalling Droid Factory (glibc + proot)" _uninstall_droid_native_impl
    log_success "Droid Factory (glibc + proot) uninstalled"
  elif _droid_is_native; then
    loading "Uninstalling Droid Factory (glibc)" _uninstall_droid_native_impl
    log_success "Droid Factory (glibc) uninstalled"
  elif _droid_is_proot; then
    loading "Uninstalling Droid Factory (proot-distro)" _uninstall_droid_proot_impl
    log_success "Droid Factory (proot-distro) uninstalled"
  else
    log_info "Droid Factory is not installed"
    return 2
  fi
  return 0
}

_uninstall_droid_proot_impl() {
  _droid_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/droid' &>>"$LOG_FILE"

  rm -f "$PREFIX/bin/droid"
  return 0
}

# ===== UPDATE =====

_update_droid_native_impl() {
  rm -f "$PREFIX/bin/droid"
  rm -rf "$DROID_DATA_DIR"
  _install_droid_native
}

_update_droid_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_droid_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Droid Factory version"
    return 1
  fi

  local binary_url="https://downloads.factory.ai/factory-cli/releases/$latest_version/linux/arm64/droid"

  _droid_proot_ubuntu /bin/bash -c "
    rm -f /usr/local/bin/droid &&
    mkdir -p /tmp/droid-update &&
    curl -fsSL '$binary_url' -o /tmp/droid-update/droid &&
    mv /tmp/droid-update/droid /usr/local/bin/droid &&
    chmod +x /usr/local/bin/droid &&
    rm -rf /tmp/droid-update
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_droid_detect_ubuntu_root)"

  if [ ! -f "$ubuntu_root/usr/local/bin/droid" ]; then
    log_error "Droid Factory binary not found after update"
    return 1
  fi

  log_success "Droid Factory (proot-distro) updated"
  return 0
}

_update_droid_impl() {
  if _droid_is_proot_glibc; then
    _install_droid_proot_glibc
    return $?
  fi

  if _droid_is_native; then
    _update_droid_native_impl
    return $?
  fi

  if _droid_is_proot; then
    loading "Updating Droid Factory (proot-distro)" _update_droid_proot_impl
    return $?
  fi

  log_warn "Could not detect Droid Factory installation method"
  return 1
}

update_droid_factory() {
  _check_update_needed "Droid Factory" "$(_get_installed_version droid)" "$(_get_latest_droid_version)" _update_droid_impl
}

# ===== REINSTALL =====

reinstall_droid_factory() {
  uninstall_droid_factory
  install_droid_factory
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_droid_factory; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_droid_factory; fi
if [[ "${1:-}" == "update" ]]; then update_droid_factory; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_droid_factory; fi
