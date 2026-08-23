#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Needle is a 26M-parameter tool-calling MODEL executed through the Cactus
# engine (`cactus run Cactus-Compute/needle`). On Ubuntu there is no separate
# binary to install: this installer ensures Cactus is present, downloads the
# model and provides a `needle` convenience wrapper.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_cactus.log}"
NEEDLE_BIN="$HOME/.local/bin/needle"

_impl_install() {
  if ! command -v cactus >/dev/null 2>&1; then
    log_error "Cactus Engine is required. Run first:"
    list_item "${D_CYAN}core install cactus${D_NC}"
    return 1
  fi

  mkdir -p "$HOME/.local/bin"
  cat >"${NEEDLE_BIN}" <<'EOF'
#!/usr/bin/env bash
# Needle (26M tool-calling model) via the Cactus engine.
exec cactus run Cactus-Compute/needle "$@"
EOF
  chmod +x "${NEEDLE_BIN}"

  loading "Downloading Needle model" bash -c "cactus download Cactus-Compute/needle &>>'${LOG_FILE}'" ||
    log_warn "Model download failed — it will be fetched on first run"

  log_success "Needle ready (wrapper at ${NEEDLE_BIN})"
  echo
  list_item "needle --tools my_tools.json     ${GRAY}OpenAI function-calling format${D_NC}"
  echo
}

_impl_uninstall() {
  rm -f "${NEEDLE_BIN}"
  local answer
  read_confirm_default "Also delete the downloaded Needle model?" "n" answer
  if [[ "${answer}" == "y" ]] && command -v cactus >/dev/null 2>&1; then
    cactus clean >/dev/null 2>&1 || true
  fi
  log_success "Needle removed"
}

case "${1:-install}" in
  install) _impl_install ;;
  uninstall) _impl_uninstall ;;
  update) _impl_install ;;
  reinstall) _impl_uninstall ; _impl_install ;;
  *) exit 0 ;;
esac
