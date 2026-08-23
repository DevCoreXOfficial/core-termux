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
AMP_DATA_DIR="$HOME/.local/share/core-termux-data/ampcode"

_amp_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_amp_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_amp_version_raw() {
  local raw
  raw=$(curl -fsSL "https://registry.npmjs.org/@ampcode/cli-linux-arm64/latest" 2>/dev/null)
  echo "$raw" | python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null
}

_get_latest_amp_version() {
  local raw
  raw=$(_spin_capture "Checking npm" _get_latest_amp_version_raw)
  _parse_version "$raw"
}

_get_latest_amp_version_silent() {
  local raw
  raw=$(curl -fsSL "https://registry.npmjs.org/@ampcode/cli-linux-arm64/latest" 2>/dev/null)
  echo "$raw" | python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null
}

_amp_install_deps_native() {
  loading "Installing glibc and dependencies" _amp_install_deps_native_impl
}

_amp_install_deps_native_impl() {
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
    ["curl"]="curl"
    ["tar"]="tar"
    ["python"]="python"
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

_download_amp_binary() {
  loading "Downloading AMP Code CLI" _download_amp_binary_impl
}

_download_amp_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_amp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest AMP Code CLI version"
    return 1
  fi

  mkdir -p "$AMP_DATA_DIR"

  local tarball="cli-linux-arm64-$latest_version.tgz"
  local download_url="https://registry.npmjs.org/@ampcode%2fcli-linux-arm64/-/cli-linux-arm64-$latest_version.tgz"

  if ! curl -fsSL "$download_url" -o "$AMP_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download AMP Code CLI binary"
    return 1
  fi

  if ! tar -zxf "$AMP_DATA_DIR/$tarball" -C "$AMP_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract AMP Code CLI binary"
    return 1
  fi

  rm -f "$AMP_DATA_DIR/$tarball"

  # The npm package tarball contains package/ with the binary
  if [ -f "$AMP_DATA_DIR/package/amp" ]; then
    mv "$AMP_DATA_DIR/package/amp" "$AMP_DATA_DIR/amp"
    rm -rf "$AMP_DATA_DIR/package"
  elif [ -f "$AMP_DATA_DIR/package/bin/amp.exe" ]; then
    mv "$AMP_DATA_DIR/package/bin/amp.exe" "$AMP_DATA_DIR/amp"
    rm -rf "$AMP_DATA_DIR/package"
  elif [ -f "$AMP_DATA_DIR/package/amp.exe" ]; then
    mv "$AMP_DATA_DIR/package/amp.exe" "$AMP_DATA_DIR/amp"
    rm -rf "$AMP_DATA_DIR/package"
  fi

  if [ ! -f "$AMP_DATA_DIR/amp" ]; then
    log_error "AMP Code CLI binary not found after extraction"
    return 1
  fi

  chmod +x "$AMP_DATA_DIR/amp"
  return 0
}

_compile_amp_helper() {
  loading "Compiling helper" _compile_amp_helper_impl
}

_compile_amp_helper_impl() {
  local HELPER_SRC="$CORE_TOOL_DIR/helper/amp_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/amp" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile amp helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/amp"
  return 0
}

_install_amp_native() {
  _amp_install_deps_native || return 1
  _download_amp_binary || return 1
  _compile_amp_helper || return 1
  log_success "AMP Code CLI installed natively"
  return 0
}

_install_amp_proot_glibc() {
  _amp_install_deps_native || return 1
  loading "Installing proot" _amp_install_proot_pkg || return 1
  _download_amp_binary || return 1
  loading "Creating proot wrapper" _amp_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$AMP_DATA_DIR/.install-method"
  log_success "AMP Code CLI installed with glibc + proot"
  return 0
}

_amp_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_amp_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/amp.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$AMP_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/amp"
  chmod +x "$PREFIX/bin/amp"
  return 0
}

_install_amp_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _amp_install_proot_distro || return 1
  loading "Installing Ubuntu container" _amp_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _amp_ubuntu_deps || return 1
  loading "Downloading AMP Code CLI (Ubuntu)" _amp_ubuntu_install_bin || return 1
  loading "Creating wrapper" _amp_create_ubuntu_wrapper || return 1

  log_success "AMP Code CLI installed (proot-distro)"
  return 0
}

