#!/usr/bin/env bash
# install.sh — Bun native install for Termux/Android
# Installs the official Android NDK binary and compiles helper shims.
#
# Usage: install.sh [--prefix DIR]

set -euo pipefail

TERMUX_PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
BUN_VERSION="1.3.14"
BUN_URL="https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-aarch64-android.zip"
SRC_DIR="$(dirname "$0")/src"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix) TERMUX_PREFIX="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

BIN_DIR="${TERMUX_PREFIX}/bin"
LIB_DIR="${TERMUX_PREFIX}/lib"

echo "[install] Bun v${BUN_VERSION} for Termux (Android NDK binary)"
echo "[install] Prefix: ${TERMUX_PREFIX}"

# Find a suitable C compiler (prefer NDK, fall back to system)
if command -v aarch64-linux-android-gcc &> /dev/null; then
    CC="aarch64-linux-android-gcc"
elif command -v "${TERMUX_PREFIX}/bin/aarch64-linux-android-gcc" &> /dev/null; then
    CC="${TERMUX_PREFIX}/bin/aarch64-linux-android-gcc"
elif command -v gcc &> /dev/null; then
    CC="gcc"
else
    echo "[install] ERROR: No C compiler found (aarch64-linux-android-gcc or gcc)"
    exit 1
fi

# --- Download official Android binary ---
mkdir -p "${BIN_DIR}" "${LIB_DIR}" "$(dirname "$0")/download"

ZIP_FILE="$(dirname "$0")/download/bun-linux-aarch64-android.zip"
if [ ! -f "${ZIP_FILE}" ]; then
    echo "[install] Downloading Bun ${BUN_VERSION} Android binary..."
    curl -fSL -o "${ZIP_FILE}" "${BUN_URL}"
else
    echo "[install] Using cached download"
fi

# Extract — the zip contains a single `bun` binary
BUN_BINARY="$(dirname "$0")/download/bun"
if [ ! -f "${BUN_BINARY}" ]; then
    echo "[install] Extracting..."
    unzip -o "${ZIP_FILE}" -d "$(dirname "$0")/download/"
    chmod +x "${BUN_BINARY}"
fi

# Verify it's an Android ELF
if ! file "${BUN_BINARY}" | grep -q "interpreter /system/bin/linker64"; then
    echo "[install] ERROR: Downloaded binary is not an Android ELF!"
    echo "[install] Expected interpreter /system/bin/linker64"
    file "${BUN_BINARY}"
    exit 1
fi

# Get the actual version string from the binary
INSTALLED_VERSION="$("${BUN_BINARY}" --version 2>/dev/null || echo "${BUN_VERSION}")"
echo "[install] Bun version: ${INSTALLED_VERSION}"

# --- Compile the LD_PRELOAD shim ---
# This shim provides two fixes:
# 1. Intercepts opendir/openat64 for /data/ to fix Bun's project-root
#    directory traversal on Termux (blocked sandbox directories)
# 2. Maps .bun section at its ELF virtual address for compiled standalone
#    binaries that have hardcoded absolute pointers

SHIM_SRC="${SRC_DIR}/bun-android-shim.c"
SHIM_OUT="${LIB_DIR}/bun-android-shim.so"

if [ -f "${SHIM_SRC}" ]; then
    echo "[install] Compiling bun-android-shim.so..."

    ${CC} -shared -fPIC -O2 -Wall \
        -o "${SHIM_OUT}" \
        "${SHIM_SRC}" \
        -ldl \
        2>&1 | sed 's/^/[install]   /'

    if [ -f "${SHIM_OUT}" ]; then
        echo "[install] ✅ Shim compiled: ${SHIM_OUT}"
        file "${SHIM_OUT}"
    else
        echo "[install] WARNING: Shim compilation failed"
    fi
else
    echo "[install] Shim source not found at ${SHIM_SRC}, skipping"
fi

# --- Compile the bun-bundle post-processor ---
# After `bun build --compile hello.ts`, run `bun-bundle hello` to create
# a shell wrapper that auto-sets LD_PRELOAD for the compiled binary.
BUNDLE_SRC="${SRC_DIR}/bun-bundle.c"
BUNDLE_OUT="${BIN_DIR}/bun-bundle"

if [ -f "${BUNDLE_SRC}" ]; then
    echo "[install] Compiling bun-bundle..."

    ${CC} -O2 -Wall \
        -o "${BUNDLE_OUT}" \
        "${BUNDLE_SRC}" \
        2>&1 | sed 's/^/[install]   /'

    if [ -f "${BUNDLE_OUT}" ]; then
        echo "[install] ✅ bun-bundle installed: ${BUNDLE_OUT}"
    else
        echo "[install] WARNING: bun-bundle compilation failed"
    fi
else
    echo "[install] bun-bundle source not found at ${BUNDLE_SRC}, skipping"
fi

# --- Install the main bun binary ---
echo "[install] Installing bun to ${BIN_DIR}/bun.real..."
cp "${BUN_BINARY}" "${BIN_DIR}/bun.real"
chmod 755 "${BIN_DIR}/bun.real"

# --- Compile the wrapper ---
# The wrapper resolves relative paths (realpath) and sets LD_PRELOAD.
# Placeholder strings __BUN_REAL__ and __BUN_SHIM__ are substituted at build time.

WRAPPER_SRC="${SRC_DIR}/bun_wrapper.c"
WRAPPER_OUT="${BIN_DIR}/bun"
SHIM_PATH="${LIB_DIR}/bun-android-shim.so"

if [ -f "${WRAPPER_SRC}" ]; then
    echo "[install] Compiling bun wrapper..."

    # Substitute placeholder paths and compile
    sed -e "s|__BUN_REAL__|${BIN_DIR}/bun.real|g" \
        -e "s|__BUN_SHIM__|${SHIM_PATH}|g" \
        "${WRAPPER_SRC}" > "${WRAPPER_SRC}.subst.c"

    ${CC} -O2 -Wall \
        -o "${WRAPPER_OUT}" \
        "${WRAPPER_SRC}.subst.c" \
        2>&1 | sed 's/^/[install]   /'

    rm -f "${WRAPPER_SRC}.subst.c"

    if [ -f "${WRAPPER_OUT}" ]; then
        echo "[install] ✅ Wrapper installed: ${WRAPPER_OUT}"
    else
        echo "[install] WARNING: Wrapper compilation failed, using direct binary"
        ln -sf "${BIN_DIR}/bun.real" "${WRAPPER_OUT}"
    fi
else
    echo "[install] Wrapper source not found at ${WRAPPER_SRC}, using direct binary"
    ln -sf "${BIN_DIR}/bun.real" "${BIN_DIR}/bun"
fi

# --- Verify installation ---
echo ""
echo "[install] Verifying installation..."
if "${BIN_DIR}/bun" --version &>/dev/null; then
    echo "[install] ✅ Bun ${INSTALLED_VERSION} installed successfully!"
    "${BIN_DIR}/bun" --version
else
    echo "[install] ⚠️  bun.real works but the wrapper may need adjustment"
    "${BIN_DIR}/bun.real" --version
fi

echo ""
echo "[install] Done!"
echo "[install]"
echo "[install] To compile and run standalone binaries:"
echo "[install]   bun build --compile hello.ts"
echo "[install]   bun-bundle hello"
echo "[install]   ./hello"
echo "[install]"
echo "[install] Shim: ${SHIM_OUT}"
