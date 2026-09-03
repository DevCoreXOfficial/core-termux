#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation methods.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/version"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

_impl_install() {
  if command -v gh &>/dev/null; then
    log_info "GitHub CLI is already installed"
    return 2
  fi

  separator
  box_large "Installing GitHub CLI"
  separator
  echo

  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $CORE_SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  $CORE_SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $CORE_SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  pm_install gh
}

_impl_uninstall() {
  if ! command -v gh &>/dev/null; then
    log_info "GitHub CLI is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling GitHub CLI"
  separator
  echo

  $CORE_SUDO rm -f /etc/apt/sources.list.d/github-cli.list
  pm_remove gh
}

_impl_update() {
  $CORE_SUDO apt-get update -qq
  loading "Updating GitHub CLI" $CORE_SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y gh || { log_error "Failed to update GitHub CLI"; return 1; }
  log_success "GitHub CLI updated to the latest version"
}

_impl_vlocal() {
  __gh_vl_query() {
  gh --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1
  }
  _spin_capture "Detecting GitHub API version" __gh_vl_query
}

_impl_vremote() {
  __gh_vr_query() {
  curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d v
  }
  _spin_capture "Checking GitHub API updates" __gh_vr_query
}

case "${1:-}" in
  install)    _impl_install ;;
  uninstall)  _impl_uninstall ;;
  update)     _check_update_needed "GitHub CLI" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)  _impl_uninstall ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
