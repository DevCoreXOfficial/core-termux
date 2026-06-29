#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"
COMMAND_CODE_DATA_DIR="$HOME/.local/share/core-termux-data/command-code"

_command_code_dependencies() {
  loading "Installing dependencies" _command_code_dependencies_impl
}

_command_code_dependencies_impl() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
    ["git"]="git"
    ["ripgrep"]="rg"
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

_install_command_code_npm() {
  loading "Installing command-code via npm" _install_command_code_npm_impl
}

_install_command_code_npm_impl() {
  mkdir -p "$COMMAND_CODE_DATA_DIR"

  if ! (cd "$COMMAND_CODE_DATA_DIR" && npm init -y &>>"$LOG_FILE"); then
    log_error "Failed to initialize npm project"
    return 1
  fi

  if ! (cd "$COMMAND_CODE_DATA_DIR" && npm install command-code@latest &>>"$LOG_FILE"); then
    log_error "Failed to install command-code package"
    return 1
  fi

  return 0
}

_install_command_code_wrappers() {
  loading "Creating command-code and cmdc wrappers" _install_command_code_wrappers_impl
}

_install_command_code_wrappers_impl() {
  local wrapper_content='#!/data/data/com.termux/files/usr/bin/bash

exec node '"$COMMAND_CODE_DATA_DIR"'/node_modules/command-code/dist/index.mjs "$@"'

  echo "$wrapper_content" >"$PREFIX/bin/command-code"
  chmod +x "$PREFIX/bin/command-code"

  ln -sf "$PREFIX/bin/command-code" "$PREFIX/bin/cmdc"

  return 0
}

install_command_code() {
  if command -v command-code &>/dev/null; then
    log_info "Command Code is already installed"
    return 2
  fi

  log_info "Installing Command Code..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _command_code_dependencies || return 1
  _install_command_code_npm || return 1
  _install_command_code_wrappers || return 1

  log_success "Command Code installed successfully"
  return 0
}

uninstall_command_code() {
  if ! command -v command-code &>/dev/null; then
    log_info "Command Code is not installed"
    return 2
  fi
  log_info "Uninstalling Command Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Command Code files" _uninstall_command_code_impl

  log_success "Command Code uninstalled"
  return 0
}

_uninstall_command_code_impl() {
  rm -f "$PREFIX/bin/command-code"
  rm -f "$PREFIX/bin/cmdc"
  rm -rf "$COMMAND_CODE_DATA_DIR"
  return 0
}

update_command_code() {
  log_info "Updating Command Code..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -d "$COMMAND_CODE_DATA_DIR" ]; then
    log_warn "Command Code is not installed"
    return 1
  fi

  loading "Updating command-code package" _update_command_code_impl

  log_success "Command Code updated"
  return 0
}

_update_command_code_impl() {
  if (cd "$COMMAND_CODE_DATA_DIR" && npm update command-code &>>"$LOG_FILE"); then
    return 0
  else
    log_error "Failed to update Command Code"
    return 1
  fi
}

reinstall_command_code() {
  uninstall_command_code
  install_command_code
}