_amp_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_amp_install_ubuntu() {
  if [ ! -d "$(_amp_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_amp_ubuntu_deps() {
  _amp_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_amp_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_amp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest AMP Code CLI version"
    return 1
  fi

  local download_url="https://registry.npmjs.org/@ampcode%2fcli-linux-arm64/-/cli-linux-arm64-$latest_version.tgz"

  _amp_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/amp-install &&
    curl -fsSL '$download_url' -o /tmp/amp-install/amp.tgz &&
    tar -zxf /tmp/amp-install/amp.tgz -C /tmp/amp-install &&
    mkdir -p /usr/local/bin &&
    mv /tmp/amp-install/package/amp /usr/local/bin/amp &&
    chmod +x /usr/local/bin/amp &&
    rm -rf /tmp/amp-install
  " &>>"$LOG_FILE"

  local amp_bin="$(_amp_detect_ubuntu_root)/usr/local/bin/amp"
  if [ ! -f "$amp_bin" ]; then
    log_error "AMP Code CLI binary not found after install"
    return 1
  fi
  return 0
}

_amp_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_amp_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/amp"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/amp"
  chmod +x "$PREFIX/bin/amp"
  return 0
}

install_amp_code_cli() {
  if command -v amp &>/dev/null; then
    log_info "AMP Code CLI is already installed"
    return 2
  fi

  log_info "Select installation method for AMP Code CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_amp_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_amp_native
    ;;
  *proot-distro*)
    _install_amp_proot
    ;;
  esac
}

uninstall_amp_code_cli() {
  _walkie_remove_wrapper amp
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/amp" ]; then
    log_warn "AMP Code CLI is not installed"
    return 1
  fi

  confirm_remove_configs "AMP Code CLI" \
    "$HOME/.config/amp" \
    "$HOME/.local/share/amp" \
    "$HOME/.cache/amp"

  loading "Uninstalling AMP Code CLI" _uninstall_amp_code_cli_impl
}

_uninstall_amp_code_cli_impl() {
  if [ -f "$AMP_DATA_DIR/amp" ]; then
    local method="native"
    if [ -f "$AMP_DATA_DIR/.install-method" ]; then
      method="$(cat "$AMP_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/amp"
    rm -rf "$AMP_DATA_DIR"
    log_success "AMP Code CLI ($method) uninstalled"
    return 0
  fi

  _amp_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/amp' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_amp_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# amp/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/amp" &>>"$LOG_FILE"; then
    log_success "AMP Code CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall AMP Code CLI"
    return 1
  fi
}

_update_amp_code_cli() {
  _update_amp_code_cli_impl
}

_update_amp_code_cli_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$AMP_DATA_DIR/amp" ]; then
    local method="native"
    if [ -f "$AMP_DATA_DIR/.install-method" ]; then
      method="$(cat "$AMP_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_amp_proot_glibc
    else
      _install_amp_native
    fi
    return $?
  fi

  loading "Updating AMP Code CLI (proot-distro)" _update_amp_proot_impl
}

update_amp_code_cli() {
  _check_update_needed "AMP Code CLI" "$(_get_installed_version amp)" "$(_get_latest_amp_version)" _update_amp_code_cli
}

_update_amp_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_amp_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest AMP Code CLI version"
    return 1
  fi

  local download_url="https://registry.npmjs.org/@ampcode%2fcli-linux-arm64/-/cli-linux-arm64-$latest_version.tgz"

  _amp_proot_ubuntu /bin/bash -c "
    rm -f /usr/local/bin/amp &&
    mkdir -p /tmp/amp-install &&
    curl -fsSL '$download_url' -o /tmp/amp-install/amp.tgz &&
    tar -zxf /tmp/amp-install/amp.tgz -C /tmp/amp-install &&
    mv /tmp/amp-install/package/amp /usr/local/bin/amp &&
    chmod +x /usr/local/bin/amp &&
    rm -rf /tmp/amp-install
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_amp_detect_ubuntu_root)"
  local amp_bin="$ubuntu_root/usr/local/bin/amp"

  if [ ! -f "$amp_bin" ]; then
    log_error "AMP Code CLI binary not found after update"
    return 1
  fi

  log_success "AMP Code CLI (proot-distro) updated"
  return 0
}

reinstall_amp_code_cli() {
  uninstall_amp_code_cli
  install_amp_code_cli
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_amp_code_cli; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_amp_code_cli; fi
if [[ "${1:-}" == "update" ]]; then update_amp_code_cli; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_amp_code_cli; fi
