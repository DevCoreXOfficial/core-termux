#!/data/data/com.termux/files/usr/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_pi_dependencies() {
  loading "Installing dependencies" _pi_dependencies_impl
}

_pi_dependencies_impl() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
    ["ripgrep"]="rg"
    ["git"]="git"
    ["fd"]="fd"
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

_install_pi_npm() {
  loading "Installing Pi Coding Agent" _install_pi_npm_impl
}

_install_pi_npm_impl() {
  if ! npm install -g --ignore-scripts @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_error "Failed to install Pi"
    return 1
  fi

  return 0
}

install_pi() {
  if command -v pi &>/dev/null; then
    log_info "Pi Coding Agent is already installed"
    return 2
  fi
  log_info "Installing Pi Coding Agent..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _pi_dependencies || return 1
  _install_pi_npm || return 1

  log_success "Pi Coding Agent installed"
  return 0
}

uninstall_pi() {
  if ! command -v pi &>/dev/null; then
    log_info "Pi Coding Agent is not installed"
    return 2
  fi
  log_info "Uninstalling Pi Coding Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Pi Coding Agent" _uninstall_pi_impl

  log_success "Pi uninstalled"
  return 0
}

_uninstall_pi_impl() {
  if ! npm uninstall -g @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_error "Failed to uninstall Pi"
    return 1
  fi
  return 0
}

update_pi() {
  log_info "Updating Pi Coding Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Updating Pi Coding Agent" _update_pi_impl

  log_success "Pi updated"
  return 0
}

_update_pi_impl() {
  if ! npm install -g --ignore-scripts @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_error "Failed to update Pi"
    return 1
  fi
  return 0
}

reinstall_pi() {
  uninstall_pi
  install_pi
}
