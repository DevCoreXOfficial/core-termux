#!/usr/bin/env bash
# Platform: Termux / Android.
# huggingface_hub installed globally via pip — NO venv, NO glibc.
#
# Key detail (from the improved package): --no-deps on huggingface_hub
# because hf-xet is a hard dep on aarch64 with no Termux wheel and hangs
# the build (Rust/maturin). Its real deps are pure-python and listed
# explicitly below. Xet transfers are disabled through profile.d so
# Xet-hosted repos still download over classic HTTP.
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"
HF_PROFILE_D="${PREFIX}/etc/profile.d/huggingface.sh"

_hf_deps() {
  loading "Installing dependencies" _hf_deps_impl
}

_hf_deps_impl() {
  declare -A DEPS=(
    ["python"]="python"
    ["python-pip"]="pip"
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
}

_hf_install_hub() {
  loading "Installing huggingface_hub (pip, global)" _hf_install_hub_impl
}

_hf_install_hub_impl() {
  # --no-deps: avoid hf-xet (no aarch64 wheel for Termux; Rust build hangs).
  pip install --quiet --no-cache-dir --no-deps "httpcore>=1.0.9" huggingface_hub &>>"$LOG_FILE" || return 1
  # Real runtime deps: pure-python wheels, install cleanly.
  pip install --quiet --no-cache-dir click "filelock>=3.10" "fsspec>=2023.5" packaging pyyaml "tqdm>=4.42" "typing-extensions>=4.1" &>>"$LOG_FILE" || return 1

  # Ensure the CLIs are reachable when pip lands them under $PREFIX/lib/bin.
  if [[ -f "${PREFIX}/lib/bin/huggingface-cli" ]] && ! command -v huggingface-cli >/dev/null 2>&1; then
    ln -sf ../lib/bin/huggingface-cli "${PREFIX}/bin/huggingface-cli"
  fi
  if [[ -f "${PREFIX}/lib/bin/hf" ]] && ! command -v hf >/dev/null 2>&1; then
    ln -sf ../lib/bin/hf "${PREFIX}/bin/hf"
  fi
  return 0
}

# hf_xet cannot build for Termux Python 3.14 (_Py_FalseStruct missing) and
# huggingface_hub declares it as hard dep on aarch64. Forcing classic HTTP
# downloads keeps Xet-hosted repos working. Safe to remove once a working
# hf-xet wheel ships for Termux.
_hf_disable_xet() {
  mkdir -p "$(dirname "$HF_PROFILE_D")"
  cat >"${HF_PROFILE_D}" <<'EOF'
# Disable Xet transfers: hf-xet has no wheel for Termux (aarch64) and is broken on
# Python 3.14 (_Py_FalseStruct). Removed automatically with the 'huggingface' tool.
export HF_HUB_DISABLE_XET=1
EOF
  log_info "Xet downloads disabled via ${HF_PROFILE_D}"
}

install_hugging_face() {
  if command -v hf &>/dev/null || command -v huggingface-cli &>/dev/null; then
    log_info "Hugging Face CLI is already installed"
    return 2
  fi

  log_info "Installing Hugging Face CLI..."

  mkdir -p "$(dirname "$LOG_FILE")"

  _hf_deps || return 1
  _hf_install_hub || { log_error "Failed to install huggingface_hub"; return 1; }
  _hf_disable_xet

  if timeout 30 hf version &>/dev/null || timeout 30 huggingface-cli version &>/dev/null; then
    log_success "Hugging Face CLI installed (global pip, no venv)"
    echo
    list_item "hf download <repo>            ${GRAY}download models/datasets${D_NC}"
    list_item "huggingface-cli login          ${GRAY}authenticate${D_NC}"
    echo
    return 0
  fi

  log_error "Hugging Face CLI smoke test failed. Check $LOG_FILE"
  return 1
}

uninstall_hugging_face() {
  _walkie_remove_wrapper hf
  mkdir -p "$(dirname "$LOG_FILE")"

  confirm_remove_configs "Hugging Face" \
    "$HOME/.cache/huggingface" \
    "$HOME/.config/huggingface" \
    "$HOME/.cache/huggingface-token"

  loading "Removing huggingface-hub" bash -c "pip uninstall -y huggingface-hub &>>'$LOG_FILE'" || true
  rm -f "${HF_PROFILE_D}" "${PREFIX}/bin/hf" "${PREFIX}/bin/huggingface-cli"
  rm -rf "${HOME}/.local/share/huggingface"
  log_success "Hugging Face CLI uninstalled"
  return 0
}

_update_hugging_face() {
  pip install --quiet --no-cache-dir --no-deps --upgrade "httpcore>=1.0.9" huggingface_hub &>>"$LOG_FILE" &&
    pip install --quiet --no-cache-dir --upgrade click "filelock>=3.10" "fsspec>=2023.5" packaging pyyaml "tqdm>=4.42" "typing-extensions>=4.1" &>>"$LOG_FILE"
}

update_hugging_face() {
  local local_ver remote_ver
  local_ver="$(_get_installed_version hf version 2>/dev/null)"
  remote_ver="$(_get_remote_pip_version huggingface_hub)"

  if [[ -z "$local_ver" || -z "$remote_ver" ]]; then
    local answer
    read_confirm_default "Could not compare versions. Update anyway?" "y" answer
    [[ "$answer" == "y" ]] && { loading "Updating Hugging Face CLI" _update_hugging_face; }
    return
  fi

  _check_update_needed "Hugging Face CLI" "$local_ver" "$remote_ver" _update_hugging_face
}

reinstall_hugging_face() {
  uninstall_hugging_face
  install_hugging_face
}

case "${1:-install}" in
  install) install_hugging_face ;;
  uninstall) uninstall_hugging_face ;;
  update) update_hugging_face ;;
  reinstall) reinstall_hugging_face ;;
  *) exit 0 ;;
esac
