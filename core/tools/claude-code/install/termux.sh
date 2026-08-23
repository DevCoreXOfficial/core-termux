#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"
CLAUDE_DATA_DIR="$HOME/.local/share/core-termux-data/claude"

_claude_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_claude_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_claude_version() {
  curl -fsSL https://api.github.com/repos/anthropics/claude-code/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_claude_install_deps_native() {
  loading "Installing glibc and dependencies" _claude_install_deps_native_impl
}

_claude_install_deps_native_impl() {
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
    ["clang"]="clang"
    ["curl"]="curl"
    ["tar"]="tar"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if [[ -n "$bin_name" ]] && command -v "$bin_name" &>/dev/null; then
      continue
    fi
    if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
      log_error "Failed to install $pkg_name"
      return 1
    fi
  done

  return 0
}

_download_claude_binary() {
  loading "Downloading Claude Code" _download_claude_binary_impl
}

_download_claude_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_claude_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Claude Code version"
    return 1
  fi

  mkdir -p "$CLAUDE_DATA_DIR"

  local tarball="claude-linux-arm64.tar.gz"
  local download_url="https://github.com/anthropics/claude-code/releases/download/$latest_version/$tarball"

  if ! curl -fsSL "$download_url" -o "$CLAUDE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Claude Code binary"
    return 1
  fi

  if ! tar -zxf "$CLAUDE_DATA_DIR/$tarball" -C "$CLAUDE_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Claude Code binary"
    return 1
  fi

  rm -f "$CLAUDE_DATA_DIR/$tarball"

  if [ ! -f "$CLAUDE_DATA_DIR/claude" ]; then
    log_error "Claude Code binary not found after extraction"
    return 1
  fi

  chmod +x "$CLAUDE_DATA_DIR/claude"
  return 0
}

_compile_claude_helper() {
  loading "Compiling helper" _compile_claude_helper_impl
}

_compile_claude_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/claude-code/helper/claude_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/claude" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile claude helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/claude"
  return 0
}

_install_claude_native() {
  _claude_install_deps_native || return 1
  _download_claude_binary || return 1
  _compile_claude_helper || return 1
  log_success "Claude Code installed natively"
  return 0
}

_install_claude_proot_glibc() {
  _claude_install_deps_native || return 1
  loading "Installing proot" _claude_install_proot_pkg || return 1
  _download_claude_binary || return 1
  loading "Creating proot wrapper" _claude_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$CLAUDE_DATA_DIR/.install-method"
  log_success "Claude Code installed with glibc + proot"
  return 0
}

_claude_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_claude_create_proot_wrapper() {
  local wrapper_src="$CORE_PATH/tools/ai/claude-code/bin/claude.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$CLAUDE_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/claude"
  chmod +x "$PREFIX/bin/claude"
  return 0
}

_install_claude_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _claude_install_proot_distro || return 1
  loading "Installing Ubuntu container" _claude_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _claude_ubuntu_deps || return 1
  loading "Downloading Claude Code (Ubuntu)" _claude_ubuntu_install_bin || return 1
  loading "Creating wrapper" _claude_create_ubuntu_wrapper || return 1

  log_success "Claude Code installed (proot-distro)"
  return 0
}

_claude_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_claude_install_ubuntu() {
  if [ ! -d "$(_claude_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_claude_ubuntu_deps() {
  _claude_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"
}

_claude_ubuntu_install_bin() {
  _claude_proot_ubuntu /bin/bash -c '
		export SHELL=/bin/bash
		export TMPDIR=/tmp
		export HOME=/root
		curl -fsSL https://claude.ai/install.sh | bash
	' &>>"$LOG_FILE"

  if ! _claude_proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
    log_error "Claude Code binary not found after install"
    return 1
  fi
  return 0
}

_claude_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_claude_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/claude-code/bin/claude"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/claude"
  chmod +x "$PREFIX/bin/claude"

  if ! grep -q '.local/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# claude-code\nexport PATH=/root/.local/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi
  return 0
}

install_claude_code() {
  if command -v claude &>/dev/null; then
    log_info "Claude Code is already installed"
    return 2
  fi

  log_info "Select installation method for Claude Code:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_claude_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_claude_native
    ;;
  *proot-distro*)
    _install_claude_proot
    ;;
  esac
}

uninstall_claude_code() {
  _walkie_remove_wrapper claude
  log_info "Uninstalling Claude Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/claude" ]; then
    log_warn "Claude Code is not installed"
    return 1
  fi

  confirm_remove_configs "Claude Code" \
    "$HOME/.claude" \
    "$HOME/.claude.json" \
    "$HOME/.config/claude" \
    "$HOME/.local/share/claude" \
    "$HOME/.local/state/claude" \
    "$HOME/.cache/claude"

  if [ -f "$CLAUDE_DATA_DIR/claude" ]; then
    local method="native"
    if [ -f "$CLAUDE_DATA_DIR/.install-method" ]; then
      method="$(cat "$CLAUDE_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/claude"
    rm -rf "$CLAUDE_DATA_DIR"
    log_success "Claude Code ($method) uninstalled"
    return 0
  fi

  _claude_proot_ubuntu /bin/bash -c \
    'rm -f /root/.local/bin/claude && rm -rf /root/.claude && rm -rf /root/.local/share/claude' \
    &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_claude_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# claude-code/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/claude" &>>"$LOG_FILE"; then
    log_success "Claude Code (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Claude Code"
    return 1
  fi
}

_update_claude_code() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$CLAUDE_DATA_DIR/claude" ]; then
    local method="native"
    if [ -f "$CLAUDE_DATA_DIR/.install-method" ]; then
      method="$(cat "$CLAUDE_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_claude_proot_glibc
    else
      _install_claude_native
    fi
    return $?
  fi

  _claude_proot_ubuntu /bin/bash -c '
    export HOME=/root
    curl -fsSL https://claude.ai/install.sh | bash
  ' &>>"$LOG_FILE"

  if ! _claude_proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
    log_error "Claude Code binary not found after update"
    return 1
  fi

  log_success "Claude Code (proot-distro) updated"
  return 0
}

update_claude_code() {
  _check_update_needed "Claude Code" "$(_get_installed_version claude)" "$(_get_remote_github_version anthropics/claude-code)" _update_claude_code
}

reinstall_claude_code() {
  uninstall_claude_code
  install_claude_code
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_claude_code; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_claude_code; fi
if [[ "${1:-}" == "update" ]]; then update_claude_code; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_claude_code; fi
