#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Installs Neovim + the Core-vendored NvChad configuration (assets/nvim).
# Existing ~/.config/nvim is backed up, never silently replaced.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_editors.log}"
NVIM_DIR="$HOME/.config/nvim"

_impl_deps() {
  pm_install neovim ripgrep git curl
  # Treesitter compilers for NvChad's syntax parsing.
  command -v gcc >/dev/null 2>&1 || pm_install build-essential
  command -v node >/dev/null 2>&1 || true   # optional: some LSPs want it
}

_impl_install_config() {
  # Back up any existing config, then clear ALL neovim state so distro
  # defaults or previous attempts cannot conflict with NvChad.
  if [[ -d "$NVIM_DIR" ]]; then
    local backup="${NVIM_DIR}.bak.$(date +%s)"
    mv "$NVIM_DIR" "$backup"
    log_info "Existing config backed up to $backup"
  fi
  rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"

  mkdir -p "$(dirname "$NVIM_DIR")"
  cp -r "${CORE_TOOL_DIR}/../assets/nvim" "$NVIM_DIR"
}

_impl_install() {
  loading "Installing dependencies" _impl_deps
  loading "Deploying NvChad configuration" _impl_install_config

  log_info "Bootstraping plugins (first run downloads them)..."
  timeout 120 nvim --headless "+qa" &>>"$LOG_FILE" || \
    log_warn "Plugin bootstrap still pending - open nvim once to finish it"

  log_success "NvChad installed - run: nvim"
}

_impl_uninstall() {
  local answer
  read_confirm_default "Delete the NvChad config ($NVIM_DIR)?" n answer
  [[ "$answer" = y ]] && rm -rf "$NVIM_DIR" "$HOME/.local/share/nvim" "$HOME/.cache/nvim" "$HOME/.local/state/nvim"
  read_confirm_default "Also remove the Neovim binary?" n answer
  [[ "$answer" = y ]] && pm_remove neovim
  log_success "NvChad removed"
}

case "${1:-install}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)
    # Refresh the vendored config over the deployed one (user lua/custom is kept).
    [[ -d "$NVIM_DIR/lua/custom" ]] && cp -r "$NVIM_DIR/lua/custom" /tmp/nvchad-custom.$$ 
    _impl_install_config >/dev/null 2>&1 || true
    [[ -d /tmp/nvchad-custom.$$ ]] && { rm -rf "$NVIM_DIR/lua/custom"; cp -r /tmp/nvchad-custom.$$ "$NVIM_DIR/lua/custom"; rm -rf /tmp/nvchad-custom.$$; }
    nvim --headless "+qa" &>>"$LOG_FILE" || true
    log_success "NvChad updated"
    ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  *) exit 0 ;;
esac
