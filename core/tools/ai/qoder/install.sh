#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"
QODER_DATA_DIR="$HOME/.local/share/core-termux-data/qoder"
QODER_MANIFEST_URL="https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/channels/manifest.json"

_qoder_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_qoder_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_qoder_version() {
  curl -fsSL "$QODER_MANIFEST_URL" |
    sed -n 's/.*"latest"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

_get_qoder_download_url() {
  local arch="${1:-arm64}"
  local manifest
  manifest="$(curl -fsSL "$QODER_MANIFEST_URL")"

  printf '%s' "$manifest" | tr -d '\n\r\t ' | sed 's/},{/}\n{/g' |
    grep -F '"os":"linux"' | grep -F "\"arch\":\"$arch\"" | head -n1 |
    sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

_qoder_install_deps_native() {
  loading "Installing glibc and dependencies" _qoder_install_deps_native_impl
}

_qoder_install_deps_native_impl() {
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

_download_qoder_binary() {
  loading "Downloading Qoder" _download_qoder_binary_impl
}

_download_qoder_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_qoder_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Qoder version"
    return 1
  fi

  local download_url
  download_url=$(_get_qoder_download_url "arm64")
  if [ -z "$download_url" ]; then
    log_error "No download URL found for linux/arm64"
    return 1
  fi

  mkdir -p "$QODER_DATA_DIR"

  local archive_filename
  archive_filename=$(basename "$download_url")

  if ! curl -fsSL "$download_url" -o "$QODER_DATA_DIR/$archive_filename" &>>"$LOG_FILE"; then
    log_error "Failed to download Qoder binary"
    return 1
  fi

  if ! tar -zxf "$QODER_DATA_DIR/$archive_filename" -C "$QODER_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Qoder binary"
    return 1
  fi

  rm -f "$QODER_DATA_DIR/$archive_filename"

  if [ ! -f "$QODER_DATA_DIR/qodercli" ]; then
    log_error "Qoder binary not found after extraction"
    return 1
  fi

  chmod +x "$QODER_DATA_DIR/qodercli"
  return 0
}

_compile_qoder_helper() {
  loading "Compiling helper" _compile_qoder_helper_impl
}

_compile_qoder_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/qoder/helper/qoder_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/qoder" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile qoder helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/qoder"
  return 0
}

_install_qoder_native() {
  _qoder_install_deps_native || return 1
  _download_qoder_binary || return 1
  _compile_qoder_helper || return 1
  log_success "Qoder installed natively"
  return 0
}

_install_qoder_proot() {
  loading "Installing Qoder (proot-distro)" _install_qoder_proot_impl
}

_install_qoder_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_qoder_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _qoder_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"

  local download_url
  download_url=$(_get_qoder_download_url "arm64")
  if [ -z "$download_url" ]; then
    log_error "No download URL found for linux/arm64"
    return 1
  fi

  local ubuntu_root
  ubuntu_root="$(_qoder_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local qoder_dir="$ubuntu_root/root/.qodercli"
  mkdir -p "$qoder_dir"

  local archive_filename
  archive_filename=$(basename "$download_url")

  if ! curl -fsSL "$download_url" -o "$qoder_dir/$archive_filename" &>>"$LOG_FILE"; then
    log_error "Failed to download Qoder binary"
    return 1
  fi

  if ! tar -zxf "$qoder_dir/$archive_filename" -C "$qoder_dir" &>>"$LOG_FILE"; then
    log_error "Failed to extract Qoder binary"
    return 1
  fi

  rm -f "$qoder_dir/$archive_filename"

  if [ ! -f "$qoder_dir/qodercli" ]; then
    log_error "Qoder binary not found after extraction"
    return 1
  fi

  chmod +x "$qoder_dir/qodercli"

  local wrapper_src="$CORE_PATH/tools/ai/qoder/bin/qoder"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/qoder"
  chmod +x "$PREFIX/bin/qoder"

  if ! grep -q '.qodercli' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# qoder\nexport PATH=/root/.qodercli:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_qoder() {
  if command -v qoder &>/dev/null; then
    log_info "Qoder is already installed"
    return 2
  fi

  log_info "Select installation method for Qoder:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_qoder_native
    ;;
  *Proot-distro*)
    _install_qoder_proot
    ;;
  esac
}

uninstall_qoder() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/qoder" ]; then
    log_warn "Qoder is not installed"
    return 1
  fi

  loading "Uninstalling Qoder" _uninstall_qoder_impl
}

_uninstall_qoder_impl() {
  if [ -f "$QODER_DATA_DIR/qodercli" ]; then
    rm -f "$PREFIX/bin/qoder"
    rm -rf "$QODER_DATA_DIR"
    log_success "Qoder (native) uninstalled"
    return 0
  fi

  _qoder_proot_ubuntu /bin/bash -c 'rm -rf /root/.qodercli' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_qoder_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# qoder/d; /export PATH=\/root\/.qodercli:/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/qoder" &>>"$LOG_FILE"; then
    log_success "Qoder (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Qoder"
    return 1
  fi
}

_update_qoder() {
	_update_qoder_impl
}

_update_qoder_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$QODER_DATA_DIR/qodercli" ]; then
    _install_qoder_native
    return $?
  fi

  loading "Updating Qoder (proot-distro)" _update_qoder_proot_impl
}

_get_remote_qoder_version() {
  _spin_capture "Checking Qoder" _get_latest_qoder_version
}

update_qoder() {
  _check_update_needed "Qoder" "$(_get_installed_version qoder)" "$(_get_remote_qoder_version)" _update_qoder
}

_update_qoder_proot_impl() {
  local ubuntu_root
  ubuntu_root="$(_qoder_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  rm -rf "$ubuntu_root/root/.qodercli"

  local download_url
  download_url=$(_get_qoder_download_url "arm64")
  if [ -z "$download_url" ]; then
    log_error "No download URL found for linux/arm64"
    return 1
  fi

  local qoder_dir="$ubuntu_root/root/.qodercli"
  mkdir -p "$qoder_dir"

  local archive_filename
  archive_filename=$(basename "$download_url")

  if ! curl -fsSL "$download_url" -o "$qoder_dir/$archive_filename" &>>"$LOG_FILE"; then
    log_error "Failed to download Qoder binary"
    return 1
  fi

  if ! tar -zxf "$qoder_dir/$archive_filename" -C "$qoder_dir" &>>"$LOG_FILE"; then
    log_error "Failed to extract Qoder binary"
    return 1
  fi

  rm -f "$qoder_dir/$archive_filename"

  if [ ! -f "$qoder_dir/qodercli" ]; then
    log_error "Qoder binary not found after extraction"
    return 1
  fi

  chmod +x "$qoder_dir/qodercli"

  log_success "Qoder (proot-distro) updated"
  return 0
}

reinstall_qoder() {
  uninstall_qoder
  install_qoder
}
