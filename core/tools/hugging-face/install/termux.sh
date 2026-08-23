#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_ai.log"
HF_BIN="$HOME/.local/bin/hf"
HF_INSTALL_DIR="$HOME/.hf-cli"

_hf_installed() {
  if command -v hf &>/dev/null; then
    return 0
  fi
  [ -x "$HF_BIN" ]
}

_hugging_face_dependencies() {
  loading "Installing dependencies" _hugging_face_dependencies_impl
}

_hugging_face_dependencies_impl() {
  declare -A DEPS=(
    ["curl"]="curl"
    ["python"]="python3"
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

_install_hugging_face() {
  loading "Installing Hugging Face CLI" _install_hugging_face_impl
}

_install_hugging_face_impl() {
  if ! curl -LsSf https://hf.co/cli/install.sh | bash &>>"$LOG_FILE"; then
    log_error "Failed to install Hugging Face CLI"
    return 1
  fi

  if ! _hf_installed; then
    log_error "Hugging Face CLI binary not found after install"
    return 1
  fi

  return 0
}

# ===== PATH SETUP =====

_hugging_face_setup_path() {
  local rc_file=""
  local path_line='export PATH="$HOME/.local/bin:$PATH"'

  # Priority: .zshrc > .bashrc
  # If .zshrc exists, use it (zsh user — priority shell).
  # Otherwise fall back to .bashrc.
  if [ -f "$HOME/.zshrc" ]; then
    rc_file="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    rc_file="$HOME/.bashrc"
  fi

  if [ -z "$rc_file" ]; then
    log_info "No .zshrc or .bashrc found, skipping PATH setup"
    return 0
  fi

  # Idempotent: only add if the exact line is not already present
  if grep -qxF "$path_line" "$rc_file" 2>/dev/null; then
    log_info "PATH already in $(basename "$rc_file")"
    return 0
  fi

  # Ensure the file ends with a newline before appending
  local last_char
  last_char="$(tail -c 1 "$rc_file" 2>/dev/null || echo "")"
  if [ -n "$last_char" ] && [ "$last_char" != $'\n' ]; then
    echo "" >>"$rc_file"
  fi

  echo "# Added by core-termux hugging-face installer" >>"$rc_file"
  echo "$path_line" >>"$rc_file"
  log_success "Added ~/.local/bin to PATH in $(basename "$rc_file")"
  list_item "Run: ${D_CYAN}source $(basename "$rc_file")${D_NC} to apply, or restart your terminal"
}

install_hugging_face() {
  if _hf_installed; then
    log_info "Hugging Face CLI is already installed"
    return 2
  fi

  log_info "Installing Hugging Face CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  _hugging_face_dependencies || return 1
  _install_hugging_face || return 1
  _hugging_face_setup_path

  log_success "Hugging Face CLI installed successfully"
  return 0
}

uninstall_hugging_face() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! _hf_installed; then
    log_warn "Hugging Face CLI is not installed"
    return 1
  fi

  confirm_remove_configs "Hugging Face CLI" \
    "$HOME/.cache/huggingface" \
    "$HOME/.config/huggingface" \
    "$HOME/.agents/skills/hf-cli" \
    "$HOME/.claude/skills/hf-cli"

  loading "Uninstalling Hugging Face CLI" _uninstall_hugging_face_impl
}

_uninstall_hugging_face_impl() {
  rm -f "$HF_BIN"
  rm -rf "$HF_INSTALL_DIR"

  if [ -e "$HF_BIN" ] || [ -d "$HF_INSTALL_DIR" ]; then
    log_error "Failed to uninstall Hugging Face CLI"
    return 1
  fi

  log_success "Hugging Face CLI uninstalled"
  return 0
}

update_hugging_face() {
  local hf_bin="hf"
  if ! command -v hf &>/dev/null; then
    hf_bin="$HF_BIN"
  fi
  _check_update_needed "Hugging Face CLI" "$(_get_installed_version "$hf_bin" version)" "$(_get_remote_pip_version hf)" _update_hugging_face
}

_update_hugging_face() {
  loading "Updating Hugging Face CLI" _update_hugging_face_impl
}

_update_hugging_face_impl() {
  if ! curl -LsSf https://hf.co/cli/install.sh | bash &>>"$LOG_FILE"; then
    log_error "Failed to update Hugging Face CLI"
    return 1
  fi

  log_success "Hugging Face CLI updated"
  return 0
}

reinstall_hugging_face() {
  uninstall_hugging_face
  install_hugging_face
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_hugging_face; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_hugging_face; fi
if [[ "${1:-}" == "update" ]]; then update_hugging_face; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_hugging_face; fi
