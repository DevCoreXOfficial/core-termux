#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"

_hermes_install_deps() {
  loading "Installing dependencies" _hermes_install_deps_impl
}

_hermes_install_deps_impl() {
  declare -A DEPS=(
    ["python"]="python"
    ["nodejs-lts"]="node"
    ["ripgrep"]="rg"
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

  if ! command -v python &>/dev/null; then
    log_error "Python is required but could not be installed"
    return 1
  fi

  return 0
}

_hermes_install_python_pkgs() {
  loading "Installing Python packages (psutil, cryptography)" _hermes_install_python_pkgs_impl
}

_hermes_install_python_pkgs_impl() {
  local need_install=()

  if ! python -c "import psutil" &>/dev/null; then
    need_install+=("python-psutil")
  fi

  if ! python -c "import cryptography" &>/dev/null; then
    need_install+=("python-cryptography")
  fi

  if [ ${#need_install[@]} -gt 0 ]; then
    if ! yes | pkg install "${need_install[@]}" &>>"$LOG_FILE"; then
      log_error "Failed to install Python packages: ${need_install[*]}"
      return 1
    fi
  fi

  return 0
}

_hermes_run_installer() {
  loading "Running Hermes Agent installer" _hermes_run_installer_impl
}

_hermes_run_installer_impl() {
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash &>>"$LOG_FILE"
}

_hermes_pip_fallback() {
  loading "Installing with pip (--ignore-requires-python)" _hermes_pip_fallback_impl
}

_hermes_pip_fallback_impl() {
  local HERMES_DIR="$HOME/.hermes/hermes-agent"
  cd "$HERMES_DIR" || return 1
  python -m pip install --ignore-requires-python -e '.[termux-all]' -c constraints-termux.txt &>>"$LOG_FILE" && return 0
  python -m pip install --ignore-requires-python -e '.[termux]' -c constraints-termux.txt &>>"$LOG_FILE" && return 0
  python -m pip install --ignore-requires-python -e '.' -c constraints-termux.txt &>>"$LOG_FILE" && return 0
  return 1
}

_hermes_apply_patches() {
  loading "Applying Termux compatibility patches" _hermes_apply_patches_impl
}

_hermes_apply_patches_impl() {
  local HERMES_DIR="$HOME/.hermes/hermes-agent"

  if [ ! -f "$HERMES_DIR/pyproject.toml" ]; then
    log_error "Hermes Agent repo not found after installer"
    return 1
  fi

  # Symlink system cryptography into the venv to avoid build failure
  local PY_VER
  PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
  local VENV_SITE="$HERMES_DIR/venv/lib/python${PY_VER}/site-packages"
  local SYS_SITE="$PREFIX/lib/python${PY_VER}/site-packages"

  if [ -d "$SYS_SITE/cryptography" ] && [ -d "$VENV_SITE" ] && [ ! -e "$VENV_SITE/cryptography" ]; then
    ln -s "$SYS_SITE/cryptography" "$VENV_SITE/cryptography"
  fi

  # Fix main.py: PROJECT_ROOT may not resolve in editable installs
  sed -i 's|print(f"Install directory: {PROJECT_ROOT}")|print(f"Install directory: {os.path.dirname(os.path.dirname(os.path.abspath(__file__)))}")|' "$HERMES_DIR/hermes_cli/main.py"

  return 0
}

_install_hermes_agent() {
  _hermes_install_deps || return 1
  _hermes_install_python_pkgs || return 1
  _hermes_run_installer && return 0

  # Installer failed — repo should be cloned, apply patches and retry
  _hermes_apply_patches || return 1
  _hermes_run_installer && return 0

  # Still failing (Python version constraint) — force install with pip
  _hermes_pip_fallback && return 0

  log_error "Failed to install Hermes Agent"
  return 1
}

install_hermes_agent() {
  if command -v hermes &>/dev/null; then
    log_info "Hermes Agent is already installed"
    return 2
  fi

  log_info "Installing Hermes Agent..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_hermes_agent || return 1

  log_success "Hermes Agent installed successfully"
  return 0
}

uninstall_hermes_agent() {
  if ! command -v hermes &>/dev/null; then
    log_info "Hermes Agent is not installed"
    return 2
  fi
  log_info "Uninstalling Hermes Agent..."
  mkdir -p "$(dirname "$LOG_FILE")"

  loading "Removing Hermes Agent" _uninstall_hermes_agent_impl

  log_success "Hermes Agent uninstalled successfully"
  return 0
}

_uninstall_hermes_agent_impl() {
  if rm -rf "$HOME/.hermes" && rm -f "$PREFIX/bin/hermes" &>>"$LOG_FILE"; then
    return 0
  else
    log_error "Failed to uninstall Hermes Agent"
    return 1
  fi
}

_hermes_get_release_date() {
  hermes --version 2>/dev/null | grep -oP '\(\K[0-9]+\.[0-9]+\.[0-9]+' || echo ""
}

update_hermes_agent() {
  if ! command -v hermes &>/dev/null; then
    log_warn "Hermes Agent: not installed"
    echo
    local confirm_var
    read_confirm_default "Install Hermes Agent?" "y" confirm_var
    if [ "$confirm_var" = "y" ]; then
      install_hermes_agent
      return $?
    fi
    log_info "Skipped Hermes Agent"
    return 0
  fi

  local installed_ver
  installed_ver=$(_get_installed_version hermes)
  local remote_ver
  remote_ver=$(_get_remote_github_version NousResearch/hermes-agent)

  if [ -n "$remote_ver" ] && [ -n "$installed_ver" ]; then
    local local_date
    local_date=$(_hermes_get_release_date)
    local remote_date
    remote_date=$(echo "$remote_ver" | sed 's/^v//')

    if [ -n "$local_date" ] && [ "$local_date" = "$remote_date" ]; then
      log_success "Hermes Agent is already up to date (v${installed_ver})"
      return 2
    fi
    log_info "Hermes Agent: ${D_GREEN}v${installed_ver}${D_NC} → ${D_CYAN}v${remote_ver}${D_NC}"
  else
    log_info "Hermes Agent: v${installed_ver}"
  fi

  echo
  local confirm_var
  read_confirm_default "Update Hermes Agent?" "y" confirm_var
  if [ "$confirm_var" != "y" ]; then
    log_info "Skipped Hermes Agent"
    return 0
  fi

  _update_hermes_agent
}

_update_hermes_agent() {
  if hermes update; then
    return 0
  fi

  # hermes update failed — apply patches and reinstall
  if [ -f "$HOME/.hermes/hermes-agent/pyproject.toml" ]; then
    _hermes_apply_patches || return 1
    _hermes_run_installer && return 0
    _hermes_pip_fallback && return 0
  fi

  log_error "Failed to update Hermes Agent"
  return 1
}

reinstall_hermes_agent() {
  uninstall_hermes_agent
  install_hermes_agent
}
