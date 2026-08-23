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

LOG_FILE="$CORE_CACHE/install_ai.log"
CACTUS_DATA_DIR="$HOME/.local/share/core-termux-data/cactus-needle"
CACTUS_GLIBC_PYTHON="$PREFIX/glibc/bin/python"

_cactus_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_cactus_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_cactus_glibc_run() {
  glibc-runner -s "$CACTUS_GLIBC_PYTHON" "$@"
}

_cactus_install_deps_native() {
  loading "Installing glibc and Python dependencies" _cactus_install_deps_native_impl
}

_cactus_install_deps_native_impl() {
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

  if [[ ! -f $CACTUS_GLIBC_PYTHON ]]; then
    if ! yes | pkg install python-glibc &>>"$LOG_FILE"; then
      log_error "Failed to install python-glibc"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/bin/pip ]]; then
    if ! yes | pkg install python-pip-glibc &>>"$LOG_FILE"; then
      log_error "Failed to install python-pip-glibc"
      return 1
    fi
  fi

  return 0
}

_cactus_install_pip_glibc() {
  log_info "This downloads large native dependencies (jaxlib, scipy) into the glibc Python environment"
  loading "Installing Cactus Needle (pip)" _cactus_install_pip_glibc_impl "$@"
}

_cactus_install_pip_glibc_impl() {
  # NOTE: never run "pip install --upgrade pip" inside the termux glibc
  # environment: python-pip-glibc ships a pip.conf that forbids it to
  # protect its bundled pip ("Installing pip is forbidden" error).
  local install_args=""
  if [ "${1:-install}" = "update" ]; then
    install_args="--upgrade"
  fi

  if ! _cactus_glibc_run -m pip install $install_args cactus-needle &>>"$LOG_FILE"; then
    log_error "Failed to install Cactus Needle"
    return 1
  fi

  return 0
}

_cactus_verify_glibc() {
  loading "Verifying Cactus Needle" _cactus_verify_impl
}

_cactus_verify_impl() {
  # NOTE: glibc-runner -s re-splits its args, so "-c" code strings with
  # spaces break; feed the check through stdin instead ("python -").
  # timeout cannot exec a bash function, so call the real binary here.
  if ! { printf 'import jax, needle\n' | timeout 300 glibc-runner -s "$CACTUS_GLIBC_PYTHON" -; } &>>"$LOG_FILE"; then
    log_error "Cactus Needle installed but jax/jaxlib failed to load — your Android kernel or glibc setup cannot run XLA; use method 2 or 3"
    rm -f "$PREFIX/bin/needle"
    _cactus_glibc_run -m pip uninstall -y cactus-needle &>>"$LOG_FILE"
    return 1
  fi
  return 0
}

_cactus_create_glibc_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/needle.glibc"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  cp "$wrapper_src" "$PREFIX/bin/needle"
  chmod +x "$PREFIX/bin/needle"
  return 0
}

_cactus_install_native() {
  _cactus_install_deps_native || return 1
  _cactus_install_pip_glibc || return 1
  _cactus_verify_glibc || return 1
  loading "Creating wrapper" _cactus_create_glibc_wrapper || return 1

  mkdir -p "$CACTUS_DATA_DIR"
  printf 'native' >"$CACTUS_DATA_DIR/.install-method"
  log_success "Cactus Needle installed natively"
  return 0
}

_cactus_install_proot_pkg() {
  if ! command -v proot &>/dev/null; then
    if ! yes | pkg install proot &>>"$LOG_FILE"; then
      log_error "Failed to install proot"
      return 1
    fi
  fi
  return 0
}

_cactus_create_proot_wrapper() {
  local wrapper_src="$CORE_TOOL_DIR/bin/needle.proot"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  cp "$wrapper_src" "$PREFIX/bin/needle"
  chmod +x "$PREFIX/bin/needle"
  return 0
}

_cactus_install_proot_glibc() {
  _cactus_install_deps_native || return 1
  loading "Installing proot" _cactus_install_proot_pkg || return 1
  _cactus_install_pip_glibc || return 1
  _cactus_verify_glibc || return 1
  loading "Creating proot wrapper" _cactus_create_proot_wrapper || return 1

  mkdir -p "$CACTUS_DATA_DIR"
  printf 'proot-glibc' >"$CACTUS_DATA_DIR/.install-method"
  log_success "Cactus Needle installed with glibc + proot"
  return 0
}

_cactus_install_proot_distro() {
  if ! command -v proot-distro &>/dev/null; then
    if ! yes | pkg install proot-distro &>>"$LOG_FILE"; then
      log_error "Failed to install proot-distro"
      return 1
    fi
  fi
  return 0
}

_cactus_install_ubuntu() {
  if [ ! -d "$(_cactus_detect_ubuntu_root)" ]; then
    if ! proot-distro install ubuntu:24.04 &>>"$LOG_FILE"; then
      log_error "Failed to install Ubuntu container"
      return 1
    fi
  fi
  return 0
}

_cactus_ubuntu_deps() {
  _cactus_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y python3 python3-pip' \
    &>>"$LOG_FILE"
}

_cactus_ubuntu_install_pip() {
  # No "pip install --upgrade pip" here: Ubuntu's distro pip is apt-managed.
  _cactus_proot_ubuntu /bin/bash -c \
    'python3 -m pip install --break-system-packages cactus-needle' \
    &>>"$LOG_FILE"

  local needle_bin="$(_cactus_detect_ubuntu_root)/usr/local/bin/needle"
  if [ ! -f "$needle_bin" ]; then
    log_error "Cactus Needle binary not found after install"
    return 1
  fi
  return 0
}

_cactus_ubuntu_verify() {
  loading "Verifying Cactus Needle" _cactus_ubuntu_verify_impl
}

