#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_ollama() {
  if command -v ollama &>/dev/null; then
    log_info "Ollama is already installed"
    return 2
  fi
  log_info "Installing Ollama..."

  mkdir -p "$(dirname "$LOG_FILE")"

  if pkg install ollama -y &>>"$LOG_FILE"; then
    log_success "Ollama installed"
    return 0
  else
    log_error "Failed to install Ollama"
    return 1
  fi
}

uninstall_ollama() {
  if ! command -v ollama &>/dev/null; then
    log_info "Ollama is not installed"
    return 2
  fi
  log_info "Uninstalling Ollama..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if pkg uninstall ollama -y &>>"$LOG_FILE"; then
    log_success "Ollama uninstalled"
    return 0
  else
    log_error "Failed to uninstall Ollama"
    return 1
  fi
}

update_ollama() {
  log_info "Updating Ollama..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if pkg upgrade ollama -y &>>"$LOG_FILE"; then
    log_success "Ollama updated"
    return 0
  else
    log_error "Failed to update Ollama"
    return 1
  fi
}

reinstall_ollama() {
  uninstall_ollama
  install_ollama
}
