#!/data/data/com.termux/files/usr/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_pi_dependencies() {
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
      if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  log_success "Dependencies installed"
  return 0
}

install_pi() {
  if command -v pi &>/dev/null; then
    log_info "Pi Coding Agent is already installed"
    return 0
  fi
  log_info "Installing Pi Coding Agent..."

  mkdir -p "$(dirname "$LOG_FILE")"

  if ! _pi_dependencies; then
    log_error "Failed to install Pi dependencies"
    return 1
  fi

  if npm install -g --ignore-scripts @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_success "Pi Coding Agent installed"
    return 0
  else
    log_error "Failed to install Pi"
    return 1
  fi
}

uninstall_pi() {
  log_info "Uninstalling Pi Coding Agent..."
  log_info "Uninstalling Pi..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm uninstall -g @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_success "Pi uninstalled"
    return 0
  else
    log_error "Failed to uninstall Pi"
    return 1
  fi
}

update_pi() {
  log_info "Updating Pi Coding Agent..."
  log_info "Updating Pi..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if npm install -g --ignore-scripts @earendil-works/pi-coding-agent &>>"$LOG_FILE"; then
    log_success "Pi updated"
    return 0
  else
    log_error "Failed to update Pi"
    return 1
  fi
}

reinstall_pi() {
  uninstall_pi
  install_pi
}
