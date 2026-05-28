#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
AGY_DATA_DIR="$HOME/.local/share/core-termux-data/antigravity-cli"
HELPER_SRC="$CORE_PATH/tools/ai/antigravity-cli/helper/agy_helper.c"
MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"

_get_latest_agy_version() {
    curl -fsSL "$MANIFEST_URL" | jq -r .version
}

_get_agy_download_url() {
    curl -fsSL "$MANIFEST_URL" | jq -r .url
}

_install_deps() {
    if ! pkg install glibc-repo -y &>>"$LOG_FILE"; then
        log_error "Failed to install glibc-repo"
        return 1
    fi

    if ! pkg install glibc clang python jq curl tar -y &>>"$LOG_FILE"; then
        log_error "Failed to install dependencies"
        return 1
    fi

    log_success "Dependencies installed"
    return 0
}

_download_agy_binary() {
    local latest_version
    latest_version=$(_get_latest_agy_version)
    if [ -z "$latest_version" ]; then
        log_error "Failed to fetch latest Antigravity version"
        return 1
    fi

    log_info "Latest version: ${D_CYAN}$latest_version${NC}"

    mkdir -p "$AGY_DATA_DIR"

    local download_url
    download_url=$(_get_agy_download_url)
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
    log_success "Antigravity CLI binary downloaded"
    return 0
}

_apply_va39_patches() {
    local upstream_bin=""
    if [ -f "$AGY_DATA_DIR/antigravity" ]; then
        upstream_bin="$AGY_DATA_DIR/antigravity"
    elif [ -f "$AGY_DATA_DIR/agy" ]; then
        upstream_bin="$AGY_DATA_DIR/agy"
    else
        log_error "Binary not found for patching"
        return 1
    fi

    log_info "Applying VA39 memory patches..."

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
    log_success "VA39 patches applied"
    return 0
}

_compile_agy_helper() {
    if [ ! -f "$HELPER_SRC" ]; then
        log_error "Helper source not found at $HELPER_SRC"
        return 1
    fi

    if ! clang -O2 -o "$PREFIX/bin/agy" "$HELPER_SRC" &>>"$LOG_FILE"; then
        log_error "Failed to compile agy helper"
        return 1
    fi

    chmod +x "$PREFIX/bin/agy"
    log_success "Bootstrapper compiled to $PREFIX/bin/agy"
    return 0
}

install_antigravity_cli() {
    if command -v agy &>/dev/null; then
        return 0
    fi

    log_info "Installing Antigravity CLI..."

    if ! loading "Installing dependencies" _install_deps; then
        return 1
    fi

    if ! loading "Downloading Antigravity CLI" _download_agy_binary; then
        return 1
    fi

    if ! loading "Applying VA39 patches" _apply_va39_patches; then
        return 1
    fi

    if ! loading "Compiling bootstrapper" _compile_agy_helper; then
        return 1
    fi

    log_success "Antigravity CLI installed"
    return 0
}

uninstall_antigravity_cli() {
    log_info "Uninstalling Antigravity CLI..."
    mkdir -p "$(dirname "$LOG_FILE")"

    rm -f "$PREFIX/bin/agy"
    rm -rf "$AGY_DATA_DIR"

    if [ ! -f "$PREFIX/bin/agy" ] && [ ! -d "$AGY_DATA_DIR" ]; then
        log_success "Antigravity CLI uninstalled"
        return 0
    else
        log_error "Failed to uninstall Antigravity CLI"
        return 1
    fi
}

update_antigravity_cli() {
    log_info "Updating Antigravity CLI..."
    mkdir -p "$(dirname "$LOG_FILE")"

    if ! loading "Downloading Antigravity CLI" _download_agy_binary; then
        return 1
    fi

    if ! loading "Applying VA39 patches" _apply_va39_patches; then
        return 1
    fi

    log_success "Antigravity CLI updated"
    return 0
}
