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
FREEBUFF_DATA_DIR="$HOME/.local/share/core-termux-data/freebuff"

_freebuff_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_freebuff_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_freebuff_version() {
  curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"freebuff-v([^"]+)".*/\1/'
}

_freebuff_install_deps_native() {
  loading "Installing glibc and dependencies" _freebuff_install_deps_native_impl
}

_freebuff_install_deps_native_impl() {
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
    ["curl"]="curl"
    ["tar"]="tar"
    ["clang"]="clang"
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

_download_freebuff_binary() {
  loading "Downloading Freebuff" _download_freebuff_binary_impl
}

_download_freebuff_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_freebuff_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Freebuff version"
    return 1
  fi

  mkdir -p "$FREEBUFF_DATA_DIR"

  local tarball="freebuff-linux-arm64.tar.gz"
  local download_url="https://codebuff.com/api/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$FREEBUFF_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Freebuff binary"
    return 1
  fi

  if ! tar -zxf "$FREEBUFF_DATA_DIR/$tarball" -C "$FREEBUFF_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Freebuff binary"
    return 1
  fi

  rm -f "$FREEBUFF_DATA_DIR/$tarball"

  if [ ! -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    log_error "Freebuff binary not found after extraction"
    return 1
  fi

  chmod +x "$FREEBUFF_DATA_DIR/freebuff"

  # The terminal command broker re-executes this binary directly (process.execPath +
  # --terminal-command-broker), WITHOUT the C loader helper. The ELF requests the
  # interpreter /lib/ld-linux-aarch64.so.1 which does not exist in Termux, so the
  # broker child dies before writing its protocol response ("protocol response was
  # missing"). Rewrite the ELF interpreter to the real glibc loader so the direct
  # re-exec works. Do NOT use --set-rpath: it corrupts the Bun-packed binary (SIGSEGV).
  if ! patchelf --set-interpreter "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" \
    "$FREEBUFF_DATA_DIR/freebuff" &>>"$LOG_FILE"; then
    log_error "Failed to patch freebuff ELF interpreter"
    return 1
  fi

  return 0
}

_compile_freebuff_helper() {
  loading "Compiling helper" _compile_freebuff_helper_impl
}

_compile_freebuff_helper_impl() {
  local HELPER_SRC="$CORE_TOOL_DIR/helper/freebuff_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/freebuff" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile freebuff helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/freebuff"
  return 0
}

_install_freebuff_native() {
  _freebuff_install_deps_native || return 1
  _download_freebuff_binary || return 1
  _compile_freebuff_helper || return 1
  log_success "Freebuff installed natively"
  return 0
}

_install_freebuff_proot_glibc() {
  _freebuff_install_deps_native || return 1
  loading "Installing proot" _freebuff_install_proot_pkg || return 1
  _download_freebuff_binary || return 1
  loading "Creating proot wrapper" _freebuff_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$FREEBUFF_DATA_DIR/.install-method"
  log_success "Freebuff installed with glibc + proot"
  return 0
}

_freebuff_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_freebuff_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/freebuff.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$FREEBUFF_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/freebuff"
  chmod +x "$PREFIX/bin/freebuff"
  return 0
}

_install_freebuff_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _freebuff_install_proot_distro || return 1
  loading "Installing Ubuntu container" _freebuff_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _freebuff_ubuntu_deps || return 1
  loading "Downloading Freebuff (Ubuntu)" _freebuff_ubuntu_install_bin || return 1
  loading "Creating wrapper" _freebuff_create_ubuntu_wrapper || return 1

  log_success "Freebuff installed (proot-distro)"
  return 0
}

