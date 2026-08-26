#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Official upstream flow (cactus-compute README + cactuscompute.com docs):
#   apt deps -> clone -> source ./setup
# The setup script creates a venv, installs the python package and builds
# the native engine. We then expose the `cactus` CLI on PATH.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"

core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_cactus.log}"
CACTUS_INSTALL_DIR="${HOME}/.local/share/cactus"
CACTUS_REPO="https://github.com/cactus-compute/cactus"

_impl_deps() {
  pm_install python3 python3-venv python3-pip cmake build-essential libcurl4-openssl-dev git curl
}

_impl_clone() {
  rm -rf "${CACTUS_INSTALL_DIR}"
  git clone --quiet --depth 1 "${CACTUS_REPO}" "${CACTUS_INSTALL_DIR}"
}

_impl_setup() {
  (
    cd "${CACTUS_INSTALL_DIR}" || exit 1
    # shellcheck disable=SC1091
    source ./setup
  )
}

_impl_expose_cli() {
  mkdir -p "$HOME/.local/bin"
  local found
  found=$(find "${CACTUS_INSTALL_DIR}" -maxdepth 4 -type f -name cactus -path "*bin*" | head -1)
  if [[ -n "$found" ]]; then
    ln -sfn "$found" "$HOME/.local/bin/cactus"
    log_ok "Binary linked into ~/.local/bin"
  fi
}

_impl_install() {
  command -v cactus >/dev/null 2>&1 && { log_info "Cactus Engine is already installed"; return 2; }

  separator
  box_large "Installing Cactus Engine (official Ubuntu flow)"
  separator
  echo
  log_info "Native build - expect ~15 minutes on first run."
  echo

  mkdir -p "$(dirname "$LOG_FILE")"
  _impl_deps || return 1
  loading "Cloning repository" _impl_clone || { log_error "Clone failed"; return 1; }
  loading "Running official setup (venv + build)" _impl_setup || {
    log_error "Setup failed. Try manually:"
    list_item "cd ${CACTUS_INSTALL_DIR} && source ./setup"
    return 1
  }

  _impl_expose_cli

  if command -v cactus >/dev/null 2>&1 && timeout 30 cactus --help &>/dev/null; then
    log_success "Cactus Engine installed!"
    echo
    list_item "cactus run Cactus-Compute/needle          first model (small)"
    list_item "cactus serve Cactus-Compute/needle       OpenAI-compatible API"
    echo
    return 0
  fi

  log_warn "CLI not detected on PATH yet. Open a new terminal or check:"
  list_item "${CACTUS_INSTALL_DIR}"
  return 0
}

_impl_uninstall() {
  confirm_remove_configs "Cactus Engine" "$HOME/.cache/cactus" >/dev/null 2>&1 || true

  local weights_dir="${CACTUS_INSTALL_DIR}/weights"
  if [[ -d "${weights_dir}" ]] && [[ -n "$(ls -A "${weights_dir}" 2>/dev/null)" ]]; then
    local size answer
    size="$(du -sh "${weights_dir}" 2>/dev/null | cut -f1)"
    read_confirm_default "Remove downloaded Cactus models (${size})?" "n" answer
    if [[ "$answer" == "y" ]]; then
      rm -rf "${CACTUS_INSTALL_DIR}"
      log_success "Cactus removed (models deleted)"
    else
      find "${CACTUS_INSTALL_DIR}" -mindepth 1 -maxdepth 1 ! -name weights -exec rm -rf {} +
      log_success "Cactus removed (models kept at ${weights_dir})"
    fi
  else
    rm -rf "${CACTUS_INSTALL_DIR}"
    log_success "Cactus Engine uninstalled"
  fi
  rm -f "$HOME/.local/bin/cactus"
}

case "${1:-install}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _impl_uninstall ; _impl_install ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  *) exit 0 ;;
esac
