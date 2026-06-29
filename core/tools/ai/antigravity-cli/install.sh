#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
AGY_DATA_DIR="$HOME/.local/share/core-termux-data/antigravity-cli"
MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"

_antigravity_get_latest_version() {
  curl -fsSL "$MANIFEST_URL" | jq -r .version
}

_antigravity_get_download_url() {
  curl -fsSL "$MANIFEST_URL" | jq -r .url
}

_antigravity_cli_dependencies() {
  loading "Installing glibc and dependencies" _antigravity_cli_dependencies_impl
}

_antigravity_cli_dependencies_impl() {
  if [[ ! -f $PREFIX/etc/apt/sources.list.d/glibc.list ]]; then
    if ! yes | pkg install glibc-repo &>>"$LOG_FILE"; then
      log_error "Failed to install glibc-repo"
      return 1
    fi
  fi

  if [[ ! -f $PREFIX/glibc/lib/libc.so.6 ]]; then
    if ! yes | pkg install glibc &>>"$LOG_FILE"; then
      log_error "Failed to install glibc"
      return 1
    fi
  fi

  declare -A DEPS=(
    ["clang"]="clang"
    ["python"]="python"
    ["jq"]="jq"
    ["curl"]="curl"
    ["tar"]="tar"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if [[ -n "$bin_name" ]] && command -v "$bin_name" &>/dev/null; then
      continue
    fi
    if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
      log_error "Failed to install $pkg_name"
      return 1
    fi
  done

  return 0
}

_antigravity_download_binary() {
  loading "Downloading Antigravity CLI binary" _antigravity_download_binary_impl
}

_antigravity_download_binary_impl() {
  local latest_version
  latest_version=$(_antigravity_get_latest_version)
  if [ -z "$latest_version" ]; then
    log_error "Failed to fetch latest Antigravity version"
    return 1
  fi

  mkdir -p "$AGY_DATA_DIR"

  local download_url
  download_url=$(_antigravity_get_download_url)
  local tarball="$AGY_DATA_DIR/agy.tar.gz"

  if ! curl -fsSL -o "$tarball" "$download_url" &>>"$LOG_FILE"; then
    log_error "Failed to download Antigravity CLI binary"
    return 1
  fi

  if ! tar -xzf "$tarball" -C "$AGY_DATA_DIR" &>>"$LOG_FILE"; then
    log_error "Failed to extract Antigravity CLI binary"
    return 1
  fi

  rm -f "$tarball"

  local upstream_bin=""
  if [ -f "$AGY_DATA_DIR/antigravity" ]; then
    upstream_bin="$AGY_DATA_DIR/antigravity"
  elif [ -f "$AGY_DATA_DIR/agy" ]; then
    upstream_bin="$AGY_DATA_DIR/agy"
  else
    log_error "Could not find binary in extracted archive"
    return 1
  fi

  chmod +x "$upstream_bin"
  return 0
}

_antigravity_apply_va39_patches() {
  loading "Applying VA39 memory patches" _antigravity_apply_va39_patches_impl
}

_antigravity_apply_va39_patches_impl() {
  local upstream_bin=""
  if [ -f "$AGY_DATA_DIR/antigravity" ]; then
    upstream_bin="$AGY_DATA_DIR/antigravity"
  elif [ -f "$AGY_DATA_DIR/agy" ]; then
    upstream_bin="$AGY_DATA_DIR/agy"
  else
    log_error "Binary not found for patching"
    return 1
  fi

  python3 - "$upstream_bin" "${AGY_DATA_DIR}/agy.va39" <<'PY'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())
def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)

lo, hi = 0, len(data)
for off in range(lo, hi, 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))
for off in range(lo, hi - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)
for off in range(lo, hi, 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)
word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}
for off in range(lo, hi, 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])
for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)
dst.write_bytes(data)
PY

  chmod +x "$AGY_DATA_DIR/agy.va39"
  return 0
}

_antigravity_detect_ubuntu_root() {
  local root
  root="$(find /data/data/com.termux -maxdepth 10 -type d \
    -name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

  if [ -z "$root" ]; then
    root="$(find /data/data/com.termux -maxdepth 10 -type d \
      -name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
  fi

  echo "$root"
}

_antigravity_proot_ubuntu() {
  proot-distro login \
    --shared-tmp \
    ubuntu \
    -- "$@"
}

_antigravity_compile_helper() {
  loading "Compiling helper" _antigravity_compile_helper_impl
}

_antigravity_compile_helper_impl() {
  local HELPER_SRC="$CORE_PATH/tools/ai/antigravity-cli/helper/agy_helper.c"
  if [ ! -f "$HELPER_SRC" ]; then
    log_error "Helper source not found at $HELPER_SRC"
    return 1
  fi

  if ! clang -O2 -o "$PREFIX/bin/agy" "$HELPER_SRC" &>>"$LOG_FILE"; then
    log_error "Failed to compile agy helper"
    return 1
  fi

  chmod +x "$PREFIX/bin/agy"
  return 0
}

_install_antigravity_proot() {
  loading "Installing Antigravity CLI (proot-distro)" _install_antigravity_proot_impl
}

