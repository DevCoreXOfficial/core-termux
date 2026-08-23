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
OMP_DATA_DIR="$HOME/.local/share/core-termux-data/oh-my-pi"

# ===== PROOT HELPERS =====

_omp_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_omp_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

# ===== VERSION DETECTION =====

_get_latest_omp_version() {
  local raw
  raw=$(_spin_capture "Checking GitHub" curl -fsSL "https://api.github.com/repos/can1357/oh-my-pi/releases?per_page=5" 2>/dev/null)
  echo "$raw" | jq -r '[.[] | select(.tag_name | startswith("v"))][0].tag_name' 2>/dev/null
}

_get_latest_omp_version_silent() {
  local raw
  raw=$(curl -fsSL "https://api.github.com/repos/can1357/oh-my-pi/releases?per_page=5" 2>/dev/null)
  echo "$raw" | jq -r '[.[] | select(.tag_name | startswith("v"))][0].tag_name' 2>/dev/null
}

# ===== NATIVE INSTALL (glibc) =====

_omp_install_deps_native() {
  loading "Installing glibc and dependencies" _omp_install_deps_native_impl
}

_omp_install_deps_native_impl() {
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

_download_omp_binary() {
  loading "Downloading Oh-My-Pi standalone binary" _download_omp_binary_impl
}

_download_omp_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_omp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Oh-My-Pi version"
    return 1
  fi

  mkdir -p "$OMP_DATA_DIR"

  local download_url="https://github.com/can1357/oh-my-pi/releases/download/$latest_version/omp-linux-arm64"

  if ! curl -fsSL "$download_url" -o "$OMP_DATA_DIR/omp" &>>"$LOG_FILE"; then
    log_error "Failed to download Oh-My-Pi binary"
    return 1
  fi

  chmod +x "$OMP_DATA_DIR/omp"

  # Save version for update checks
  echo "$latest_version" > "$OMP_DATA_DIR/version"

  return 0
}

_compile_omp_helper() {
  loading "Compiling omp helper" _compile_omp_helper_impl
}

_compile_omp_helper_impl() {
  local HELPER_SRC="$CORE_TOOL_DIR/helper/omp_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/omp" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile omp helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/omp"

  return 0
}

_install_omp_native() {
  _omp_install_deps_native || return 1
  _download_omp_binary || return 1
  _compile_omp_helper || return 1
  log_success "Oh-My-Pi (omp) installed natively"
  return 0
}

_install_omp_proot_glibc() {
  _omp_install_deps_native || return 1
  loading "Installing proot" _omp_install_proot_pkg || return 1
  _download_omp_binary || return 1
  loading "Creating proot wrapper" _omp_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$OMP_DATA_DIR/.install-method"
  log_success "Oh-My-Pi installed with glibc + proot"
  return 0
}

_omp_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_omp_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/omp.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$OMP_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/omp"
  chmod +x "$PREFIX/bin/omp"
  return 0
}

# ===== PROOT-DISTRO INSTALL =====

_install_omp_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _omp_install_proot_distro || return 1
  loading "Installing Ubuntu container" _omp_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _omp_ubuntu_deps || return 1
  loading "Downloading Oh-My-Pi (Ubuntu)" _omp_ubuntu_install_bin || return 1
  loading "Creating wrapper" _omp_create_ubuntu_wrapper || return 1

  log_success "Oh-My-Pi (omp) installed (proot-distro)"
  return 0
}

_omp_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_omp_install_ubuntu() {
  if [ ! -d "$(_omp_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_omp_ubuntu_deps() {
  _omp_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"
}

_omp_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_omp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Oh-My-Pi version"
    return 1
  fi

  local download_url="https://github.com/can1357/oh-my-pi/releases/download/$latest_version/omp-linux-arm64"

  _omp_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/omp-install &&
    curl -fsSL '$download_url' -o /tmp/omp-install/omp &&
    mkdir -p /usr/local/bin &&
    mv /tmp/omp-install/omp /usr/local/bin/omp &&
    chmod +x /usr/local/bin/omp &&
    rm -rf /tmp/omp-install
  " &>>"$LOG_FILE"

  local omp_bin
  omp_bin="$(_omp_detect_ubuntu_root)/usr/local/bin/omp"
  if [ ! -f "$omp_bin" ]; then
    log_error "Oh-My-Pi binary not found after install"
    return 1
  fi
  return 0
}

