#!/usr/bin/env bash
# Platform: Termux / Android.
# Mirrors ~/nvchad-termux/nvchad.sh: exact deps, config copy to
# ~/.config/nvim, then the three Lazy headless passes.
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_editors.log"
NVIM_DIR="$HOME/.config/nvim"

NVCHAD_PKGS=(git neovim nodejs-lts python perl curl wget lua-language-server ripgrep stylua tree-sitter)

_install_deps() {
  loading "Installing NvChad dependencies" _install_deps_impl
}

_install_deps_impl() {
  local pkg
  for pkg in "${NVCHAD_PKGS[@]}"; do
    dpkg -l | grep -q "^ii  $pkg " || yes | pkg install "$pkg" &>>"$LOG_FILE"
  done
  # Prettier globally (formatter used by conform)
  npm list -g --depth=0 2>/dev/null | grep -q "prettier@" || npm install -g prettier &>>"$LOG_FILE"
}

_deploy_config() {
  if [[ -d "$NVIM_DIR" ]]; then
    local backup="${NVIM_DIR}.bak.$(date +%s)"
    mv "$NVIM_DIR" "$backup"
    log_info "Existing config backed up to $backup"
  fi
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
  _deploy_config

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
  [[ "$answer" = y ]] && yes | pkg uninstall neovim &>>"$LOG_FILE"

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
