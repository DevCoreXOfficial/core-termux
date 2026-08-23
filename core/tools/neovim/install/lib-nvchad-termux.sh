#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVCHAD_REPO="https://github.com/DevCoreXOfficial/nvchad-termux.git"
NVCHAD_DIR="$CORE_DATA/nvchad-termux"

_nvchad_dependencies() {
  declare -A DEPS=(
    ["git"]="git"
    ["neovim"]="nvim"
    ["nodejs-lts"]="node"
    ["python"]="python"
    ["perl"]="perl"
    ["curl"]="curl"
    ["wget"]="wget"
    ["lua-language-server"]="lua-language-server"
    ["ripgrep"]="rg"
    ["stylua"]="stylua"
    ["tree-sitter"]="tree-sitter"
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

  log_success "NvChad dependencies installed"
  return 0
}

_install_nvchad_impl() {
  _nvchad_dependencies

  mkdir -p "$(dirname "$LOG_FILE")"

  rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
  if git clone "$NVCHAD_REPO" "$NVCHAD_DIR" &>>"$LOG_FILE"; then
    cp -r "$NVCHAD_DIR/nvim" ~/.config/ &>>"$LOG_FILE"
    nvim --headless "+Lazy! sync" +qa &>>"$LOG_FILE"
    nvim --headless "+Lazy! clean nvim-treesitter" +qa &>>"$LOG_FILE"
    nvim --headless "+Lazy! install nvim-treesitter" +qa &>>"$LOG_FILE"
    log_success "NvChad installed"
    return 0
  else
    log_error "Failed to install NvChad"
    return 1
  fi
}

install_nvchad() {
  if [[ -d "$HOME/.config/nvim" ]]; then
    log_info "NvChad already installed"
    return 0
  fi
  log_info "Installing NvChad..."
  loading "Installing NvChad" _install_nvchad_impl
}

_uninstall_nvchad_impl() {
  if [[ -d "$HOME/.config/nvim" ]]; then
    rm -rf ~/.config/nvim &>>"$LOG_FILE"
    rm -rf ~/.local/state/nvim &>>"$LOG_FILE"
    rm -rf ~/.local/share/nvim &>>"$LOG_FILE"
    rm -rf "$NVCHAD_DIR" &>>"$LOG_FILE"
    log_success "NvChad uninstalled"
  else
    log_warn "NvChad not installed"
  fi
}

uninstall_nvchad() {
  if [[ ! -d "$HOME/.config/nvim" ]]; then
    log_info "NvChad is not installed"
    return 2
  fi
  log_info "Uninstalling NvChad..."
  loading "Uninstalling NvChad" _uninstall_nvchad_impl
}

_update_nvchad() {
  loading "Updating NvChad" _do_nvchad_update
}

_do_nvchad_update() {
  rm -rf "$HOME/.config/nvim" 2>/dev/null
  cp -r "$NVCHAD_DIR/nvim" "$HOME/.config/nvim"
}

update_nvchad() {
  _update_nvchad
}

reinstall_nvchad() {
  uninstall_nvchad
  install_nvchad
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_nvchad; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_nvchad; fi
if [[ "${1:-}" == "update" ]]; then update_nvchad; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_nvchad; fi
