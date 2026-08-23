#!/usr/bin/env bash
# Platform: Termux / Android.
# Native Cactus Engine build (no glibc, no proot):
#   clones cactus-compute/cactus @ v2.0.1, patches Python 3.14 /
#   SentencePiece compatibility, installs runtime deps globally via pip,
#   builds libcactus_engine.so with cmake and the run/transcribe binaries
#   with termux-elf-cleaner TLS alignment.
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_ai.log"
CACTUS_INSTALL_DIR="${HOME}/.local/share/cactus"
CACTUS_REPO="https://github.com/cactus-compute/cactus"
CACTUS_TAG="v2.0.1"
PIP_TIMEOUT=900

_cactus_deps() {
  loading "Installing dependencies" _cactus_deps_impl
}

_cactus_deps_impl() {
  declare -A DEPS=(
    ["python"]="python"
    ["python-pip"]="pip"
    ["git"]="git"
    ["cmake"]="cmake"
    ["binutils"]="strip"
    ["pkg-config"]="pkg-config"
    ["rust"]="cargo"
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

  # termux-elf-cleaner fixes TLS alignment on Bionic (p_align >= 64).
  command -v termux-elf-cleaner &>/dev/null || yes | pkg install termux-elf-cleaner &>>"$LOG_FILE"

  # Heavy science stack: recommended, not fatal when unavailable.
  local sci
  for sci in python-numpy python-pillow python-torch python-torchvision python-scipy python-tokenizers; do
    if ! dpkg -s "$sci" &>/dev/null 2>&1; then
      yes | pkg install "$sci" &>>"$LOG_FILE" ||
        log_warn "Optional package '$sci' unavailable (some models may need it)"
    fi
  done
  return 0
}

_cactus_clone() {
  loading "Cloning Cactus ${CACTUS_TAG}" _cactus_clone_impl
}

_cactus_clone_impl() {
  rm -rf "${CACTUS_INSTALL_DIR}"
  git clone --quiet --depth 1 --branch "${CACTUS_TAG}" "${CACTUS_REPO}" "${CACTUS_INSTALL_DIR}" &>>"$LOG_FILE"
}

# Patch requires-python so Python 3.14 is accepted.
_cactus_patch_pyproject() {
  sed -i 's/requires-python = ">=3.10,<3.14"/requires-python = ">=3.10"/' \
    "${CACTUS_INSTALL_DIR}/python/pyproject.toml" &>>"$LOG_FILE" || true
}

# Patch bundle validation: SentencePiece bundles ship tokenizer.model,
# not tokenizer.json — stock validator rejects them and falls back to a
# local build that is impossible for architectures absent from transformers.
_cactus_patch_sentencepiece() {
  python3 - <<'PY' &>>"$LOG_FILE" || true
from pathlib import Path

p = Path.home() / ".local/share/cactus/python/cactus/cli/utils.py"
s = p.read_text(encoding="utf-8")
old = (
    '    optional_required = ["special_tokens.json", "tokenizer.json"]\n'
    '    if tokenizer_type == "bpe":\n'
    '        optional_required.append("merges.txt")'
)
new = (
    '    if tokenizer_type == "sentencepiece":\n'
    '        optional_required = ["special_tokens.json", "tokenizer.model"]\n'
    '    else:\n'
    '        optional_required = ["special_tokens.json", "tokenizer.json"]\n'
    '        if tokenizer_type == "bpe":\n'
    '            optional_required.append("merges.txt")'
)
if old in s:
    p.write_text(s.replace(old, new), encoding="utf-8")
elif 'tokenizer_type == "sentencepiece"' in s and '"tokenizer.model"' in s:
    pass  # already patched
else:
    raise SystemExit("pattern not found")
PY
}

_cactus_pip_runtime() {
  pip install --quiet --no-cache-dir fastapi uvicorn python-multipart httpx "httpcore>=1.0.9" &>>"$LOG_FILE"
}

_cactus_pip_convert_stack() {
  # Only needed for 'cactus convert' (HuggingFace -> CQ weights).
  timeout ${PIP_TIMEOUT} pip install --quiet --no-cache-dir sentencepiece protobuf &>>"$LOG_FILE" ||
    { log_warn "sentencepiece/protobuf failed or timed out ('cactus convert' only)"; return 0; }
  timeout ${PIP_TIMEOUT} pip install --quiet --no-cache-dir --no-deps "transformers==5.5.4" &>>"$LOG_FILE" &&
    timeout ${PIP_TIMEOUT} pip install --quiet --no-cache-dir safetensors regex pyyaml &>>"$LOG_FILE" ||
    { log_warn "convert stack failed or timed out ('cactus convert' only)"; return 0; }
  _cactus_relax_tokenizers_check
}

# transformers 5.5.4 pins tokenizers<=0.23.0; relax it to use apt's newer one.
_cactus_relax_tokenizers_check() {
  python3 - <<'PY' &>>"$LOG_FILE" || true
import importlib.util
from pathlib import Path

spec = importlib.util.find_spec("transformers")
p = Path(spec.submodule_search_locations[0]) / "dependency_versions_table.py"
s = p.read_text()
if '"tokenizers": "tokenizers>=0.22.0,<=0.23.0"' in s:
    p.write_text(s.replace('"tokenizers": "tokenizers>=0.22.0,<=0.23.0"',
                           '"tokenizers": "tokenizers>=0.22.0"'))
PY
}

_cactus_install_cli() {
  pip install --quiet --no-cache-dir --no-deps -e "${CACTUS_INSTALL_DIR}/python" &>>"$LOG_FILE"
  if [[ -f "${PREFIX}/lib/bin/cactus" ]] && ! command -v cactus >/dev/null 2>&1; then
    ln -sf ../lib/bin/cactus "${PREFIX}/bin/cactus"
  fi
}

_cactus_build_engine() {
  loading "Building native engine (~5-15 min)" _cactus_build_engine_impl
}

_cactus_build_engine_impl() {
  (
    cd "${CACTUS_INSTALL_DIR}/cactus-engine" || exit 1
    mkdir -p build && cd build || exit 1
    cmake .. -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_RULE_MESSAGES=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=OFF >"${CACTUS_INSTALL_DIR}/build.log" 2>&1 || exit 1
    make -j"$(nproc)" >>"${CACTUS_INSTALL_DIR}/build.log" 2>&1 || exit 1
  )
}

_cactus_build_binaries() {
  (
    cd "${CACTUS_INSTALL_DIR}" || exit 1
    python3 - <<'PY' >>"${CACTUS_INSTALL_DIR}/build.log" 2>&1 || exit 1
from pathlib import Path
from cactus.cli.compile import build_binary

lib = Path.home() / ".local/share/cactus/cactus-engine/build/libcactus_engine.a"
for name in ("run", "transcribe"):
    if build_binary(name, lib, sdl2=([], [])) != 0:
        raise SystemExit(f"build_binary({name}) failed")
PY
    termux-elf-cleaner \
      "${CACTUS_INSTALL_DIR}/python/cactus/bin/run" \
      "${CACTUS_INSTALL_DIR}/python/cactus/bin/transcribe" &>>"$LOG_FILE"
  )
}

install_cactus() {
  if command -v cactus &>/dev/null; then
    log_info "Cactus Engine is already installed"
    return 2
  fi

  separator
  box "Installing Cactus Engine (native build)"
  separator
  echo
  log_info "C++20 / ARM NEON native build — expect ~15 minutes on device."
  echo

  mkdir -p "$(dirname "$LOG_FILE")"

  _cactus_deps || return 1
  _cactus_clone || { log_error "Failed to clone repository"; return 1; }
  loading "Patching for Python 3.14 / SentencePiece" _cactus_patch_pyproject
  _cactus_patch_sentencepiece

  loading "Installing runtime Python deps" _cactus_pip_runtime || { log_error "Runtime deps failed"; return 1; }

  log_info "Installing optional 'convert' stack (HuggingFace → CQ weights)..."
  _cactus_pip_convert_stack

  loading "Installing Cactus CLI" _cactus_install_cli || { log_error "CLI install failed"; return 1; }
  _cactus_build_engine || {
    log_error "Engine build failed. Log: ${CACTUS_INSTALL_DIR}/build.log"
    return 1
  }
  _cactus_build_binaries || { log_error "CLI binaries build failed"; return 1; }

  if timeout 30 cactus --help &>/dev/null; then
    log_success "Cactus Engine installed (native, no glibc)"
    echo
    list_item "cactus run Cactus-Compute/needle                    ${GRAY}first model${D_NC}"
    list_item "cactus transcribe openai/whisper-base --file a.wav ${GRAY}transcription${D_NC}"
    list_item "cactus serve Cactus-Compute/needle --port 8080     ${GRAY}OpenAI-compatible API${D_NC}"
    echo
    return 0
  fi

  log_error "Cactus smoke test failed. Check: ${CACTUS_INSTALL_DIR}/build.log"
  return 1
}

uninstall_cactus() {
  mkdir -p "$(dirname "$LOG_FILE")"

  confirm_remove_configs "Cactus Engine" \
    "$HOME/.cache/cactus" \
    "$HOME/.config/cactus"

  loading "Removing cactus CLI (pip)" bash -c "pip uninstall -y cactus-compute &>>'$LOG_FILE'" || true

  local weights_dir="${CACTUS_INSTALL_DIR}/weights"
  if [[ -d "${weights_dir}" ]] && [[ -n "$(ls -A "${weights_dir}" 2>/dev/null)" ]]; then
    local size answer
    size="$(du -sh "${weights_dir}" 2>/dev/null | cut -f1)"
    read_confirm_default "Remove downloaded Cactus models (${size})?" "n" answer
    if [[ "${answer}" == "y" ]]; then
      rm -rf "${CACTUS_INSTALL_DIR}"
      log_success "Cactus Engine removed (models deleted)"
    else
      find "${CACTUS_INSTALL_DIR}" -mindepth 1 -maxdepth 1 ! -name weights -exec rm -rf {} +
      log_success "Cactus Engine removed (models kept at ${weights_dir})"
    fi
  else
    rm -rf "${CACTUS_INSTALL_DIR}"
    rm -f "${PREFIX}/bin/cactus"
    log_success "Cactus Engine uninstalled"
    return 0
  fi
  rm -f "${PREFIX}/bin/cactus"
}

_update_cactus() {
  rm -f "${PREFIX}/bin/cactus"
  pip uninstall -y cactus-compute &>>"$LOG_FILE" || true
  install_cactus
}

update_cactus() {
  _check_update_needed "Cactus Engine" "" "" _update_cactus
}

reinstall_cactus() {
  uninstall_cactus
  install_cactus
}

case "${1:-install}" in
  install) install_cactus ;;
  uninstall) uninstall_cactus ;;
  update) update_cactus ;;
  reinstall) reinstall_cactus ;;
  *) exit 0 ;;
esac