_omp_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_omp_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/omp"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/omp"
  chmod +x "$PREFIX/bin/omp"
  return 0
}

# ===== MAIN INSTALL =====

install_oh_my_pi() {
  if command -v omp &>/dev/null; then
    log_info "Oh-My-Pi (omp) is already installed"
    return 2
  fi

  log_info "Select installation method for Oh-My-Pi:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_omp_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_omp_native
    ;;
  *proot-distro*)
    _install_omp_proot
    ;;
  esac
}

# ===== UNINSTALL =====

_uninstall_omp_native_impl() {
  rm -f "$PREFIX/bin/omp"
  rm -rf "$OMP_DATA_DIR"
}

_omp_is_native() {
  [ -d "$OMP_DATA_DIR" ] && [ -f "$OMP_DATA_DIR/omp" ]
}

_omp_is_proot_glibc() {
  [ -f "$OMP_DATA_DIR/.install-method" ] && [ "$(cat "$OMP_DATA_DIR/.install-method")" = "proot-glibc" ]
}

_omp_is_proot() {
  local root
  root="$(_omp_detect_ubuntu_root)"
  [ -n "$root" ] && [ -f "$root/usr/local/bin/omp" ]
}

uninstall_oh_my_pi() {
  _walkie_remove_wrapper omp
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! _omp_is_proot_glibc && ! _omp_is_native && ! _omp_is_proot; then
    log_info "Oh-My-Pi is not installed"
    return 2
  fi

  confirm_remove_configs "Oh My Pi" \
    "$HOME/.omp"

  if _omp_is_proot_glibc; then
    loading "Uninstalling Oh-My-Pi (native + proot)" _uninstall_omp_native_impl
    log_success "Oh-My-Pi (native + proot) uninstalled"
  elif _omp_is_native; then
    loading "Uninstalling Oh-My-Pi (native)" _uninstall_omp_native_impl
    log_success "Oh-My-Pi (native) uninstalled"
  elif _omp_is_proot; then
    loading "Uninstalling Oh-My-Pi (proot-distro)" _uninstall_omp_proot_impl
    log_success "Oh-My-Pi (proot-distro) uninstalled"
  else
    log_info "Oh-My-Pi is not installed"
    return 2
  fi
  return 0
}

_uninstall_omp_proot_impl() {
  _omp_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/omp' &>>"$LOG_FILE"

  rm -f "$PREFIX/bin/omp"
  return 0
}

# ===== UPDATE =====

_update_omp_native_impl() {
  rm -f "$PREFIX/bin/omp"
  rm -rf "$OMP_DATA_DIR"
  _install_omp_native
}

_update_omp_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_omp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Oh-My-Pi version"
    return 1
  fi

  local download_url="https://github.com/can1357/oh-my-pi/releases/download/$latest_version/omp-linux-arm64"

  _omp_proot_ubuntu /bin/bash -c "
    rm -f /usr/local/bin/omp &&
    mkdir -p /tmp/omp-update &&
    curl -fsSL '$download_url' -o /tmp/omp-update/omp &&
    mv /tmp/omp-update/omp /usr/local/bin/omp &&
    chmod +x /usr/local/bin/omp &&
    rm -rf /tmp/omp-update
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_omp_detect_ubuntu_root)"

  if [ ! -f "$ubuntu_root/usr/local/bin/omp" ]; then
    log_error "Oh-My-Pi binary not found after update"
    return 1
  fi

  log_success "Oh-My-Pi (proot-distro) updated"
  return 0
}

_update_omp_impl() {
  if _omp_is_proot_glibc; then
    _install_omp_proot_glibc
    return $?
  fi

  if _omp_is_native; then
    _update_omp_native_impl
    return $?
  fi

  if _omp_is_proot; then
    loading "Updating Oh-My-Pi (proot-distro)" _update_omp_proot_impl
    return $?
  fi

  log_warn "Could not detect Oh-My-Pi installation method"
  return 1
}

update_oh_my_pi() {
  _check_update_needed "Oh-My-Pi" "$(_get_installed_version omp)" "$(_get_latest_omp_version)" _update_omp_impl
}

# ===== REINSTALL =====

reinstall_oh_my_pi() {
  uninstall_oh_my_pi
  install_oh_my_pi
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_oh_my_pi; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_oh_my_pi; fi
if [[ "${1:-}" == "update" ]]; then update_oh_my_pi; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_oh_my_pi; fi
