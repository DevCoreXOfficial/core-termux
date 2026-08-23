#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_lang.log"
BUN_DATA_DIR="$HOME/.local/share/core-termux-data/bun"
_BUN_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${_BUN_INSTALL_DIR}/src"

# ===== PROOT HELPERS =====

_bun_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_bun_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

# ===== VERSION DETECTION =====

_get_bun_remote_version() {
  _spin_capture "Checking GitHub" curl -fsSL "https://api.github.com/repos/oven-sh/bun/releases/latest" 2>/dev/null |
    grep '"tag_name":' | sed -E 's/.*"bun-v([^"]+)".*/\1/'
}



# ===== NATIVE INSTALL =====























# ===== PROOT-DISTRO INSTALL =====

_install_bun_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  local version
  version="$(_get_bun_remote_version_silent)"
  if [ -z "$version" ]; then
    log_error "Failed to fetch latest Bun version"
    return 1
  fi

  _install_bun_proot_impl "$version"
}

_install_bun_proot_impl() {
  local version="$1"

  if ! command -v proot-distro &>/dev/null; then
    loading "Installing proot-distro" _install_bun_proot_deps
  fi

  if [ ! -d "$(_bun_detect_ubuntu_root)" ]; then
    loading "Installing Ubuntu container" _install_bun_proot_ubuntu
  fi

  loading "Installing dependencies in Ubuntu" _install_bun_proot_deps_ubuntu

  local download_url="https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip"

  loading "Downloading and installing Bun v${version}" _install_bun_proot_bun "$download_url"

  local ubuntu_root
  ubuntu_root="$(_bun_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local bun_bin="$ubuntu_root/usr/local/bin/bun"

  if [ ! -f "$bun_bin" ]; then
    log_error "Bun binary not found after install"
    return 1
  fi

  loading "Creating wrappers" _install_bun_proot_wrappers "$ubuntu_root"

  return 0
}

_install_bun_proot_deps() {
  yes | pkg install proot-distro &>>"$LOG_FILE"
}

_install_bun_proot_ubuntu() {
  proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
}

_install_bun_proot_deps_ubuntu() {
  _bun_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates unzip' \
    &>>"$LOG_FILE"
}

_install_bun_proot_bun() {
  local download_url="$1"

  _bun_proot_ubuntu /bin/bash -c "
    export HOME=/root TMPDIR=/tmp
    cd /tmp &&
    curl -fsSL '$download_url' -o bun.zip &&
    unzip -o bun.zip >/dev/null 2>&1 &&
    mkdir -p /usr/local/bin &&
    mv bun-linux-aarch64/bun /usr/local/bin/bun &&
    chmod +x /usr/local/bin/bun &&
    ln -sf /usr/local/bin/bun /usr/local/bin/bunx &&
    rm -rf bun.zip bun-linux-aarch64
  " &>>"$LOG_FILE"
}

_install_bun_proot_wrappers() {
  local ubuntu_root="$1"

  local wrapper_src="$CORE_TOOL_DIR/bin/bun"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/bun"
  chmod +x "$PREFIX/bin/bun"

  local wrapper_bunx_src="$CORE_TOOL_DIR/bin/bunx"
  if [ -f "$wrapper_bunx_src" ]; then
    sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_bunx_src" >"$PREFIX/bin/bunx"
    chmod +x "$PREFIX/bin/bunx"
  else
    ln -sf "$PREFIX/bin/bun" "$PREFIX/bin/bunx"
  fi
}

# ===== PATH SETUP =====



_bun_setup_path_proot() {
  local ubuntu_root
  ubuntu_root="$(_bun_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    return 0
  fi

  # Inside ubuntu, bun is at /usr/local/bin which is already in PATH.
  # Still add the custom path if user wants it for global bins.
  local rc_file="$ubuntu_root/root/.bashrc"
  local path_line='export PATH="$PATH:/usr/local/bin"'

  if [ -f "$rc_file" ]; then
    if ! grep -qxF "$path_line" "$rc_file" 2>/dev/null; then
      echo "" >>"$rc_file"
      echo "# Added by core-termux bun installer" >>"$rc_file"
      echo "$path_line" >>"$rc_file"
      log_success "Added bun PATH in Ubuntu container (root)"
    fi
  fi
}

