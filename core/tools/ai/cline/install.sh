#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"
CLINE_DATA_DIR="$HOME/.local/share/core-termux-data/cline"

_cline_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_cline_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_cline_version() {
  local raw
  raw=$(_spin_capture "Checking npm" curl -fsSL "https://registry.npmjs.org/@cline%2fcli-linux-arm64/latest" 2>/dev/null)
  echo "$raw" | python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null
}

_get_latest_cline_version_silent() {
  local raw
  raw=$(curl -fsSL "https://registry.npmjs.org/@cline%2fcli-linux-arm64/latest" 2>/dev/null)
  echo "$raw" | python3 -c "import json,sys; print(json.load(sys.stdin).get('version',''))" 2>/dev/null
}

_cline_install_deps_native() {
  loading "Installing glibc and dependencies" _cline_install_deps_native_impl
}

_cline_install_deps_native_impl() {
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
    ["jq"]="jq"
    ["python"]="python"
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

_download_cline_binary() {
  loading "Downloading Cline CLI" _download_cline_binary_impl
}

_download_cline_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_cline_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Cline CLI version"
    return 1
  fi

  mkdir -p "$CLINE_DATA_DIR"

  local tarball="cli-linux-arm64-$latest_version.tgz"
  local download_url="https://registry.npmjs.org/@cline%2fcli-linux-arm64/-/cli-linux-arm64-$latest_version.tgz"

  if ! curl -fsSL "$download_url" -o "$CLINE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Cline CLI binary"
    return 1
  fi

  # Extract the binary from the platform package tarball
  if ! tar -zxf "$CLINE_DATA_DIR/$tarball" -C "$CLINE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Cline CLI binary"
    return 1
  fi

  rm -f "$CLINE_DATA_DIR/$tarball"

  # The npm package tarball contains package/ with the binary at package/bin/cline
  if [ -f "$CLINE_DATA_DIR/package/bin/cline" ]; then
    mv "$CLINE_DATA_DIR/package/bin/cline" "$CLINE_DATA_DIR/cline"
    rm -rf "$CLINE_DATA_DIR/package"
  fi

  if [ ! -f "$CLINE_DATA_DIR/cline" ]; then
    log_error "Cline CLI binary not found after extraction"
    return 1
  fi

  chmod +x "$CLINE_DATA_DIR/cline"
  return 0
}

_compile_cline_helper() {
  loading "Compiling helper" _compile_cline_helper_impl
}

_compile_cline_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/cline/helper/cline_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/cline" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile cline helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/cline"
  return 0
}

_install_cline_native() {
  _cline_install_deps_native || return 1
  _download_cline_binary || return 1
  _compile_cline_helper || return 1
  log_success "Cline CLI installed natively"
  return 0
}

_install_cline_proot() {
  loading "Installing Cline CLI (proot-distro)" _install_cline_proot_impl
}

_install_cline_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_cline_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
  fi

  _cline_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"

  _cline_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://registry.npmjs.org/@cline%2fcli-linux-arm64/-/cli-linux-arm64-$(curl -fsSL https://registry.npmjs.org/@cline%2fcli-linux-arm64/latest | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"version\",\"\"))").tgz -o /tmp/cline.tgz
    mkdir -p /root/.cline/bin
    tar -zxf /tmp/cline.tgz -C /tmp
    cp /tmp/package/bin/cline /root/.cline/bin/cline
    chmod +x /root/.cline/bin/cline
    rm -rf /tmp/cline.tgz /tmp/package
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_cline_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local cline_bin="$ubuntu_root/root/.cline/bin/cline"

  if [ ! -f "$cline_bin" ]; then
    log_error "Cline CLI binary not found after install"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/cline/bin/cline"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/cline"
  chmod +x "$PREFIX/bin/cline"

  if ! grep -q '.cline/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# cline\nexport PATH=/root/.cline/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_cline() {
  if command -v cline &>/dev/null; then
    log_info "Cline CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Cline CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _install_cline_native
    ;;
  *Proot-distro*)
    _install_cline_proot
    ;;
  esac
}

uninstall_cline() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/cline" ]; then
    log_warn "Cline CLI is not installed"
    return 1
  fi

  loading "Uninstalling Cline CLI" _uninstall_cline_impl
}

_uninstall_cline_impl() {
  if [ -f "$CLINE_DATA_DIR/cline" ]; then
    rm -f "$PREFIX/bin/cline"
    rm -f "$CLINE_DATA_DIR/cline"
    log_success "Cline CLI (native) uninstalled"
    return 0
  fi

  _cline_proot_ubuntu /bin/bash -c 'rm -rf /root/.cline' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_cline_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# cline/d; /export PATH=\/root\/.cline\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/cline" &>>"$LOG_FILE"; then
    log_success "Cline CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Cline CLI"
    return 1
  fi
}

_update_cline() {
  _update_cline_impl
}

_update_cline_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$CLINE_DATA_DIR/cline" ]; then
    _install_cline_native
    return $?
  fi

  loading "Updating Cline CLI (proot-distro)" _update_cline_proot_impl
}

update_cline() {
  _check_update_needed "Cline CLI" "$(_get_installed_version cline)" "$(_get_latest_cline_version)" _update_cline
}

_update_cline_proot_impl() {
  _cline_proot_ubuntu /bin/bash -c 'rm -rf /root/.cline' &>>"$LOG_FILE"

  _cline_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://registry.npmjs.org/@cline%2fcli-linux-arm64/-/cli-linux-arm64-$(curl -fsSL https://registry.npmjs.org/@cline%2fcli-linux-arm64/latest | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"version\",\"\"))").tgz -o /tmp/cline.tgz
    mkdir -p /root/.cline/bin
    tar -zxf /tmp/cline.tgz -C /tmp
    cp /tmp/package/bin/cline /root/.cline/bin/cline
    chmod +x /root/.cline/bin/cline
    rm -rf /tmp/cline.tgz /tmp/package
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_cline_detect_ubuntu_root)"
  local cline_bin="$ubuntu_root/root/.cline/bin/cline"

  if [ ! -f "$cline_bin" ]; then
    log_error "Cline CLI binary not found after update"
    return 1
  fi

  log_success "Cline CLI (proot-distro) updated"
  return 0
}

reinstall_cline() {
  uninstall_cline
  install_cline
}
