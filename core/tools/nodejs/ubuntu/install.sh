#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
# Installs the official NodeSource LTS build (ships node + npm together),
# replacing the outdated distro package entirely.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_languages.log}"

_impl_install() {
  command -v curl >/dev/null 2>&1 || pm_install curl ca-certificates

  loading "Removing outdated distro Node.js" bash -c '
    $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get remove -y nodejs "libnode*" 2>/dev/null || true
    $CORE_SUDO apt-get autoremove -y &>>"'$LOG_FILE'" || true'

  loading "Setting up NodeSource LTS repository" bash -c '
    curl -fsSL https://deb.nodesource.com/setup_lts.x | $CORE_SUDO -E bash - &>>"'$LOG_FILE'"'

  loading "Installing Node.js LTS" bash -c '
    $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs &>>"'$LOG_FILE'"'

  if command -v node >/dev/null 2>&1; then
    log_success "Node.js $(node --version) + npm $(npm --version) installed (LTS)"
  else
    log_error "Node.js failed to install - last output:"
    tail -5 "$LOG_FILE" 2>/dev/null | sed 's/^/  /' >&2
    return 1
  fi
}

_impl_uninstall() {
  local answer
  read_confirm_default "Remove global npm packages too?" n answer
  [[ "$answer" = y ]] && $CORE_SUDO npm ls -g --depth=0 >/dev/null 2>&1 && \
    $CORE_SUDO npm -g rm $(npm ls -g --depth=0 2>/dev/null | awk -F'@' 'NR>1{print $1}' | tr '\n' ' ') 2>/dev/null || true

  read_confirm_default "Also remove your ~/.npm cache and config?" n answer
  [[ "$answer" = y ]] && rm -rf "$HOME/.npm" "$HOME/.npmrc"

  $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get purge -y nodejs 2>/dev/null || true
  $CORE_SUDO rm -f /etc/apt/sources.list.d/nodesource.list 2>/dev/null || true
  $CORE_SUDO apt-get autoremove -y &>/dev/null || true
  log_success "Node.js removed"
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
  log_success "Node.js updated to $(node --version)"
}

_impl_vlocal() {
  node --version 2>/dev/null | tr -d v
}

_impl_vremote() {
  # Official distribution index: first entry is the newest release line.
  curl -fsSL https://nodejs.org/dist/index.json 2>/dev/null \
    | jq -r '[.[] | select(.lts)][0].version' | tr -d v
}

case "${1:-install}" in
  install)        _impl_install ;;
  uninstall)      _impl_uninstall ;;
  update)         _impl_update ;;
  reinstall)      _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *) exit 0 ;;
esac
