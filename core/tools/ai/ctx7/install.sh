#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"
import "@/tools/lang/bun/install"

LOG_FILE="$CORE_CACHE/install_ai.log"

_ctx7_dependencies() {
  loading "Installing dependencies" _ctx7_dependencies_impl
}

_ctx7_dependencies_impl() {
  declare -A DEPS=()

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

  _ensure_bun || return 1

  return 0
}

_install_ctx7_bun() {
  loading "Installing Context7" _install_ctx7_bun_impl
}

_install_ctx7_bun_impl() {
  if ! _install_pkg_fallback "ctx7"; then
    log_error "Failed to install Context7"
    return 1
  fi

  return 0
}

install_ctx7() {
  if command -v ctx7 &>/dev/null; then
    log_info "Context7 is already installed"
    return 2
  fi

  log_info "Installing Context7..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _ctx7_dependencies || return 1
  _install_ctx7_bun || return 1

  log_success "Context7 installed successfully"
  return 0
}

uninstall_ctx7() {
  if ! command -v ctx7 &>/dev/null; then
    log_info "Context7 is not installed"
    return 2
  fi
  log_info "Uninstalling Context7..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Context7" _uninstall_ctx7_impl

  log_success "Context7 uninstalled"
  return 0
}

_uninstall_ctx7_impl() {
  _uninstall_pkg_fallback "ctx7"
  return 0
}

update_ctx7() {
  _check_update_needed "Context7" "$(_get_installed_version ctx7)" "$(_get_remote_npm_version ctx7)" _update_ctx7
}

_update_ctx7() {
  loading "Updating Context7" _update_ctx7_impl
}

_update_ctx7_impl() {
  if ! _install_pkg_fallback "ctx7@latest"; then
    log_error "Failed to update Context7"
    return 1
  fi
  return 0
}

reinstall_ctx7() {
  uninstall_ctx7
  install_ctx7
}
