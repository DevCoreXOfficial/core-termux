#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"

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

_get_bun_remote_version_silent() {
  curl -fsSL "https://api.github.com/repos/oven-sh/bun/releases/latest" 2>/dev/null |
    grep '"tag_name":' | sed -E 's/.*"bun-v([^"]+)".*/\1/'
}

# ===== NATIVE INSTALL =====

_install_bun_deps() {
  loading "Installing dependencies" _install_bun_deps_impl
}

_install_bun_deps_impl() {
  local deps=("curl" "unzip" "clang")

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      if ! yes | pkg install "$dep" &>>"$LOG_FILE"; then
        log_error "Failed to install $dep"
        return 1
      fi
    fi
  done
  return 0
}

_download_bun_binary() {
  local version="$1"
  local label="$2"
  loading "Downloading Bun v${version} (${label})" _download_bun_binary_impl "$version" "$label"
}

_download_bun_binary_impl() {
  local version="$1"
  local label="$2"

  local zip_name="bun-linux-aarch64"
  if [ "$label" = "android" ]; then
    zip_name="bun-linux-aarch64-android"
  fi

  local url="https://github.com/oven-sh/bun/releases/download/bun-v${version}/${zip_name}.zip"
  local extract_dir="$BUN_DATA_DIR/download/${zip_name}"

  mkdir -p "$BUN_DATA_DIR/download"

  local zip_file="$BUN_DATA_DIR/download/${zip_name}.zip"
  if [ ! -f "${zip_file}" ]; then
    if ! curl -fSL -o "${zip_file}" "${url}" &>>"$LOG_FILE"; then
      log_error "Failed to download Bun binary"
      return 1
    fi
  fi

  if [ ! -f "${extract_dir}/bun" ]; then
    if ! unzip -o "${zip_file}" -d "$BUN_DATA_DIR/download/" &>>"$LOG_FILE"; then
      log_error "Failed to extract Bun binary"
      return 1
    fi
    chmod +x "${extract_dir}/bun"
  fi

  return 0
}

_compile_bun_shim() {
  loading "Compiling bun-android-shim" _compile_bun_shim_impl
}

_compile_bun_shim_impl() {
  local shim_src="${SRC_DIR}/bun-android-shim.c"
  local shim_out="$PREFIX/lib/bun-android-shim.so"

  if [ ! -f "${shim_src}" ]; then
    log_warn "Shim source not found, skipping"
    return 0
  fi

  local cc
  if command -v aarch64-linux-android-gcc &>/dev/null; then
    cc="aarch64-linux-android-gcc"
  elif command -v clang &>/dev/null; then
    cc="clang"
  else
    log_warn "No C compiler found, skipping shim compilation"
    return 0
  fi

  mkdir -p "$PREFIX/lib"

  if ! ${cc} -shared -fPIC -O2 -Wall \
    -o "${shim_out}" \
    "${shim_src}" \
    -ldl &>>"$LOG_FILE"; then
    log_warn "Shim compilation failed"
    return 0
  fi

  return 0
}

_compile_bun_bundle() {
  loading "Compiling bun-bundle" _compile_bun_bundle_impl
}

_compile_bun_bundle_impl() {
  local bundle_src="${SRC_DIR}/bun-bundle.c"
  local bundle_out="$PREFIX/bin/bun-bundle"

  if [ ! -f "${bundle_src}" ]; then
    log_warn "bun-bundle source not found, skipping"
    return 0
  fi

  local cc
  if command -v aarch64-linux-android-gcc &>/dev/null; then
    cc="aarch64-linux-android-gcc"
  elif command -v clang &>/dev/null; then
    cc="clang"
  else
    log_warn "No C compiler found, skipping bun-bundle compilation"
    return 0
  fi

  if ! ${cc} -O2 -Wall \
    -o "${bundle_out}" \
    "${bundle_src}" &>>"$LOG_FILE"; then
    log_warn "bun-bundle compilation failed"
    return 0
  fi

  chmod +x "${bundle_out}"
  return 0
}

_install_bun_binary() {
  loading "Installing bun binary" _install_bun_binary_impl
}

_install_bun_binary_impl() {
  local bin_dir="$PREFIX/bin"
  local lib_dir="$PREFIX/lib"
  local bun_binary="$BUN_DATA_DIR/download/bun-linux-aarch64-android/bun"

  mkdir -p "$bin_dir" "$lib_dir"

  cp "${bun_binary}" "${bin_dir}/bun.real"
  chmod 755 "${bin_dir}/bun.real"

  local wrapper_src="${SRC_DIR}/bun_wrapper.c"
  local shim_path="${lib_dir}/bun-android-shim.so"

  if [ -f "${wrapper_src}" ]; then
    local wrapper_tmp="${wrapper_src}.subst.c"

    sed -e "s|__BUN_REAL__|${bin_dir}/bun.real|g" \
      -e "s|__BUN_SHIM__|${shim_path}|g" \
      "${wrapper_src}" > "${wrapper_tmp}"

    local cc
    if command -v aarch64-linux-android-gcc &>/dev/null; then
      cc="aarch64-linux-android-gcc"
    elif command -v clang &>/dev/null; then
      cc="clang"
    else
      cc="gcc"
    fi

    if ${cc} -O2 -Wall \
      -o "${bin_dir}/bun" \
      "${wrapper_tmp}" &>>"$LOG_FILE"; then
      rm -f "${wrapper_tmp}"
    else
      rm -f "${wrapper_tmp}"
      ln -sf "${bin_dir}/bun.real" "${bin_dir}/bun"
    fi
  else
    ln -sf "${bin_dir}/bun.real" "${bin_dir}/bun"
  fi

  ln -sf "${bin_dir}/bun" "${bin_dir}/bunx"
  return 0
}

_install_bun_native() {
  local version
  version="$(_get_bun_remote_version_silent)"
  if [ -z "$version" ]; then
    log_error "Failed to fetch latest Bun version"
    return 1
  fi

  _install_bun_deps || return 1
  _download_bun_binary "$version" "android" || return 1
  _compile_bun_shim || return 1
  _compile_bun_bundle || return 1
  _install_bun_binary || return 1
  log_success "Bun (native) installed"
  return 0
}

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

  local wrapper_src="$CORE_PATH/tools/lang/bun/bin/bun"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/bun"
  chmod +x "$PREFIX/bin/bun"

  local wrapper_bunx_src="$CORE_PATH/tools/lang/bun/bin/bunx"
  if [ -f "$wrapper_bunx_src" ]; then
    sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_bunx_src" >"$PREFIX/bin/bunx"
    chmod +x "$PREFIX/bin/bunx"
  else
    ln -sf "$PREFIX/bin/bun" "$PREFIX/bin/bunx"
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
    _install_bun_native
    ;;
  *Proot-distro*)
    _install_bun_proot
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
