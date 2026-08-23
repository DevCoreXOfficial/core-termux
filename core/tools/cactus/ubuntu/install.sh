#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Official upstream flow (documented in cactus-compute/cactus README):
#   apt deps -> clone (pinned tag) -> source ./setup
# The setup script creates its own venv and builds the native engine.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_cactus.log}"
CACTUS_INSTALL_DIR="${HOME}/.local/share/cactus"
CACTUS_REPO="https://github.com/cactus-compute/cactus"
CACTUS_TAG="v2.0.1"

_impl_deps() {
  pm_install python3.12 python3.12-venv python3-pip cmake build-essential \
    libcurl4-openssl-dev git curl ||
    pm_install python3 python3-venv python3-pip cmake build-essential \
      libcurl4-openssl-dev git curl
}

_impl_clone() {
  rm -rf "${CACTUS_INSTALL_DIR}"
  git clone --quiet --depth 1 --branch "${CACTUS_TAG}" "${CACTUS_REPO}" "${CACTUS_INSTALL_DIR}"
}

_impl_setup() {
  # Official bootstrap: venv + pip deps + native engine build.
  (
    cd "${CACTUS_INSTALL_DIR}" || exit 1
    # shellcheck disable=SC1091
    source ./setup
  )
}

_impl_install() {
  mkdir -p "$(dirname "$LOG_FILE")"
  command -v cactus >/dev/null 2>&1 && { log_info "Cactus Engine is already installed"; return 2; }

  log_info "Installing Cactus Engine (official Ubuntu flow, ~15 min build)..."
  _impl_deps || { log_error "Failed to install system dependencies"; return 1; }
  loading "Cloning Cactus ${CACTUS_TAG}" _impl_clone || { log_error "Clone failed"; return 1; }
  loading "Running official setup (venv + native build)" _impl_setup || {
    log_error "Setup failed. Try manually: cd ${CACTUS_INSTALL_DIR} && source ./setup"
    return 1
  }

  if timeout 30 cactus --help &>/dev/null; then
    log_success "Cactus Engine installed"
    echo
    list_item "cactus run Cactus-Compute/needle                    first model (small)"
    list_item "cactus serve Cactus-Compute/needle --port 8080     OpenAI-compatible API"
    echo
    return 0
  fi

  log_error "Smoke test failed. Check the setup output above."
  return 1
}

_impl_uninstall() {
  confirm_remove_configs "Cactus Engine" "$HOME/.cache/cactus" >/dev/null 2>&1 || true

  local weights_dir="${CACTUS_INSTALL_DIR}/weights"
  if [[ -d "${weights_dir}" ]] && [[ -n "$(ls -A "${weights_dir}" 2>/dev/null)" ]]; then
    local size answer
    size="$(du -sh "${weights_dir}" 2>/dev/null | cut -f1)"
    read_confirm_default "Remove downloaded Cactus models (${size})?" "n" answer
    if [[ "${answer}" == "y" ]]; then
      rm -rf "${CACTUS_INSTALL_DIR}"
      log_success "Cactus Engine removed (models deleted)"
    else
      find "${CACTUS_INSTALL_DIR}" -mindepth 1 -maxdepth 1 ! -name weights -exec rm -rf {} +
      log_success "Cactus removed (models kept at ${weights_dir})"
    fi
  else
    rm -rf "${CACTUS_INSTALL_DIR}"
    log_success "Cactus Engine uninstalled"
  fi
  rm -f "$HOME/.local/bin/cactus" /usr/local/bin/cactus 2>/dev/null
}

_impl_update() {
  local had=0
  [[ -d "${CACTUS_INSTALL_DIR}" ]] && had=1
  _impl_uninstall >/dev/null 2>&1 || true
  [[ $had -eq 0 ]] && return 0
  _impl_install
}

case "${1:-install}" in
  install) _impl_install ;;
  uninstall) _impl_uninstall ;;
  update) _impl_update ;;
  reinstall) _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  *) exit 0 ;;
esac
