#!/data/data/com.termux/files/usr/bin/bash

[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
import "@/utils/env"
import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_muse-code.log"
DATA_DIR="${HOME}/.local/share/muse-code"
LAUNCHER_URL="https://api.meta.ai/muse-launcher.sh"
LAUNCHER="$DATA_DIR/muse-launcher"
CHANNEL_URL="https://api.meta.ai/muse-code/channels/muse-stable"

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

sha256_of() {
  sha256sum "$1" | awk '{print tolower($1)}'
}

_muse_install_deps() {
  loading "Installing dependencies" _muse_install_deps_impl
}

_muse_install_deps_impl() {
  declare -A DEPS=(
    ["proot"]="proot"
    ["curl"]="curl"
    ["python"]="python3"
  )
  local pkg bin
  for pkg in "${!DEPS[@]}"; do
    bin="${DEPS[$pkg]}"
    if ! command -v "$bin" &>/dev/null; then
      if ! yes | pkg install "$pkg" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg"
        return 1
      fi
    fi
  done
  return 0
}

_download_launcher() {
  loading "Downloading Muse launcher" _download_launcher_impl
}

_download_launcher_impl() {
  mkdir -p "$DATA_DIR"
  local tmp headers
  tmp="$(mktemp "$DATA_DIR/.muse-launcher.XXXXXX")"
  headers="$tmp.headers"
  trap 'rm -f "$tmp" "$headers"' RETURN
  if ! curl --fail --silent --show-error --location --max-redirs 3 \
    --proto '=https' --proto-redir '=https' --tlsv1.2 \
    --dump-header "$headers" --output "$tmp" "$LAUNCHER_URL" &>>"$LOG_FILE"; then
    log_error "Failed to download launcher"
    return 1
  fi
  if ! bash -n "$tmp" &>>"$LOG_FILE"; then
    log_error "Downloaded launcher is invalid"
    return 1
  fi
  local advertised
  advertised="$(tr -d '\r' <"$headers" | awk -F': ' 'tolower($1)=="x-content-sha256"{v=$2} END{gsub(/[ \t]/,"",v); print tolower(v)}')"
  if [[ "$advertised" =~ ^[0-9a-f]{64}$ ]]; then
    local actual
    actual="$(sha256_of "$tmp")"
    if [[ "$actual" != "$advertised" ]]; then
      log_error "Launcher checksum verification failed"
      return 1
    fi
  fi
  chmod 755 "$tmp"
  mv -f "$tmp" "$LAUNCHER"
  trap - RETURN
  rm -f "$headers"
  return 0
}

_download_binary() {
  loading "Downloading Muse binary" _download_binary_impl
}

_download_binary_impl() {
  mkdir -p "$DATA_DIR"
  if MUSE_LAUNCHER_INSTALL=1 bash "$LAUNCHER" &>>"$LOG_FILE"; then
    return 0
  else
    log_warn "Binary download failed; first 'muse-code' run will retry"
    return 0
  fi
}

_install_wrapper() {
  loading "Installing Muse Code wrapper" _install_wrapper_impl
}

_install_wrapper_impl() {
  # Wrapper from the official .deb package (uses proot for proper Termux env)
  cat > "$PREFIX/bin/muse-code" <<'WRAPPER'
#!/data/data/com.termux/files/usr/bin/env bash
set -euo pipefail

PREFIX="/data/data/com.termux/files/usr"
LAUNCHER="${HOME}/.local/share/muse-code/muse-launcher"

if [[ ! -f "$LAUNCHER" ]]; then
  printf 'muse-code: launcher missing at %s; rerun the package installation\n' "$LAUNCHER" >&2
  exit 1
fi

bindings=()
for d in data system vendor product odm apex dev proc sys storage sdcard mnt; do
  [[ -e "/$d" ]] && bindings+=( -b "/$d:/$d" )
done

export TZ="${TZ:-$(getprop persist.sys.timezone 2>/dev/null || true)}"

exec proot -r "$PREFIX" "${bindings[@]}" "$PREFIX/bin/bash" "$LAUNCHER" "$@"
WRAPPER
  chmod 755 "$PREFIX/bin/muse-code"
  ln -sf muse-code "$PREFIX/bin/muse" 2>/dev/null || true

  if [[ -r /linkerconfig/ld.config.txt ]]; then
    mkdir -p "${PREFIX}/linkerconfig" 2>/dev/null
    cp /linkerconfig/ld.config.txt "${PREFIX}/linkerconfig/ld.config.txt" 2>/dev/null || true
  fi
  if command -v python3 &>/dev/null && command -v pip &>/dev/null; then
    if pip install -q tzdata 2>>"$LOG_FILE"; then
      local zdir
      zdir="$(python3 -c "import tzdata,pathlib;print(pathlib.Path(tzdata.__path__[0])/'zoneinfo')" 2>/dev/null || true)"
      if [[ -n "$zdir" && -d "$zdir" ]]; then
        mkdir -p "${PREFIX}/share/zoneinfo" 2>/dev/null
        cp -r "$zdir"/. "${PREFIX}/share/zoneinfo/" 2>/dev/null || true
        local tz
        tz="$(getprop persist.sys.timezone 2>/dev/null || true)"
        if [[ -n "$tz" && -f "${PREFIX}/share/zoneinfo/$tz" ]]; then
          cp "${PREFIX}/share/zoneinfo/$tz" "${PREFIX}/etc/localtime" 2>/dev/null || true
        fi
      fi
    fi
  fi
  return 0
}

install_muse_code() {
  if command -v muse-code &>/dev/null; then
    log_info "Muse Code is already installed"
    return 2
  fi

  separator
  box_large "Installing Muse Code"
  separator
  echo

  _muse_install_deps || return 1
  _download_launcher || return 1
  _download_binary || return 1
  _install_wrapper || return 1

  if command -v muse-code &>/dev/null; then
    log_success "Muse Code installed"
    echo
    list_item "Run: ${GRAY_19}muse-code${NC}  (alias: ${GRAY_19}muse${NC})"
    echo
    return 0
  else
    log_warn "Wrapper not found after install"
    return 1
  fi
}

uninstall_muse_code() {
  separator
  box_large "Uninstalling Muse Code"
  separator
  echo

  if ! command -v muse-code &>/dev/null && [[ ! -d "$DATA_DIR" ]]; then
    log_info "Muse Code is not installed"
    return 0
  fi

  confirm_remove_configs "Muse Code" \
    "$HOME/.config/muse" \
    "$HOME/.muse" \
    "$DATA_DIR"

  log_info "Removing Muse Code..."

  rm -f "${PREFIX}/bin/muse" "${PREFIX}/bin/muse-code" 2>/dev/null || true
  rm -rf "$DATA_DIR" 2>/dev/null || true

  log_success "Muse Code uninstalled"
  echo
}

_get_installed_muse_version() {
  local out
  out="$(muse-code --version 2>&1 || muse --version 2>&1 || true)"
  echo "$out" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[~.\-][Rr]?[0-9.]+' | head -1
  if [[ -z "$out" ]]; then
    _get_installed_version muse-code 2>/dev/null || _get_installed_version muse 2>/dev/null || true
  fi
}

_get_remote_muse_version() {
  local ver
  ver="$(curl -fsSL "$CHANNEL_URL" 2>/dev/null | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' | cut -d'"' -f4 | head -1)"
  if [[ -n "$ver" ]]; then
    echo "$ver"
    return 0
  fi
  curl -fsSL "$LAUNCHER_URL" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+~R[0-9.]+' | head -1 || true
}

_update_muse_code() {
  _download_launcher || return 1
  _download_binary || return 1
  log_success "Muse Code updated"
}

update_muse_code() {
  _check_update_needed "Muse Code" "$(_get_installed_muse_version)" "$(_get_remote_muse_version)" _update_muse_code
}

reinstall_muse_code() {
  uninstall_muse_code
  install_muse_code
}

if [[ "${1:-}" == "install" ]]; then install_muse_code; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_muse_code; fi
if [[ "${1:-}" == "update" ]]; then update_muse_code; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_muse_code; fi
