#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
import "@/utils/env"


import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_dev.log"

_superfile_dependencies() {
  loading "Installing dependencies" _superfile_dependencies_impl
}

_superfile_dependencies_impl() {
  declare -A DEPS=(
    ["golang"]="go"
    ["git"]="git"
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

  return 0
}

_get_latest_superfile_version() {
  local raw tag
  raw=$(curl -fsSL https://api.github.com/repos/yorukot/superfile/releases/latest 2>/dev/null)
  tag=$(echo "$raw" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "${tag#v}"
}

_clone_superfile_repo() {
  loading "Cloning superfile repository" _clone_superfile_repo_impl
}

_clone_superfile_repo_impl() {
  if ! git clone --quiet --depth 1 --branch "v$(_get_latest_superfile_version)" https://github.com/yorukot/superfile "$CORE_DATA/superfile" &>>"$LOG_FILE"; then
    log_error "Failed to clone superfile repository"
    return 1
  fi

  return 0
}

_build_superfile() {
  loading "Building superfile binary" _build_superfile_impl
}

_build_superfile_impl() {
  if ! go build -C "$CORE_DATA/superfile" -o "$PREFIX/bin/spf" &>>"$LOG_FILE"; then
    log_error "Failed to build superfile"
    return 1
  fi

  return 0
}

install_superfile() {
  if command -v spf &>/dev/null; then
    log_info "SuperFile is already installed"
    return 2
  fi
  log_info "Installing SuperFile..."

  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  mkdir -p "$(dirname "$LOG_FILE")"

  _superfile_dependencies || return 1
  _clone_superfile_repo || return 1
  _build_superfile || return 1

  log_success "SuperFile installed"
  return 0
}

uninstall_superfile() {
  if ! command -v spf &>/dev/null; then
    log_info "SuperFile is not installed"
    return 2
  fi

  confirm_remove_configs "SuperFile" \
    "$HOME/.config/superfile" \
    "$HOME/.local/share/superfile"

  log_info "Uninstalling SuperFile..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing SuperFile" _uninstall_superfile_impl

  log_success "SuperFile uninstalled"
  return 0
}

_uninstall_superfile_impl() {
  if rm -rf "$CORE_DATA/superfile" && rm -f "$PREFIX/bin/spf" &>>"$LOG_FILE"; then
    return 0
  else
    log_error "Failed to uninstall SuperFile"
    return 1
  fi
}

update_superfile() {
  _check_update_needed "SuperFile" "$(_get_installed_version spf)" "$(_get_remote_github_version yorukot/superfile)" _update_superfile
}

_update_superfile() {
  _update_superfile_impl
}

_update_superfile_impl() {
  export GOPATH="$HOME/.local/go"
  export GOCACHE="$HOME/.cache/go"
  export GOMODCACHE="$GOPATH/pkg/mod"

  mkdir -p "$(dirname "$LOG_FILE")"

  rm -rf "$CORE_DATA/superfile"

  _clone_superfile_repo || return 1
  _build_superfile || return 1
  return 0
}

reinstall_superfile() {
  uninstall_superfile
  install_superfile
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_superfile; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_superfile; fi
if [[ "${1:-}" == "update" ]]; then update_superfile; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_superfile; fi
