#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/utils/walkie"

LOG_FILE="$CORE_CACHE/install_ai.log"
CURSOR_DATA_DIR="$HOME/.local/share/core-termux-data/cursor"

_cursor_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_cursor_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_get_latest_cursor_version() {
  local raw
  raw=$(_spin_capture "Checking cursor.com" curl -fsS "https://cursor.com/install" 2>/dev/null)
  echo "$raw" | grep -oP 'downloads\.cursor\.com/lab/\K[^/]+'
}

_get_latest_cursor_version_silent() {
  local raw
  raw=$(curl -fsS "https://cursor.com/install" 2>/dev/null)
  echo "$raw" | grep -oP 'downloads\.cursor\.com/lab/\K[^/]+'
}

_cursor_install_deps_native() {
  loading "Installing glibc and dependencies" _cursor_install_deps_native_impl
}

_cursor_install_deps_native_impl() {
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

_download_cursor_binary() {
  loading "Downloading Cursor CLI" _download_cursor_binary_impl
}

_download_cursor_binary_impl() {
  local latest_version
  latest_version=$(_get_latest_cursor_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Cursor CLI version"
    return 1
  fi

  mkdir -p "$CURSOR_DATA_DIR"

  local tarball="agent-cli-package.tar.gz"
  local download_url="https://downloads.cursor.com/lab/$latest_version/linux/arm64/$tarball"

  if ! curl -fsSL "$download_url" -o "$CURSOR_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
    log_error "Failed to download Cursor CLI binary"
    return 1
  fi

  if ! tar -zxf "$CURSOR_DATA_DIR/$tarball" --strip-components=1 -C "$CURSOR_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Cursor CLI binary"
    return 1
  fi

  rm -f "$CURSOR_DATA_DIR/$tarball"

  if [ ! -f "$CURSOR_DATA_DIR/cursor-agent" ]; then
    log_error "Cursor CLI binary not found after extraction"
    return 1
  fi

  chmod +x "$CURSOR_DATA_DIR/cursor-agent"
  return 0
}

_create_cursor_wrapper() {
  loading "Creating launcher wrapper" _create_cursor_wrapper_impl
}

_create_cursor_wrapper_impl() {
  if [ ! -f "$CURSOR_DATA_DIR/node" ]; then
    log_error "Bundled node not found at $CURSOR_DATA_DIR/node"
    return 1
  fi

  cat >"$PREFIX/bin/cursor" <<'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
unset LD_LIBRARY_PATH

export GODEBUG="netdns=cgo"
export SSL_CERT_FILE="/data/data/com.termux/files/usr/etc/tls/cert.pem"
export CURSOR_INVOKED_AS="${0##*/}"

CURSOR_DATA_DIR="$HOME/.local/share/core-termux-data/cursor"

# Enable Node.js compile cache for faster startup (Node.js >= 22.1.0)
if [ -z "${NODE_COMPILE_CACHE:-}" ]; then
  export NODE_COMPILE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-compile-cache"
fi

# OAuth / networking helpers
# Set HOST for Node.js HTTP server binding (helps OAuth callback reach back)
export HOST="${HOST:-127.0.0.1}"
# Pass through BROWSER if user wants to override URL opening
if [ -z "${BROWSER:-}" ] && command -v termux-open-url &>/dev/null; then
  BROWSER="termux-open-url"
fi
export BROWSER

GLIBC_LOADER="/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1"
GLIBC_LIB="/data/data/com.termux/files/usr/glibc/lib"

exec "$GLIBC_LOADER" \
  --library-path "$GLIBC_LIB" \
  "$CURSOR_DATA_DIR/node" \
  "$CURSOR_DATA_DIR/index.js" \
  "$@"
WRAPPER

  chmod +x "$PREFIX/bin/cursor"

  ln -sf "$PREFIX/bin/cursor" "$PREFIX/bin/cursor-agent"

  return 0
}

_install_cursor_native() {
  _cursor_install_deps_native || return 1
  _download_cursor_binary || return 1
  _create_cursor_wrapper || return 1
  log_success "Cursor CLI installed natively"
  return 0
}

_install_cursor_proot_glibc() {
  _cursor_install_deps_native || return 1
  loading "Installing proot" _cursor_install_proot_pkg || return 1
  _download_cursor_binary || return 1
  loading "Creating proot wrapper" _cursor_create_proot_wrapper || return 1

  printf 'proot-glibc' >"$CURSOR_DATA_DIR/.install-method"
  log_success "Cursor CLI installed with glibc + proot"
  return 0
}

_cursor_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_cursor_create_proot_wrapper() {
  local wrapper_src="$CORE_PATH/tools/ai/cursor-cli/bin/cursor.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__DATA_DIR__|$CURSOR_DATA_DIR|g" "$wrapper_src" >"$PREFIX/bin/cursor"
  chmod +x "$PREFIX/bin/cursor"
  ln -sf "$PREFIX/bin/cursor" "$PREFIX/bin/cursor-agent"
  return 0
}

_install_cursor_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _cursor_install_proot_distro || return 1
  loading "Installing Ubuntu container" _cursor_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _cursor_ubuntu_deps || return 1
  loading "Downloading Cursor CLI (Ubuntu)" _cursor_ubuntu_install_bin || return 1
  loading "Creating wrapper" _cursor_create_ubuntu_wrapper || return 1

  log_success "Cursor CLI installed (proot-distro)"
  return 0
}

_cursor_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_cursor_install_ubuntu() {
  if [ ! -d "$(_cursor_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_cursor_ubuntu_deps() {
  _cursor_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates tar' \
    &>>"$LOG_FILE"
}

_cursor_ubuntu_install_bin() {
  local latest_version
  latest_version=$(_get_latest_cursor_version_silent)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Cursor CLI version"
    return 1
  fi

  local download_url="https://downloads.cursor.com/lab/$latest_version/linux/arm64/agent-cli-package.tar.gz"

  _cursor_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/cursor-install /opt/cursor &&
    curl -fsSL '$download_url' -o /tmp/cursor-install/agent.tar.gz &&
    tar -zxf /tmp/cursor-install/agent.tar.gz --strip-components=1 -C /tmp/cursor-install &&
    cp -r /tmp/cursor-install/. /opt/cursor/ &&
    chmod +x /opt/cursor/cursor-agent /opt/cursor/node &&
    ln -sf /opt/cursor/cursor-agent /usr/local/bin/cursor-agent &&
    rm -rf /tmp/cursor-install
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_cursor_detect_ubuntu_root)"

  # Check the real file path, not the symlink (symlink target is inside proot fs)
  local cursor_symlink="$ubuntu_root/usr/local/bin/cursor-agent"
  local cursor_real="$ubuntu_root/opt/cursor/cursor-agent"

  if [ ! -f "$cursor_real" ]; then
    log_error "Cursor CLI binary not found at $cursor_real"
    return 1
  fi

  # Verify symlink exists
  if [ ! -L "$cursor_symlink" ]; then
    log_warn "Symlink not found, creating..."
    ln -sf /opt/cursor/cursor-agent "$cursor_symlink"
  fi
  return 0
}

_cursor_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_cursor_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_PATH/tools/ai/cursor-cli/bin/cursor"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/cursor"
  chmod +x "$PREFIX/bin/cursor"

  ln -sf "$PREFIX/bin/cursor" "$PREFIX/bin/cursor-agent"
  return 0
}

