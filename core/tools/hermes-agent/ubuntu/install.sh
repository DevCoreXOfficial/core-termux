#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"
_impl_install() {
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash &>>"$LOG_FILE"
}

case "${1:-install}" in
  install)
    _impl_install
    ;;
  *)
    exit 0
    ;;
esac
