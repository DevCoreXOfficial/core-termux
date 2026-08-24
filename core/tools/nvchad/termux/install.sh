#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_editor.log"

_install_neovim_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if yes | pkg install neovim &>>"$LOG_FILE"; then
    log_success "Neovim installed"
    return 0
  else
    log_error "Failed to install Neovim"
    return 1
  fi
}

install_neovim() {
  if command -v nvim &>/dev/null; then
    log_info "Neovim is already installed"
    return 0
  fi
  log_info "Installing Neovim..."
  loading "Installing Neovim" _install_neovim_impl
}

_uninstall_neovim_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"
  if pkg uninstall neovim -y &>>"$LOG_FILE"; then
    log_success "Neovim uninstalled"
    return 0
  else
    log_error "Failed to uninstall Neovim"
    return 1
  fi
}

uninstall_neovim() {
  if ! command -v nvim &>/dev/null; then
    log_info "Neovim is not installed"
    return 2
  fi

  confirm_remove_configs "Neovim" \
    "$HOME/.config/nvim" \
    "$HOME/.local/share/nvim" \
    "$HOME/.local/state/nvim" \
    "$HOME/.cache/nvim"

  log_info "Uninstalling Neovim..."
  loading "Uninstalling Neovim" _uninstall_neovim_impl
}

_update_neovim_impl() {
  loading "Updating Neovim" _do_neovim_update
}

_do_neovim_update() {
  mkdir -p "$(dirname "$LOG_FILE")"
  yes | pkg upgrade neovim -y &>>"$LOG_FILE"
}

update_neovim() {
  _check_update_needed "Neovim" "$(_get_installed_pkg_version neovim "Neovim")" "$(_get_remote_pkg_version neovim)" _update_neovim_impl
}

reinstall_neovim() {
  uninstall_neovim
  install_neovim
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then
  install_neovim || exit $?
  LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$LIB_DIR/lib-nvchad.sh" deploy || log_warn "NvChad setup failed (see log)"
fi
if [[ "${1:-}" == "uninstall" ]]; then
  LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$LIB_DIR/lib-nvchad.sh" remove_config >/dev/null 2>&1 || true
  uninstall_neovim
fi
if [[ "${1:-}" == "update" ]]; then update_neovim; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_neovim; fi
