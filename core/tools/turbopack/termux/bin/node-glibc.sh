#!/data/data/com.termux/files/usr/bin/bash
# Wrapper for glibc Node.js — runs official linux-arm64 Node via patched ELF
# Unset bionic linker vars so glibc ld.so finds libs from interpreter path
unset LD_LIBRARY_PATH
unset LD_PRELOAD
NODE_GLIBC="$HOME/.local/share/core-termux-data/node-glibc/bin/node"
if [[ ! -x "$NODE_GLIBC" ]]; then
	echo "Turbopack toolchain not installed. Run: core install npm --turbopack" >&2
	exit 1
fi
exec "$NODE_GLIBC" "$@"
