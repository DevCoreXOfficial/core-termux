#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_ollama_pkg() {
  loading "Installing Ollama" _install_ollama_pkg_impl
}

_install_ollama_pkg_impl() {
  if ! yes | pkg install ollama &>>"$LOG_FILE"; then
    log_error "Failed to install Ollama"
    return 1
  fi

  return 0
}

install_ollama() {
  if command -v ollama &>/dev/null; then
    log_info "Ollama is already installed"
    return 2
  fi
  log_info "Installing Ollama..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_ollama_pkg || return 1

  log_success "Ollama installed"
  return 0
}

uninstall_ollama() {
  if ! command -v ollama &>/dev/null; then
    log_info "Ollama is not installed"
    return 2
  fi
  log_info "Uninstalling Ollama..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Ollama" _uninstall_ollama_impl

  log_success "Ollama uninstalled"
  return 0
}

_uninstall_ollama_impl() {
  if ! pkg uninstall ollama -y &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Ollama"
    return 1
  fi
  return 0
}

update_ollama() {
  _check_update_needed "Ollama" "$(_get_installed_version ollama)" "$(_get_remote_pkg_version ollama)" _update_ollama
}

_update_ollama() {
  loading "Updating Ollama" _update_ollama_impl
}

_update_ollama_impl() {
  if ! pkg upgrade ollama -y &>>"$LOG_FILE"; then
    log_error "Failed to update Ollama"
    return 1
  fi
  return 0
}

reinstall_ollama() {
  uninstall_ollama
  install_ollama
}
