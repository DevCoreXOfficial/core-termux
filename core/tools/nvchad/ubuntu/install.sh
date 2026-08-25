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

NVCHAD_PKGS=(git nodejs npm lua-language-server ripgrep stylua tree-sitter curl wget)
# Neovim >= 0.10 is required (config uses vim.uv); distro packages ship 0.9.x,
# so we install the official upstream build instead of the apt one.

_ensure_nvim_recent() {
  local need="0.10"
  local have=""
  command -v nvim >/dev/null 2>&1 && have="$(nvim --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  if [[ -n "$have" ]] && [[ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -1)" == "$need" ]]; then
    return 0
  fi

  loading "Installing Neovim >= 0.10 (official upstream build)" _ensure_nvim_recent_impl
}

_ensure_nvim_recent_impl() {
  local tag arch dir
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64) arch="arm64" ;;
    *) arch="$(uname -m)" ;;
  esac
  tag=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
          | grep '"tag_name"' | cut -d'"' -f4)
  [[ -z "$tag" ]] && { log_error "Could not resolve latest Neovim release"; return 1; }

  dir="$HOME/.local/opt/nvim-${tag}"
  mkdir -p "$dir" "$HOME/.local/bin"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${tag}/nvim-linux-${arch}.tar.gz" \
    | tar -C "$HOME/.local/opt" -xz &>>"$LOG_FILE" || { log_error "Download failed"; return 1; }

  # Atomic-ish swap so an interrupted run never leaves a broken link.
  rm -rf "$dir.old"; [[ -d "$dir" ]] || { log_error "Extraction failed"; return 1; }
  ln -sfn "${dir}/bin/nvim" "$HOME/.local/bin/nvim"
}

_install_deps() {
  loading "Installing NvChad dependencies" _install_deps_impl
}

_install_deps_impl() {
  _ensure_nvim_recent || return 1
  export PATH="$HOME/.local/bin:$PATH"
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
  if [[ "$answer" = y ]]; then
    rm -f "$HOME/.local/bin/nvim"
    rm -rf "$HOME/.local/opt"/nvim-* 2>/dev/null
    pm_remove neovim 2>/dev/null || true
  fi

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