_install_antigravity_proot_impl() {
  mkdir -p "$(dirname "$LOG_FILE")"

  if ! command -v proot-distro &>/dev/null; then
    yes | pkg install proot-distro &>>"$LOG_FILE"
  fi

  if [ ! -d "$(_antigravity_detect_ubuntu_root)" ]; then
    proot-distro install ubuntu &>>"$LOG_FILE"
  fi

  _antigravity_proot_ubuntu /bin/bash -c \
    'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
    &>>"$LOG_FILE"

  _antigravity_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://antigravity.google/cli/install.sh | bash
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_antigravity_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local upstream_bin=""
  local candidates=(
    "$ubuntu_root/root/.local/bin/agy"
    "$ubuntu_root/root/.agy/bin/agy"
    "$ubuntu_root/usr/local/bin/agy"
  )
  for p in "${candidates[@]}"; do
    if [ -f "$p" ]; then
      upstream_bin="$p"
      break
    fi
  done

  if [ -z "$upstream_bin" ]; then
    log_error "Antigravity CLI binary not found after install"
    return 1
  fi

  python3 - "$upstream_bin" "${upstream_bin}.va39" <<'PY'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())
def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)

lo, hi = 0, len(data)
for off in range(lo, hi, 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))
for off in range(lo, hi - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)
for off in range(lo, hi, 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)
word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}
for off in range(lo, hi, 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])
for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)
dst.write_bytes(data)
PY

  chmod +x "${upstream_bin}.va39"

  local wrapper_src="$CORE_PATH/tools/ai/antigravity-cli/bin/agy"
  if [ ! -f "$wrapper_src" ]; then
    log_error "Wrapper template not found at $wrapper_src"
    return 1
  fi
  sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/agy"
  chmod +x "$PREFIX/bin/agy"

  if ! grep -q '.local/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
    printf '\n# antigravity-cli\nexport PATH=/root/.local/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
  fi

  return 0
}

install_antigravity_cli() {
  if command -v agy &>/dev/null; then
    log_info "Antigravity CLI is already installed"
    return 2
  fi

  log_info "Select installation method for Antigravity CLI:"

  read_select "Installation method" SELECTED_METHOD \
    "Native (recommended) - Compile with glibc support" \
    "Proot-distro (alternative) - Ubuntu container"

  case "$SELECTED_METHOD" in
  *Native*)
    _antigravity_cli_dependencies || return 1
    _antigravity_download_binary || return 1
    _antigravity_apply_va39_patches || return 1
    _antigravity_compile_helper || return 1
    log_success "Antigravity CLI installed"
    return 0
    ;;
  *Proot-distro*)
    _install_antigravity_proot
    ;;
  esac
}

uninstall_antigravity_cli() {
  log_info "Uninstalling Antigravity CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ ! -f "$PREFIX/bin/agy" ]; then
    log_warn "Antigravity CLI is not installed"
    return 1
  fi

  if [ -f "$AGY_DATA_DIR/agy.va39" ]; then
    rm -f "$PREFIX/bin/agy"
    rm -rf "$AGY_DATA_DIR"
    log_success "Antigravity CLI (native) uninstalled"
    return 0
  fi

  _antigravity_proot_ubuntu /bin/bash -c \
    'rm -f /root/.local/bin/agy /root/.local/bin/agy.va39 && rm -rf /root/.agy' \
    &>>"$LOG_FILE"

  local ubuntu_bashrc
  ubuntu_bashrc="$(_antigravity_detect_ubuntu_root)/root/.bashrc"

  if [ -f "$ubuntu_bashrc" ]; then
    sed -i '/# antigravity-cli/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
  fi

  if rm -f "$PREFIX/bin/agy" &>>"$LOG_FILE"; then
    log_success "Antigravity CLI (proot-distro) uninstalled"
    return 0
  else
    log_error "Failed to uninstall Antigravity CLI"
    return 1
  fi
}

update_antigravity_cli() {
  log_info "Updating Antigravity CLI..."
  mkdir -p "$(dirname "$LOG_FILE")"

  if [ -f "$AGY_DATA_DIR/agy.va39" ]; then
    _antigravity_download_binary || return 1
    _antigravity_apply_va39_patches || return 1
    log_success "Antigravity CLI (native) updated"
    return 0
  fi

  _antigravity_proot_ubuntu /bin/bash -c \
    'rm -f /root/.local/bin/agy /root/.local/bin/agy.va39' \
    &>>"$LOG_FILE"

  _antigravity_proot_ubuntu /bin/bash -c '
    export SHELL=/bin/bash
    export TMPDIR=/tmp
    export HOME=/root
    curl -fsSL https://antigravity.google/cli/install.sh | bash
  ' &>>"$LOG_FILE"

  local ubuntu_root
  ubuntu_root="$(_antigravity_detect_ubuntu_root)"

  if [ -z "$ubuntu_root" ]; then
    log_error "Ubuntu rootfs not found"
    return 1
  fi

  local upstream_bin=""
  local candidates=(
    "$ubuntu_root/root/.local/bin/agy"
    "$ubuntu_root/root/.agy/bin/agy"
    "$ubuntu_root/usr/local/bin/agy"
  )
  for p in "${candidates[@]}"; do
    if [ -f "$p" ]; then
      upstream_bin="$p"
      break
    fi
  done

  if [ -z "$upstream_bin" ]; then
    log_error "Antigravity CLI binary not found after update"
    return 1
  fi

  log_info "Applying VA39 patches (proot)..."
  python3 - "$upstream_bin" "${upstream_bin}.va39" <<'PY'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())
def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)

lo, hi = 0, len(data)
for off in range(lo, hi, 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))
for off in range(lo, hi - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)
for off in range(lo, hi, 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)
word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}
for off in range(lo, hi, 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])
for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)
dst.write_bytes(data)
PY

  chmod +x "${upstream_bin}.va39"
  log_success "Antigravity CLI (proot-distro) updated"
  return 0
}

reinstall_antigravity_cli() {
  uninstall_antigravity_cli
  install_antigravity_cli
}
