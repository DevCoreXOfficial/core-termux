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
# legacy v1 (GitHub anomalyco/opencode releases) - kept only so old installs can be cleaned up
OPENCODE_DATA_DIR="$HOME/.local/share/core-termux-data/opencode"
# v2 (npm @opencode/cli-*) - this is what install/update manage
OPENCODE_V2_DATA_DIR="$HOME/.local/share/core-termux-data/opencode-v2"
OPENCODE_V2_VERSION_URL="https://opencode.ai/update/api/latest/cli/npm"
OPENCODE_V2_REGISTRY="https://registry.npmjs.org"

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

_get_latest_opencode_v2_version() {
  local json
  json=$(curl -fsSL --max-time 30 "$OPENCODE_V2_VERSION_URL" 2>/dev/null)
  echo "$json" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p' | head -1
}

_get_remote_opencode_v2_version() {
  _parse_version "$(_get_latest_opencode_v2_version)"
}

# npm package target triple, e.g. linux-arm64
_opencode_v2_target() {
  local os arch
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)
  case "$arch" in
  aarch64 | arm64) arch="arm64" ;;
  x86_64 | amd64) arch="x64" ;;
  esac
  echo "$os-$arch"
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
  latest_version=$(_get_latest_opencode_v2_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest OpenCode version"
    return 1
  fi

  local target package tarball download_url
  target=$(_opencode_v2_target)
  package="@opencode/cli-$target"
  tarball="cli-$target-$latest_version.tgz"
  download_url="$OPENCODE_V2_REGISTRY/$package/-/$tarball"

  # Stage inside the target dir so the final swap is a same-filesystem rename.
  # A failed download/extract must never leave a truncated binary behind.
  mkdir -p "$OPENCODE_V2_DATA_DIR"
  local staging="$OPENCODE_V2_DATA_DIR/.staging.$$"
  rm -rf "$staging"
  mkdir -p "$staging"

  if ! curl -fsSL "$download_url" -o "$staging/$tarball" &>>"$LOG_FILE"; then
    rm -rf "$staging"
    log_error "Failed to download OpenCode binary"
    return 1
  fi

  if ! tar -zxf "$staging/$tarball" -C "$staging" &>>"$LOG_FILE"; then
    rm -rf "$staging"
    log_error "Failed to extract OpenCode binary"
    return 1
  fi

  if [ ! -f "$staging/package/bin/opencode" ]; then
    rm -rf "$staging"
    log_error "OpenCode binary not found after extraction"
    return 1
  fi

  if ! mv -f "$staging/package/bin/opencode" "$OPENCODE_V2_DATA_DIR/opencode"; then
    rm -rf "$staging"
    log_error "Failed to install OpenCode binary"
    return 1
  fi

  rm -rf "$staging"
  chmod +x "$OPENCODE_V2_DATA_DIR/opencode"
  printf '%s' "$latest_version" >"$OPENCODE_V2_DATA_DIR/.install-version"
  return 0
}

_install_opencode_v2_launcher() {
  loading "Installing launcher" _install_opencode_v2_launcher_impl
}

_install_opencode_v2_launcher_impl() {
  local launcher_src="$CORE_TOOL_DIR/bin/opencode.v2"
  if [ ! -f "$launcher_src" ]; then
    log_error "Launcher template not found at $launcher_src"
    return 1
  fi

  sed "s|__DATA_DIR__|$OPENCODE_V2_DATA_DIR|g" "$launcher_src" >"$PREFIX/bin/opencode" || {
    log_error "Failed to write launcher"
    return 1
  }
  chmod +x "$PREFIX/bin/opencode"
  return 0
}

_install_opencode_native() {
  _opencode_install_deps_native || return 1
  _download_opencode_binary || return 1
  _install_opencode_v2_launcher || return 1
  log_success "OpenCode v2 installed natively"
  return 0
}

_install_opencode_proot_glibc() {
  _opencode_install_deps_native || return 1
  loading "Installing proot" _opencode_install_proot_pkg || return 1
  _download_opencode_binary || return 1
  loading "Creating proot wrapper" _opencode_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$OPENCODE_V2_DATA_DIR/.install-method"
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
  sed "s|__DATA_DIR__|$OPENCODE_V2_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/opencode"
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
  if _opencode_installed; then
    local method
    method="$(_opencode_install_method)"
    rm -f "$PREFIX/bin/opencode"
    # managed v2 dir, plus any legacy v1 dir left by older installs
    rm -rf "$OPENCODE_V2_DATA_DIR" "$OPENCODE_DATA_DIR"
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

_opencode_installed() {
  [ -f "$OPENCODE_V2_DATA_DIR/opencode" ] || [ -f "$OPENCODE_DATA_DIR/opencode" ]
}

# v2 dir wins; fall back to the legacy v1 dir so pre-existing installs report correctly
_opencode_install_method() {
  local method_file
  for method_file in "$OPENCODE_V2_DATA_DIR/.install-method" "$OPENCODE_DATA_DIR/.install-method"; do
    if [ -f "$method_file" ]; then
      cat "$method_file"
      return 0
    fi
  done
  echo "native"
}

_update_opencode() {
	_update_opencode_impl
}

_update_opencode_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if _opencode_installed; then
    local method
    method="$(_opencode_install_method)"
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
  _check_update_needed "OpenCode" "$(_get_installed_version opencode)" "$(_get_remote_opencode_v2_version)" _update_opencode
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
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version opencode; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_opencode_v2_version; fi
