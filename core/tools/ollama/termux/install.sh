#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

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

  confirm_remove_configs "Ollama" \
    "$HOME/.ollama" \
    "$HOME/.ollama_code_history"

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

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_ollama; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_ollama; fi
if [[ "${1:-}" == "update" ]]; then update_ollama; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_ollama; fi