# ===== MAIN INSTALL =====

install_bun() {
  if command -v bun &>/dev/null; then
    log_info "Bun is already installed"
    return 2
  fi

  mkdir -p "$(dirname "$LOG_FILE")"

  log_info "Select installation method for Bun:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Android Bionic" \
    "Proot-distro (alternative) - Ubuntu Container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_bun_native || return 1
    _bun_setup_path_native
    ;;
  *Proot-distro*)
    _install_bun_proot || return 1
    _bun_setup_path_proot
    ;;
  esac

  local installed_version
  installed_version=$(bun --version 2>/dev/null || echo "unknown")
  log_success "Bun v${installed_version} installed successfully"
  return 0
}

# ===== UNINSTALL =====

_uninstall_bun_native_impl() {
  rm -f "$PREFIX/bin/bun" "$PREFIX/bin/bunx" "$PREFIX/bin/bun.real" "$PREFIX/bin/bun-bundle"
  rm -f "$PREFIX/lib/bun-android-shim.so"
  rm -rf "$BUN_DATA_DIR"
}

_uninstall_bun_proot_impl() {
  _bun_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/bun' &>>"$LOG_FILE"

  rm -f "$PREFIX/bin/bun" "$PREFIX/bin/bunx"
  return 0
}

_bun_is_native() {
  [ -f "$PREFIX/bin/bun.real" ] || [ -d "$BUN_DATA_DIR/download/bun-linux-aarch64-android" ]
}

_bun_is_proot() {
  local root
  root="$(_bun_detect_ubuntu_root)"
  [ -n "$root" ] && [ -f "$root/usr/local/bin/bun" ]
}

uninstall_bun() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! _bun_is_native && ! _bun_is_proot; then
    log_info "Bun is not installed"
    return 2
  fi

  confirm_remove_configs "Bun" \
    "$HOME/.bun" \
    "$HOME/.bunfig.toml" \
    "$HOME/.cache/bun"

  if _bun_is_native; then
    loading "Uninstalling Bun (native)" _uninstall_bun_native_impl
    log_success "Bun (native) uninstalled"
  elif _bun_is_proot; then
    loading "Uninstalling Bun (proot-distro)" _uninstall_bun_proot_impl
    log_success "Bun (proot-distro) uninstalled"
  else
    log_info "Bun is not installed"
    return 2
  fi
  return 0
}

# ===== UPDATE =====

_update_bun_native_impl() {
  rm -f "$PREFIX/bin/bun" "$PREFIX/bin/bunx" "$PREFIX/bin/bun.real" "$PREFIX/bin/bun-bundle"
  rm -f "$PREFIX/lib/bun-android-shim.so"
  rm -rf "$BUN_DATA_DIR/download"
  _install_bun_native
}

_update_bun_proot_impl() {
  local version
  version="$(_get_bun_remote_version_silent)"
  if [ -z "$version" ]; then
    log_error "Failed to fetch latest Bun version"
    return 1
  fi

  local download_url="https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip"

  _bun_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/bun' &>>"$LOG_FILE"

  _bun_proot_ubuntu /bin/bash -c "
    export HOME=/root TMPDIR=/tmp
    cd /tmp &&
    curl -fsSL '$download_url' -o bun.zip &&
    unzip -o bun.zip >/dev/null 2>&1 &&
    mkdir -p /usr/local/bin &&
    mv bun-linux-aarch64/bun /usr/local/bin/bun &&
    chmod +x /usr/local/bin/bun &&
    rm -rf bun.zip bun-linux-aarch64
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_bun_detect_ubuntu_root)"

  if [ ! -f "$ubuntu_root/usr/local/bin/bun" ]; then
    log_error "Bun binary not found after update"
    return 1
  fi

  log_success "Bun (proot-distro) updated"
  return 0
}