_cactus_ubuntu_verify_impl() {
  # timeout cannot exec a bash function, so call proot-distro directly
  if ! timeout 300 proot-distro login --shared-tmp ubuntu -- python3 -c "import jax, needle" &>>"$LOG_FILE"; then
    log_error "Cactus Needle installed but jax/jaxlib failed to load in the Ubuntu container — XLA could not start"
    _cactus_proot_ubuntu python3 -m pip uninstall -y cactus-needle &>>"$LOG_FILE"
    return 1
  fi
  return 0
}

_cactus_create_ubuntu_wrapper() {
  local ubuntu_root
  ubuntu_root="$(_cactus_detect_ubuntu_root)"
  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local wrapper_src="$CORE_TOOL_DIR/bin/needle"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/needle"
  chmod +x "$PREFIX/bin/needle"
  return 0
}

_install_cactus_proot() {
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Installing proot-distro" _cactus_install_proot_distro || return 1
  loading "Installing Ubuntu container" _cactus_install_ubuntu || return 1
  loading "Installing dependencies (Ubuntu)" _cactus_ubuntu_deps || return 1
  loading "Installing Cactus Needle (Ubuntu)" _cactus_ubuntu_install_pip || return 1
  loading "Verifying Cactus Needle" _cactus_ubuntu_verify_impl || return 1
  loading "Creating wrapper" _cactus_create_ubuntu_wrapper || return 1

  mkdir -p "$CACTUS_DATA_DIR"
  printf 'proot' >"$CACTUS_DATA_DIR/.install-method"
  log_success "Cactus Needle installed (proot-distro)"
  return 0
}

install_cactus_needle() {
  if command -v needle &>/dev/null; then
    log_info "Cactus Needle is already installed"
    return 2
  fi

  log_info "Select installation method for Cactus Needle:"

  read_select "Installation method" SELECTED_METHOD \
    "glibc (recommended)" \
    "glibc + proot (bad system call)" \
    "proot-distro (ubuntu container)"

  case "$SELECTED_METHOD" in
  *"glibc + proot"*)
    _cactus_install_proot_glibc
    ;;
  *"glibc (recommended)"*)
    _cactus_install_native
    ;;
  *proot-distro*)
    _install_cactus_proot
    ;;
  esac
}

uninstall_cactus_needle() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/needle" ]; then
    log_warn "Cactus Needle is not installed"
    return 1
  fi

  confirm_remove_configs "Cactus Needle" \
    "$HOME/.cache/cactus-needle" \
    "$HOME/.cache/needle" \
    "$HOME/.local/share/needle" \
    "$HOME/.config/needle" \
    "$HOME/.cache/huggingface/hub/models--Cactus-Compute--needle2"

  loading "Uninstalling Cactus Needle" _uninstall_cactus_needle_impl
}

_uninstall_cactus_needle_impl() {
  local method="native"
  if [ -f "$CACTUS_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    _cactus_proot_ubuntu python3 -m pip uninstall -y cactus-needle &>>"$LOG_FILE"
    rm -f "$PREFIX/bin/needle"
    rm -rf "$CACTUS_DATA_DIR"
    log_success "Cactus Needle (proot-distro) uninstalled"
    return 0
  fi

  _cactus_glibc_run -m pip uninstall -y cactus-needle &>>"$LOG_FILE"
  rm -f "$PREFIX/bin/needle"
  rm -rf "$CACTUS_DATA_DIR"
  log_success "Cactus Needle ($method) uninstalled"
  return 0
}

_cactus_installed_version() {
  local method="native"
  if [ -f "$CACTUS_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    _spin_capture "Detecting version" bash -c 'proot-distro login --shared-tmp ubuntu -- python3 -c "from importlib.metadata import version; print(version(\"cactus-needle\"))" 2>/dev/null'
  else
    # glibc-runner -s re-splits args, so pass the check through stdin
    _spin_capture "Detecting version" bash -c 'printf "%s\n" "from importlib.metadata import version; print(version(\"cactus-needle\"))" | glibc-runner -s "$PREFIX/glibc/bin/python" - 2>/dev/null'
  fi
}

update_cactus_needle() {
  _check_update_needed "Cactus Needle" "$(_parse_version "$(_cactus_installed_version)")" "$(_get_remote_pip_version cactus-needle)" _update_cactus_needle
}

_update_cactus_needle() {
  loading "Updating Cactus Needle" _update_cactus_needle_impl
}

_update_cactus_needle_impl() {
  local method="native"
  if [ -f "$CACTUS_DATA_DIR/.install-method" ]; then
    method="$(cat "$CACTUS_DATA_DIR/.install-method")"
  fi

  if [ "$method" = "proot" ]; then
    if ! _cactus_proot_ubuntu /bin/bash -c 'python3 -m pip install --break-system-packages --upgrade cactus-needle' &>>"$LOG_FILE"; then
      log_error "Failed to update Cactus Needle"
      return 1
    fi
    if ! timeout 300 proot-distro login --shared-tmp ubuntu -- python3 -c "import jax, needle" &>>"$LOG_FILE"; then
      log_error "Cactus Needle updated but jax/jaxlib failed to load"
      return 1
    fi
    log_success "Cactus Needle (proot-distro) updated"
    return 0
  fi

  _cactus_install_pip_glibc update || return 1
  _cactus_verify_glibc || return 1
  log_success "Cactus Needle ($method) updated"
  return 0
}

reinstall_cactus_needle() {
  uninstall_cactus_needle
  install_cactus_needle
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_cactus_needle; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_cactus_needle; fi
if [[ "${1:-}" == "update" ]]; then update_cactus_needle; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_cactus_needle; fi
