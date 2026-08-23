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

CACTUS_CLI_LOG_FILE="$CORE_CACHE/install_ai.log"
CACTUS_CLI_DATA_DIR="$HOME/.local/share/core-termux-data/cactus-cli"
CACTUS_CLI_GLIBC_PYTHON="$PREFIX/glibc/bin/python"

_cactus_cli_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_cactus_cli_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_cactus_cli_glibc_run() {
  glibc-runner -s "$CACTUS_CLI_GLIBC_PYTHON" "$@"
}

_cactus_cli_install_deps_native() {
  loading "Installing glibc and Python dependencies" _cactus_cli_install_deps_native_impl
}

_cactus_cli_install_deps_native_impl() {
  if [[ ! -f $PREFIX/etc/apt/sources.list.d/glibc.list ]]; then
    if ! yes | pkg install glibc-repo &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install glibc-repo"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/lib/libc.so.6 ]]; then
    if ! yes | pkg install glibc &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install glibc"
      return 1
    fi
  fi

  if [[ ! -f $CACTUS_CLI_GLIBC_PYTHON ]]; then
    if ! yes | pkg install python-glibc &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install python-glibc"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/bin/pip ]]; then
    if ! yes | pkg install python-pip-glibc &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install python-pip-glibc"
      return 1
    fi
  fi

  return 0
}

_cactus_cli_install_pip_glibc() {
  log_info "This downloads the Cactus Engine wheel (~24 MB) plus core deps (numpy, huggingface-hub, fastapi) into the glibc Python environment"
  loading "Installing Cactus-compute (pip)" _cactus_cli_install_pip_glibc_impl "$@"
}

_cactus_cli_install_pip_glibc_impl() {
  # NOTE: never run "pip install --upgrade pip" inside the termux glibc
  # environment: python-pip-glibc ships a pip.conf that forbids it to
  # protect its bundled pip ("Installing pip is forbidden" error).
  local install_args=""
  if [ "${1:-install}" = "update" ]; then
    install_args="--upgrade"
  fi

  if ! _cactus_cli_glibc_run -m pip install $install_args cactus-compute &>>"$CACTUS_CLI_LOG_FILE"; then
    log_error "Failed to install Cactus Engine CLI"
    return 1
  fi

  _cactus_cli_post_install_glibc || return 1

  return 0
}

# Post-install fixes for the glibc native runtime. They must run after every
# pip install/upgrade because the wheel replaces site-packages:
#   1. Copy our launcher (bundle-validation patch) into $PREFIX/libexec.
#   2. repoint the engine binaries' ELF interpreter at the Termux glibc
#      loader (wheels ship /lib/ld-linux-aarch64.so.1, which does not exist
#      in Termux) via patchelf, and make them executable.
_cactus_cli_post_install_glibc() {
  local launcher_src="$CORE_TOOL_DIR/bin/cactus.launcher.py"
  local launcher_dst="$PREFIX/libexec/cactus.launcher.py"
  local bin_dir cactus_bin engine_lib loader

  if [ ! -f "$launcher_src" ]; then
    log_error "Launcher template not found at $launcher_src"
    return 1
  fi
  mkdir -p "$PREFIX/libexec"
  cp "$launcher_src" "$launcher_dst"
  chmod 644 "$launcher_dst"

  if ! command -v patchelf &>/dev/null; then
    if ! yes | pkg install patchelf &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install patchelf (needed to fix cactus engine binaries)"
      return 1
    fi
  fi

  cactus_bin="$PREFIX/glibc/bin/cactus"
  # Resolve the wheel's engine binary dir from the installed module itself,
  # not from the console-script shebang (which points at the python dir).
  bin_dir="$({ printf 'import cactus, os; print(os.path.join(os.path.dirname(cactus.__file__), "bin"))\n' | "$CACTUS_CLI_GLIBC_PYTHON" - 2>/dev/null; } | tail -1)"
  if [ -z "$bin_dir" ] || [ ! -d "$bin_dir" ]; then
    # Fall back to the standard wheel layout next to the python entrypoint.
    bin_dir="$PREFIX/glibc/lib/python3.12/site-packages/cactus/bin"
  fi
  loader="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
  engine_lib="$PREFIX/glibc/lib"

  for engine in run transcribe; do
    if [ ! -f "$bin_dir/$engine" ]; then
      log_warn "Engine binary not found: $bin_dir/$engine"
      continue
    fi
    chmod 755 "$bin_dir/$engine" 2>/dev/null || true
    # Idempotent: only repoint when the interpreter is still the wheel's.
    if readelf -l "$bin_dir/$engine" 2>/dev/null | grep -q "interpreter: /lib/ld-linux"; then
      if ! patchelf --set-interpreter "$loader" --set-rpath "\$ORIGIN/../../cactus_compute.libs:$engine_lib" "$bin_dir/$engine" &>>"$CACTUS_CLI_LOG_FILE"; then
        log_error "patchelf failed on $bin_dir/$engine"
        return 1
      fi
    fi
  done

  return 0
}

