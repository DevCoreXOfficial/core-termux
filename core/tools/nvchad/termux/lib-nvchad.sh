#!/usr/bin/env bash
# Platform: Termux / Android.
# Deploys the Core-vendored NvChad configuration (assets/nvim).
# No external repository cloning anymore.
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_editor.log"
NVIM_DIR="$HOME/.config/nvim"

nvchad_deploy() {
  if [[ -d "$NVIM_DIR" ]]; then
    local backup="${NVIM_DIR}.bak.$(date +%s)"
    mv "$NVIM_DIR" "$backup"
    log_info "Existing config backed up to $backup"
  fi
  mkdir -p "$(dirname "$NVIM_DIR")"
  cp -r "${CORE_TOOL_DIR}/../assets/nvim" "$NVIM_DIR"

  log_info "Bootstraping plugins (first run downloads them)..."
  timeout 180 nvim --headless "+qa" &>>"$LOG_FILE" || \
    log_warn "Plugin bootstrap still pending - open nvim once to finish it"
}

nvchad_remove_config() {
  rm -rf "$NVIM_DIR" "$HOME/.local/share/nvim" "$HOME/.cache/nvim" "$HOME/.local/state/nvim"
}
