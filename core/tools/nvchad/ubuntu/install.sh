#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Same flow as Termux but with the Ubuntu-adapted config
# (system LSPs via PATH, no hardcoded Termux paths) and pre-clean of any
# existing neovim state as requested.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/uninstall"
import "@/lib/platform"

core_detect_platform

LOG_FILE="$CORE_CACHE/install_editors.log"
NVIM_DIR="$HOME/.config/nvim"

NVCHAD_PKGS=(git neovim nodejs npm lua-language-server ripgrep stylua tree-sitter curl wget)

_install_deps() {
  loading "Installing NvChad dependencies" _install_deps_impl
}

_install_deps_impl() {
  pm_install "${NVCHAD_PKGS[@]}" build-essential
  command -v prettier >/dev/null 2>&1 || _npm_g install -g prettier
}

_deploy_config() {
  # Pre-clean existing neovim state (distro defaults / old attempts).
  rm -rf "$NVIM_DIR" "$HOME/.local/state/nvim" "$HOME/.local/share/nvim"
  mkdir -p "$(dirname "$NVIM_DIR")"
  cp -r "${CORE_TOOL_DIR}/nvim" "$NVIM_DIR"
}

_lazy_sync() {
  nvim --headless "+Lazy! sync" +qa &>>"$LOG_FILE"
  nvim --headless "+Lazy! clean nvim-treesitter" +qa &>>"$LOG_FILE"
  nvim --headless "+Lazy! install nvim-treesitter" +qa &>>"$LOG_FILE"
}

install_nvchad() {
  separator
  box_large "Installing NvChad (Neovim)"
  separator
  echo

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_deps || return 1
  loading "Deploying NvChad configuration" _deploy_config

  log_info "Syncing plugins (headless)..."
  _lazy_sync || log_warn "Some plugins still syncing - open nvim once more"

  log_success "NvChad installed! Start Neovim with 'nvim'"
  return 0
}

uninstall_nvchad() {
  confirm_remove_configs "NvChad" \
    "$HOME/.config/nvim" \
    "$HOME/.local/share/nvim" \
    "$HOME/.cache/nvim" \
    "$HOME/.local/state/nvim"

  read_confirm_default "Also remove the Neovim binary?" n answer
  [[ "$answer" = y ]] && pm_remove neovim

  log_success "NvChad removed"
  return 0
}

update_nvchad() {
  install_nvchad
}

reinstall_nvchad() {
  uninstall_nvchad
  install_nvchad
}

if [[ "${1:-}" == "install" ]]; then install_nvchad; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_nvchad; fi
if [[ "${1:-}" == "update" ]]; then update_nvchad; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_nvchad; fi