_cactus_cli_verify_glibc() {
  loading "Verifying Cactus Engine CLI" _cactus_cli_verify_impl
}

_cactus_cli_verify_impl() {
  # NOTE: glibc-runner -s re-splits its args, so "-c" code strings with
  # spaces break; feed the check through stdin instead ("python -").
  # timeout cannot exec a bash function, so call the real binary here.
  if ! { printf 'import cactus\n' | timeout 300 glibc-runner -s "$CACTUS_CLI_GLIBC_PYTHON" -; } &>>"$CACTUS_CLI_LOG_FILE"; then
    log_error "Cactus Engine CLI installed but the native engine failed to load — your Android kernel or glibc setup cannot run it; use method 2 or 3"
    rm -f "$PREFIX/bin/cactus"
    _cactus_cli_glibc_run -m pip uninstall -y cactus-compute &>>"$CACTUS_CLI_LOG_FILE"
    return 1
  fi
  return 0
}

_cactus_cli_create_glibc_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/cactus.glibc"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  cp "$wrapper_src" "$PREFIX/bin/cactus"
  chmod +x "$PREFIX/bin/cactus"
  return 0
}

_cactus_cli_install_native() {
  _cactus_cli_install_deps_native || return 1
  _cactus_cli_install_pip_glibc || return 1
  _cactus_cli_verify_glibc || return 1
  loading "Creating wrapper" _cactus_cli_create_glibc_wrapper || return 1

  mkdir -p "$CACTUS_CLI_DATA_DIR"
  printf 'native' >"$CACTUS_CLI_DATA_DIR/.install-method"
  log_success "Cactus Engine CLI installed natively"
  return 0
}

_cactus_cli_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_cactus_cli_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/cactus.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  cp "$wrapper_src" "$PREFIX/bin/cactus"
  chmod +x "$PREFIX/bin/cactus"
  return 0
}

_cactus_cli_install_proot_glibc() {
  _cactus_cli_install_deps_native || return 1
  loading "Installing proot" _cactus_cli_install_proot_pkg || return 1
  _cactus_cli_install_pip_glibc || return 1
  _cactus_cli_verify_glibc || return 1
  loading "Creating proot wrapper" _cactus_cli_create_proot_wrapper || return 1

  mkdir -p "$CACTUS_CLI_DATA_DIR"
  printf 'proot-glibc' >"$CACTUS_CLI_DATA_DIR/.install-method"
  log_success "Cactus Engine CLI installed with glibc + proot"
  return 0
}

_cactus_cli_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_cactus_cli_install_ubuntu() {
  if [ ! -d "$(_cactus_cli_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_cactus_cli_ubuntu_deps() {
  _cactus_cli_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y python3 python3-pip' \
    &>>"$CACTUS_CLI_LOG_FILE"
}

_cactus_cli_ubuntu_install_pip() {
  # No "pip install --upgrade pip" here: Ubuntu's distro pip is apt-managed.
  _cactus_cli_proot_ubuntu /bin/bash -c \
    'python3 -m pip install --break-system-packages cactus-compute' \
    &>>"$CACTUS_CLI_LOG_FILE"

  local cactus_bin="$(_cactus_cli_detect_ubuntu_root)/usr/local/bin/cactus"
  if [ ! -f "$cactus_bin" ]; then
    log_error "Cactus Engine CLI binary not found after install"
    return 1
  fi
  return 0
}

_cactus_cli_ubuntu_verify() {
  loading "Verifying Cactus Engine CLI" _cactus_cli_ubuntu_verify_impl
}

_cactus_cli_ubuntu_verify_impl() {
  # timeout cannot exec a bash function, so call proot-distro directly
  if ! timeout 300 proot-distro login --shared-tmp ubuntu -- python3 -c "import cactus" &>>"$CACTUS_CLI_LOG_FILE"; then
    log_error "Cactus Engine CLI installed but the native engine failed to load in the Ubuntu container"
    _cactus_cli_proot_ubuntu python3 -m pip uninstall -y cactus-compute &>>"$CACTUS_CLI_LOG_FILE"
    return 1
  fi
  return 0
}

_cactus_cli_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_cactus_cli_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/cactus"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/cactus"
  chmod +x "$PREFIX/bin/cactus"
  return 0
}