install_cursor_cli() {
  if command -v cursor &>/dev/null || command -v cursor-agent &>/dev/null; then
    log_info "Cursor CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Cursor CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _install_cursor_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _install_cursor_native
    ;;
  *proot-distro*)
    _install_cursor_proot
    ;;
  esac
}

uninstall_cursor_cli() {
  _walkie_remove_wrapper cursor cursor-agent
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/cursor" ] && [ ! -f "$PREFIX/bin/cursor-agent" ]; then
    log_warn "Cursor CLI is not installed"
    return 1
  fi

  confirm_remove_configs "Cursor CLI" \
    "$HOME/.cursor" \
    "$HOME/.local/share/cursor-agent" \
    "$HOME/.cache/cursor-compile-cache"

  loading "Uninstalling Cursor CLI" _uninstall_cursor_cli_impl
}

_uninstall_cursor_cli_impl() {
  if [ -f "$CURSOR_DATA_DIR/cursor-agent" ]; then
    local method="native"
    if [ -f "$CURSOR_DATA_DIR/.install-method" ]; then
      method="$(cat "$CURSOR_DATA_DIR/.install-method")"
    fi
    rm -f "$PREFIX/bin/cursor" "$PREFIX/bin/cursor-agent"
    rm -rf "$CURSOR_DATA_DIR"
    log_success "Cursor CLI ($method) uninstalled"
    return 0
  fi

  _cursor_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/cursor-agent && rm -rf /opt/cursor' &>>"$LOG_FILE"

  if rm -f "$PREFIX/bin/cursor" "$PREFIX/bin/cursor-agent" &>>"$LOG_FILE"; then
    log_success "Cursor CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Cursor CLI"
    return 1
  fi
}

_update_cursor_cli() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$CURSOR_DATA_DIR/cursor-agent" ]; then
    local method="native"
    if [ -f "$CURSOR_DATA_DIR/.install-method" ]; then
      method="$(cat "$CURSOR_DATA_DIR/.install-method")"
    fi
    if [ "$method" = "proot-glibc" ]; then
      _install_cursor_proot_glibc
    else
      _install_cursor_native
    fi
    return $?
  fi

  loading "Updating Cursor CLI (proot-distro)" _update_cursor_proot_impl
}

update_cursor_cli() {
  _check_update_needed "Cursor CLI" "$(_get_installed_version cursor-agent)" "$(_parse_version "$(_get_latest_cursor_version)")" _update_cursor_cli
}

_update_cursor_proot_impl() {
  local latest_version
  latest_version=$(_get_latest_cursor_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Cursor CLI version"
    return 1
  fi

  local download_url="https://downloads.cursor.com/lab/$latest_version/linux/arm64/agent-cli-package.tar.gz"

  _cursor_proot_ubuntu /bin/bash -c "
    mkdir -p /tmp/cursor-install &&
    curl -fsSL '$download_url' -o /tmp/cursor-install/agent.tar.gz &&
    tar -zxf /tmp/cursor-install/agent.tar.gz --strip-components=1 -C /tmp/cursor-install &&
    rm -rf /opt/cursor &&
    mkdir -p /opt/cursor &&
    cp -r /tmp/cursor-install/. /opt/cursor/ &&
    chmod +x /opt/cursor/cursor-agent /opt/cursor/node &&
    rm -rf /tmp/cursor-install
  " &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_cursor_detect_ubuntu_root)"

  # Check the real file path inside the proot rootfs
  local cursor_real="$ubuntu_root/opt/cursor/cursor-agent"

  if [ ! -f "$cursor_real" ]; then
    log_error "Cursor CLI binary not found after update"
    return 1
  fi

  log_success "Cursor CLI (proot-distro) updated"
  return 0
}

reinstall_cursor_cli() {
  uninstall_cursor_cli
  install_cursor_cli
}