_freebuff_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_freebuff_install_ubuntu() {
  if [ ! -d "$(_freebuff_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_freebuff_ubuntu_deps() {
  _freebuff_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"
}

_freebuff_ubuntu_install_bin() {
  _freebuff_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    LATEST=$(curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest | grep '"'"'tag_name'"'"' | sed -E '"'"'s/.*"freebuff-v([^"]+)".*/\1/'"'"')
    curl -fsSL "https://codebuff.com/api/releases/download/${LATEST}/freebuff-linux-arm64.tar.gz" -o /tmp/freebuff.tar.gz
    mkdir -p /root/.freebuff
    tar -zxf /tmp/freebuff.tar.gz -C /root/.freebuff
    rm -f /tmp/freebuff.tar.gz
    chmod +x /root/.freebuff/freebuff
  ' &>>"$LOG_FILE"

  local freebuff_bin="$(_freebuff_detect_ubuntu_root)/root/.freebuff/freebuff"
  if [ ! -f "$freebuff_bin" ]; then
    log_error "Freebuff binary not found after install"
    return 1
  fi
  return 0
}

_freebuff_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_freebuff_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/freebuff"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/freebuff"
  chmod +x "$PREFIX/bin/freebuff"

  if ! grep -q '.freebuff' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# freebuff\nexport PATH=/root/.freebuff:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi
  return 0
}

install_freebuff() {
  if command -v freebuff &>/dev/null; then
    log_info "Freebuff is already installed"
    return 2
  fi

  log_info "Select installation method for Freebuff:"

  separator
  box_large "Installing FreeBuff"
  separator
  echo

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_freebuff_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_freebuff_native
    ;;
  *proot-distro*)
    _install_freebuff_proot
    ;;
  esac
}

uninstall_freebuff() {
  _walkie_remove_wrapper freebuff
  log_info "Uninstalling Freebuff..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/freebuff" ]; then
    log_warn "Freebuff is not installed"
    return 1
  fi

  separator
  box_large "Uninstalling FreeBuff"
  separator
  echo

  confirm_remove_configs "FreeBuff" \
    "$HOME/.config/fresh" \
    "$HOME/.config/manicode" \
    "$HOME/.config/ai-agent" \
    "$HOME/.config/aichat" \
    "$HOME/.local/share/fresh" \
    "$HOME/.local/state/fresh"

  if [ -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    local method="native"
    if [ -f "$FREEBUFF_DATA_DIR/.install-method" ]; then
      method="$(cat "$FREEBUFF_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/freebuff"
    rm -rf "$FREEBUFF_DATA_DIR"
    log_success "Freebuff ($method) uninstalled"
    return 0
  fi

  _freebuff_proot_ubuntu /bin/bash -c 'rm -rf /root/.freebuff' &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_freebuff_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# freebuff/d; /export PATH=\/root\/.freebuff/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/freebuff" &>>"$LOG_FILE"; then
    log_success "Freebuff (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Freebuff"
    return 1
  fi
}

_update_freebuff() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$FREEBUFF_DATA_DIR/freebuff" ]; then
    local method="native"
    if [ -f "$FREEBUFF_DATA_DIR/.install-method" ]; then
      method="$(cat "$FREEBUFF_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_freebuff_proot_glibc
    else
      _install_freebuff_native
    fi
    return $?
  fi

  _freebuff_proot_ubuntu /bin/bash -c 'rm -rf /root/.freebuff' &>>"$LOG_FILE"

  _freebuff_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    LATEST=$(curl -fsSL https://api.github.com/repos/CodebuffAI/codebuff-community/releases/latest | grep '"'"'tag_name'"'"' | sed -E '"'"'s/.*"freebuff-v([^"]+)".*/\1/'"'"')
    curl -fsSL "https://codebuff.com/api/releases/download/${LATEST}/freebuff-linux-arm64.tar.gz" -o /tmp/freebuff.tar.gz
    mkdir -p /root/.freebuff
    tar -zxf /tmp/freebuff.tar.gz -C /root/.freebuff
    rm -f /tmp/freebuff.tar.gz
    chmod +x /root/.freebuff/freebuff
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_freebuff_detect_ubuntu_root)"
  local freebuff_bin="$ubuntu_root/root/.freebuff/freebuff"

  if [ ! -f "$freebuff_bin" ]; then
    log_error "Freebuff binary not found after update"
    return 1
  fi

  log_success "Freebuff (proot-distro) updated"
  return 0
}

update_freebuff() {
  _check_update_needed "Freebuff" "$(_get_installed_version freebuff)" "$(_get_remote_github_version CodebuffAI/codebuff-community)" _update_freebuff
}

reinstall_freebuff() {
  uninstall_freebuff
  install_freebuff
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_freebuff; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_freebuff; fi
if [[ "${1:-}" == "update" ]]; then update_freebuff; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_freebuff; fi