_install_cactus_cli_proot() {
  mkdir -p "$(dirname "$CACTUS_CLI_LOG_FILE")"

  loading "Installing proot-distro" _cactus_cli_install_proot_distro || return 1
  loading "Installing Ubuntu container" _cactus_cli_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _cactus_cli_ubuntu_deps || return 1
  loading "Installing Cactus-compute (Ubuntu)" _cactus_cli_ubuntu_install_pip || return 1
  loading "Verifying Cactus Engine CLI" _cactus_cli_ubuntu_verify_impl || return 1
  loading "Creating wrapper" _cactus_cli_create_ubuntu_wrapper || return 1

  mkdir -p "$CACTUS_CLI_DATA_DIR"
  printf 'proot' >"$CACTUS_CLI_DATA_DIR/.install-method"
  log_success "Cactus Engine CLI installed (proot-distro)"
  return 0
}

install_cactus_cli() {
  if command -v cactus &>/dev/null; then
    log_info "Cactus Engine CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Cactus Engine CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _cactus_cli_install_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _cactus_cli_install_native
    ;;
  *proot-distro*)
    _install_cactus_cli_proot
    ;;
  esac
}

uninstall_cactus_cli() {
  mkdir -p "$(dirname "$CACTUS_CLI_LOG_FILE")"

  if [ ! -f "$PREFIX/bin/cactus" ]; then
    log_warn "Cactus Engine CLI is not installed"
    return 1
  fi

  confirm_remove_configs "Cactus Engine CLI" \
    "$HOME/.cache/cactus" \
    "$HOME/.cache/cactus-cli" \
    "$HOME/.config/cactus" \
    "$HOME/.local/share/cactus" \
    "$HOME/.cactus" \
    "$HOME/Library" \
    "$HOME/.cache/huggingface/hub"/models--Cactus-Compute--* \
    "${TMPDIR:-$PREFIX/tmp}/cactus-cq-cache"

  loading "Uninstalling Cactus Engine CLI" _uninstall_cactus_cli_impl
}

_uninstall_cactus_cli_impl() {
  local method="native"
  if [ -f "$CACTUS_CLI_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_CLI_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    _cactus_cli_proot_ubuntu python3 -m pip uninstall -y cactus-compute &>>"$CACTUS_CLI_LOG_FILE"
    rm -f "$PREFIX/bin/cactus"
    rm -rf "$CACTUS_CLI_DATA_DIR"
    log_success "Cactus Engine CLI (proot-distro) uninstalled"
    return 0
  fi

  _cactus_cli_glibc_run -m pip uninstall -y cactus-compute &>>"$CACTUS_CLI_LOG_FILE"
  rm -f "$PREFIX/bin/cactus"
  rm -rf "$CACTUS_CLI_DATA_DIR"
  log_success "Cactus Engine CLI ($method) uninstalled"
  return 0
}

_cactus_cli_installed_version() {
  local method="native"
  if [ -f "$CACTUS_CLI_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_CLI_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    _spin_capture "Detecting version" bash -c 'proot-distro login --shared-tmp ubuntu -- python3 -c "from importlib.metadata import version; print(version(\"cactus-compute\"))" 2>/dev/null'
  else
    # glibc-runner -s re-splits args, so pass the check through stdin
    _spin_capture "Detecting version" bash -c 'printf "%s\n" "from importlib.metadata import version; print(version(\"cactus-compute\"))" | glibc-runner -s "$PREFIX/glibc/bin/python" - 2>/dev/null'
  fi
}

update_cactus_cli() {
  _check_update_needed "Cactus Engine CLI" "$(_parse_version "$(_cactus_cli_installed_version)")" "$(_get_remote_pip_version cactus-compute)" _update_cactus_cli
}

_update_cactus_cli() {
  loading "Updating Cactus Engine CLI" _update_cactus_cli_impl
}

_update_cactus_cli_impl() {
  local method="native"
  if [ -f "$CACTUS_CLI_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_CLI_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    if ! _cactus_cli_proot_ubuntu /bin/bash -c 'python3 -m pip install --break-system-packages --upgrade cactus-compute' &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Failed to update Cactus Engine CLI"
      return 1
    fi
    if ! timeout 300 proot-distro login --shared-tmp ubuntu -- python3 -c "import cactus" &>>"$CACTUS_CLI_LOG_FILE"; then
      log_error "Cactus Engine CLI updated but the native engine failed to load"
      return 1
    fi
    log_success "Cactus Engine CLI (proot-distro) updated"
    return 0
  fi

  _cactus_cli_install_pip_glibc update || return 1
  _cactus_cli_verify_glibc || return 1
  log_success "Cactus Engine CLI ($method) updated"
  return 0
}

reinstall_cactus_cli() {
  uninstall_cactus_cli
  install_cactus_cli
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_cactus_cli; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_cactus_cli; fi
if [[ "${1:-}" == "update" ]]; then update_cactus_cli; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_cactus_cli; fi