_update_bun_impl() {
  if _bun_is_native; then
    _update_bun_native_impl
    return $?
  fi

  if _bun_is_proot; then
    loading "Updating Bun (proot-distro)" _update_bun_proot_impl
    return $?
  fi

  log_warn "Could not detect Bun installation method"
  return 1
}

update_bun() {
  local installed_ver
  installed_ver="$(_get_installed_version bun)"
  local remote_ver
  remote_ver="$(_get_bun_remote_version)"

  _check_update_needed "Bun" "$installed_ver" "$remote_ver" _update_bun_impl
}

# ===== REINSTALL =====

reinstall_bun() {
  uninstall_bun
  install_bun
}

# ===== AUTO-INSTALL FOR TOOL DEPENDENCIES (non-interactive) =====
# Used by tool installers that depend on bun as a runtime.
# Installs bun natively without any interactive prompt.


# Also export as a public alias used by CLI tools
install_bun_native_auto() {
  _ensure_bun
}

# ===== PKG FALLBACK — bun → npm =====
# Used by tool installers that depend on bun as a runtime.
# Tries bun first; if bun fails (e.g. "bad system call" on Android),
# falls back to npm automatically.

_ensure_npm() {
  if command -v npm &>/dev/null; then
    return 0
  fi
  log_info "Installing Node.js/npm for fallback package installation..."
  if ! yes | pkg install nodejs-lts &>>"$LOG_FILE"; then
    log_error "Failed to install Node.js/npm"
    return 1
  fi
  return 0
}

# Install a package globally: try bun, fall back to npm on failure.
# Usage: _install_pkg_fallback <package> [extra_flags]
#   extra_flags are passed to BOTH bun and npm (e.g. --ignore-scripts)
_install_pkg_fallback() {
  local pkg="$1"
  local extra_flags="${2:-}"

  # Try bun first (fast path)
  if bun install -g $extra_flags "$pkg" &>>"$LOG_FILE"; then
    return 0
  fi

  log_warn "bun install failed for '${pkg}', falling back to npm..."
  _ensure_npm || return 1

  if npm install -g $extra_flags "$pkg" &>>"$LOG_FILE"; then
    log_info "Installed '${pkg}' via npm (fallback)"
    return 0
  fi

  log_error "Failed to install '${pkg}' via both bun and npm"
  return 1
}

# Uninstall a package globally: try bun, then npm (don't fail).
# Usage: _uninstall_pkg_fallback <package>
_uninstall_pkg_fallback() {
  local pkg="$1"

  # Try bun first
  bun uninstall -g "$pkg" &>>"$LOG_FILE" 2>/dev/null

  # Also try npm (may have been installed via fallback)
  if command -v npm &>/dev/null; then
    npm uninstall -g "$pkg" &>>"$LOG_FILE" 2>/dev/null
  fi

  # Never fail uninstall — package may already be gone
  return 0
}

# Install in a local directory: try bun, fall back to npm.
# Uses bun init / npm init to create a package.json, then installs.
# Usage: _install_pkg_fallback_local <directory> <package>
_install_pkg_fallback_local() {
  local dir="$1"
  local pkg="$2"

  mkdir -p "$dir"

  # Try bun first
  if (cd "$dir" && bun init -y &>>"$LOG_FILE" && bun install "$pkg" &>>"$LOG_FILE"); then
    return 0
  fi

  log_warn "bun install failed for '${pkg}', falling back to npm..."
  _ensure_npm || return 1

  if (cd "$dir" && npm init -y &>>"$LOG_FILE" && npm install "$pkg" &>>"$LOG_FILE"); then
    log_info "Installed '${pkg}' locally via npm (fallback)"
    return 0
  fi

  log_error "Failed to install '${pkg}' locally via both bun and npm"
  return 1
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_bun_native_auto; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_bun; fi
if [[ "${1:-}" == "update" ]]; then update_bun; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_bun; fi
