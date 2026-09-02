#!/usr/bin/env bash
# Shared Bun helper library. Sourced by tools that need bun at runtime.
# Functions only — sourcing this file never triggers an install.
[[ -n "${__CORE_BUN_LIB:-}" ]] && return 0
__CORE_BUN_LIB=1

_ensure_bun() {
  command -v bun &>/dev/null && return 0

  local _saved_log="${LOG_FILE:-}"
  local _log_dir
  _log_dir="$(dirname "$_saved_log" 2>/dev/null || echo "$CORE_CACHE")"
  local _log="$_log_dir/install_ensure_bun.log"

  LOG_FILE="$_log"
  mkdir -p "$(dirname "$LOG_FILE")" "$CORE_CACHE"

  _install_bun_native || {
    LOG_FILE="$_saved_log"
    return 1
  }
  _bun_setup_path_native

  LOG_FILE="$_saved_log"
  return 0
}

_install_bun_deps() {
  loading "Installing dependencies" _install_bun_deps_impl
}

_compile_bun_shim() {
  loading "Compiling bun-android-shim" _compile_bun_shim_impl
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

_compile_bun_bundle() {
  loading "Compiling bun-bundle" _compile_bun_bundle_impl
}

_install_bun_binary() {
  loading "Installing bun binary" _install_bun_binary_impl
}

_download_bun_binary() {
  local version="$1"
  local label="$2"
  loading "Downloading Bun v${version} (${label})" _download_bun_binary_impl "$version" "$label"
}

_bun_setup_path_native() {
  local rc_file=""
  local path_line='export PATH="/data/data/com.termux/files/home/.cache/.bun/bin:$PATH"'

  # Priority: .zshrc > .bashrc
  # If .zshrc exists, use it (zsh user — priority shell).
  # Otherwise fall back to .bashrc.
  if [ -f "$HOME/.zshrc" ]; then
    rc_file="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    rc_file="$HOME/.bashrc"
  fi

  if [ -z "$rc_file" ]; then
    log_info "No .zshrc or .bashrc found, skipping PATH setup"
    return 0
  fi

  # Idempotent: only add if the exact line is not already present
  if grep -qxF "$path_line" "$rc_file" 2>/dev/null; then
    log_info "bun PATH already in $(basename "$rc_file")"
    return 0
  fi

  # Ensure the file ends with a newline before appending
  local last_char
  last_char="$(tail -c 1 "$rc_file" 2>/dev/null || echo "")"
  if [ -n "$last_char" ] && [ "$last_char" != $'\n' ]; then
    echo "" >>"$rc_file"
  fi

  echo "# Added by core-termux bun installer" >>"$rc_file"
  echo "$path_line" >>"$rc_file"
  log_success "Added bun PATH to $(basename "$rc_file")"
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

_install_bun_binary_impl() {
  local bin_dir="$PREFIX/bin"
  local lib_dir="$PREFIX/lib"
  local bun_binary="$BUN_DATA_DIR/download/bun-linux-aarch64-android/bun"
  local shim_path="${lib_dir}/bun-android-shim.so"

  mkdir -p "$bin_dir" "$lib_dir"

  cp "${bun_binary}" "${bin_dir}/bun.real"
  chmod 755 "${bin_dir}/bun.real"

  # Generate bash wrapper — more reliable than C on Android/bionic.
  # bash's pwd -P is a shell builtin that resolves physical CWD without
  # calling libc's getcwd(), which is exactly what fails on Android.
  cat > "${bin_dir}/bun" <<-'WRAPPER_EOF'
		#!/data/data/com.termux/files/usr/bin/bash
		# bun wrapper for Termux/Android — generated by core-termux installer

		# LD_PRELOAD shim for dir traversal and standalone binary fix
		export LD_PRELOAD="__BUN_SHIM__"

		# Termux-friendly environment
		export SSL_CERT_FILE="/data/data/com.termux/files/usr/etc/tls/cert.pem"
		export TMPDIR="/data/data/com.termux/files/usr/tmp"
		export HOME="/data/data/com.termux/files/home"
		export BUN_INSTALL_CACHE_DIR="/data/data/com.termux/files/home/.bun/cache"
		export XDG_CACHE_HOME="/data/data/com.termux/files/home/.cache"
		export BUN_MANIFEST_CACHE="/data/data/com.termux/files/home/.cache/bun/manifest"
		export npm_config_cache="/data/data/com.termux/files/home/.npm"
		export BUN_INSTALL_BACKEND="copyfile"

		# Resolve CWD to physical absolute path using shell builtin pwd -P.
		# This bypasses libc's getcwd() which can fail on Android/bionic.
		cd "$(pwd -P 2>/dev/null || pwd)" || true
		export PWD="$(pwd -P 2>/dev/null || pwd)"

		# Detect bunx invocation: bun detects argv[0] for "bunx" mode,
		# but the wrapper breaks this detection. Inject "x" when needed.
		_BUN_CMD="x"
		case "$0" in
			*bunx*) _BUN_CMD="x" ;;
			*)      _BUN_CMD=""   ;;
		esac

		if [ -n "$_BUN_CMD" ]; then
			exec __BUN_REAL__ "$_BUN_CMD" "$@"
		else
			exec __BUN_REAL__ "$@"
		fi
		WRAPPER_EOF

  sed -i "s|__BUN_SHIM__|${shim_path}|g" "${bin_dir}/bun"
  sed -i "s|__BUN_REAL__|${bin_dir}/bun.real|g" "${bin_dir}/bun"
  chmod 755 "${bin_dir}/bun"

  ln -sf "${bin_dir}/bun" "${bin_dir}/bunx"
  return 0
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

_get_bun_remote_version_silent() {
  curl -fsSL "https://api.github.com/repos/oven-sh/bun/releases/latest" 2>/dev/null |
    grep '"tag_name":' | sed -E 's/.*"bun-v([^"]+)".*/\1/'
}

# Package install helpers shared across npm-based tools.
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

_uninstall_pkg_fallback() {
  local pkg="$1"

  if bun remove -g "$pkg" &>>"$LOG_FILE"; then
    return 0
  fi

  _ensure_npm || return 1

  if npm uninstall -g "$pkg" &>>"$LOG_FILE"; then
    log_info "Removed '${pkg}' via npm (fallback)"
    return 0
  fi

  log_error "Failed to remove '${pkg}' via both bun and npm"
  return 1
}

