#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_hermes_agent() {
  if curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash; then
    return 0
  fi

  # If external installer failed but repo was cloned (Python version mismatch, etc.),
  # retry pip install with --ignore-requires-python
  if [ -f "$HOME/.hermes/hermes-agent/pyproject.toml" ]; then
    cd "$HOME/.hermes/hermes-agent" || return 1
    python -m pip install --ignore-requires-python -e '.[termux-all]' -c constraints-termux.txt 2>&1 && return 0
    python -m pip install --ignore-requires-python -e '.[termux]' -c constraints-termux.txt 2>&1 && return 0
    python -m pip install --ignore-requires-python -e '.' -c constraints-termux.txt 2>&1 && return 0
  fi

  log_error "Failed to install Hermes Agent"
  return 1
}

install_hermes_agent() {
  if command -v hermes &>/dev/null; then
    log_info "Hermes Agent is already installed"
    return 2
  fi

  log_info "Installing Hermes Agent..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_hermes_agent || return 1

  log_success "Hermes Agent installed successfully"
  return 0
}

uninstall_hermes_agent() {
  if ! command -v hermes &>/dev/null; then
    log_info "Hermes Agent is not installed"
    return 2
  fi
  log_info "Uninstalling Hermes Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Hermes Agent" _uninstall_hermes_agent_impl

  log_success "Hermes Agent uninstalled successfully"
  return 0
}

_uninstall_hermes_agent_impl() {
  if rm -rf "$HOME/.hermes" && rm -f "$PREFIX/bin/hermes" &>>"$LOG_FILE"; then
    return 0
  else
    log_error "Failed to uninstall Hermes Agent"
    return 1
  fi
}

update_hermes_agent() {
  _check_update_needed "Hermes Agent" "$(_get_installed_version hermes)" "" _update_hermes_agent
}

_update_hermes_agent() {
  loading "Updating Hermes Agent" _update_hermes_agent_cmd
}

_update_hermes_agent_cmd() {
  if ! hermes update; then
    log_error "Failed to update Hermes Agent"
    return 1
  fi
  return 0
}

reinstall_hermes_agent() {
  uninstall_hermes_agent
  install_hermes_agent
}
