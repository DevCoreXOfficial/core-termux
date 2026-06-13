#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_hermes_agent() {
  if command -v hermes &>/dev/null; then
    log_info "Hermes Agent is already installed"
    return 0
  fi

  log_info "Installing Hermes Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash; then
    log_success "Hermes Agent installed successfully"
    return 0
  else
    log_error "Failed to install Hermes Agent"
    return 1
  fi
}

uninstall_hermes_agent() {
  log_info "Uninstalling Hermes Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if rm -rf "$HOME/.hermes" && rm -f "$PREFIX/bin/hermes" &>>"$LOG_FILE"; then
    log_success "Hermes Agent uninstalled successfully"
    return 0
  else
    log_error "Failed to uninstall Hermes Agent"
    return 1
  fi
}

update_hermes_agent() {
  log_info "Updating Hermes Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if hermes update; then
    log_success "Hermes Agent updated successfully"
    return 0
  else
    log_error "Failed to update Hermes Agent"
    return 1
  fi
}

reinstall_hermes_agent() {
  uninstall_hermes_agent
  install_hermes_agent
}
