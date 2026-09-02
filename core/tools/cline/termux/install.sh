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
    ["patchelf"]="patchelf"
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

  # The interactive terminal command broker re-executes this binary directly
  # (process.execPath + --terminal-command-broker), WITHOUT the C loader helper.
  # The ELF requests the interpreter /lib/ld-linux-aarch64.so.1 which does not
  # exist in Termux, so the broker child dies before writing its protocol
  # response ("protocol response was missing"). Rewrite the ELF interpreter to
  # the real glibc loader so the direct re-exec works. Do NOT use --set-rpath:
  # it corrupts the Bun-packed binary (SIGSEGV).
  if ! patchelf --set-interpreter "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" \
    "$CLINE_DATA_DIR/cline" &>>"$LOG_FILE"; then
    log_error "Failed to patch cline ELF interpreter"
    return 1
  fi

  return 0
}

_install_cline_proot_glibc() {
  _cline_install_deps_native || return 1
  loading "Installing proot" _cline_install_proot_pkg || return 1
  _download_cline_binary || return 1
  loading "Creating proot wrapper" _cline_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$CLINE_DATA_DIR/.install-method"
  log_success "Cline CLI installed with glibc + proot"
  return 0
}

_cline_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_cline_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/cline.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$CLINE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/cline"
  chmod +x "$PREFIX/bin/cline"
  return 0
}

_install_cline_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _cline_install_proot_distro || return 1
  loading "Installing Ubuntu container" _cline_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _cline_ubuntu_deps || return 1
  loading "Downloading Cline CLI (Ubuntu)" _cline_ubuntu_install_bin || return 1
  loading "Creating wrapper" _cline_create_ubuntu_wrapper || return 1

  log_success "Cline CLI installed (proot-distro)"
  return 0
}

_cline_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_cline_install_ubuntu() {
  if [ ! -d "$(_cline_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_cline_ubuntu_deps() {
  _cline_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_cline_ubuntu_install_bin() {
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

  local cline_bin="$(_cline_detect_ubuntu_root)/root/.cline/bin/cline"
  if [ ! -f "$cline_bin" ]; then
    log_error "Cline CLI binary not found after install"
    return 1
  fi
  return 0
}

_cline_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_cline_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/cline"
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

  separator
  box_large "Installing Cline"
  separator
  echo

  log_info "Select installation method for Cline CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc + proot (recommended)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_cline_proot_glibc
    ;;
  *proot-distro*)
    _install_cline_proot
    ;;
  esac
}

uninstall_cline() {
  _walkie_remove_wrapper cline
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/cline" ]; then
    log_warn "Cline CLI is not installed"
    return 1
  fi

  separator
  box_large "Uninstalling Cline"
  separator
  echo

  confirm_remove_configs "Cline" \
    "$HOME/.cline"

  loading "Uninstalling Cline CLI" _uninstall_cline_impl
}

_uninstall_cline_impl() {
  if [ -f "$CLINE_DATA_DIR/cline" ]; then
    local method="native"
    if [ -f "$CLINE_DATA_DIR/.install-method" ]; then
      method="$(cat "$CLINE_DATA_DIR/.install-method")"
      rm -f "$CLINE_DATA_DIR/.install-method"
    fi
    rm -f "$PREFIX/bin/cline"
    rm -f "$CLINE_DATA_DIR/cline"
    log_success "Cline CLI ($method) uninstalled"
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
    # Only proot-glibc and proot-distro remain; there is no native mode.
    _install_cline_proot_glibc
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

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_cline; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_cline; fi
if [[ "${1:-}" == "update" ]]; then update_cline; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_cline; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version cline; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_remote_npm_version @cline/cline; fi
