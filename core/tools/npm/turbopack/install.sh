import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_turbopack.log"
TURBO_DATA_DIR="$HOME/.local/share/core-termux-data/node-glibc"
NODE_VERSION="22.14.0"
NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-arm64.tar.xz"
GLIBC_LIBDIR="/data/data/com.termux/files/usr/glibc/lib"
GLIBC_BINDIR="/data/data/com.termux/files/usr/glibc/bin"

_has_glibc_node() {
	[[ -x "$TURBO_DATA_DIR/bin/node" ]]
}

_installed_version() {
	_has_glibc_node && "$TURBO_DATA_DIR/bin/node" --version 2>/dev/null || echo ""
}

_install_deps() {
	loading "Installing dependencies" _install_deps_impl
}

_install_deps_impl() {
	declare -A DEPS=(
		["curl"]="curl"
		["tar"]="tar"
		["binutils"]="aarch64-linux-android-strip"
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

_download() {
	mkdir -p "$TURBO_DATA_DIR" "$(dirname "$LOG_FILE")"
	local archive="$TURBO_DATA_DIR/node-v${NODE_VERSION}-linux-arm64.tar.xz"
	if [[ ! -f "$archive" ]]; then
		curl -fsSL "$NODE_URL" -o "$archive" || { log_error "download failed"; return 1; }
	fi
	tar -xf "$archive" -C "$TURBO_DATA_DIR" --strip-components=1 || { log_error "extract failed"; return 1; }
	rm -f "$archive"
}

_strip() {
	[[ -f "$TURBO_DATA_DIR/bin/node" ]] || { log_error "node binary not found"; return 1; }
	cp "$TURBO_DATA_DIR/bin/node" "$TURBO_DATA_DIR/bin/node.stripped" || return 1
	aarch64-linux-android-strip "$TURBO_DATA_DIR/bin/node.stripped" &>>"$LOG_FILE"
}

_patch() {
	[[ -f "$TURBO_DATA_DIR/bin/node.stripped" ]] || { log_error "stripped binary not found"; return 1; }
	local patch_script="$CORE_PATH/tools/npm/turbopack/bin/patch-interp.py"
	python3 "$patch_script" \
		"$TURBO_DATA_DIR/bin/node.stripped" \
		"$GLIBC_LIBDIR/ld-linux-aarch64.so.1" &>>"$LOG_FILE" || {
			log_error "patch failed — see $LOG_FILE"
			return 1
		}
	mv "$TURBO_DATA_DIR/bin/node.stripped" "$TURBO_DATA_DIR/bin/node"
	chmod +x "$TURBO_DATA_DIR/bin/node"
}

_install_wrappers() {
	local src="$CORE_PATH/tools/npm/turbopack/bin"
	cp "$src/node-glibc.sh" "$PREFIX/bin/node-glibc" && chmod +x "$PREFIX/bin/node-glibc"
	cp "$src/next-turbopack" "$PREFIX/bin/next-turbopack" && chmod +x "$PREFIX/bin/next-turbopack"
}

_uninstall_node() { rm -rf "$TURBO_DATA_DIR" 2>/dev/null; }
_uninstall_wrappers() { rm -f "$PREFIX/bin/node-glibc" "$PREFIX/bin/next-turbopack" 2>/dev/null; }

install_turbopack() {
	if _has_glibc_node; then
		log_info "Turbopack toolchain already installed"
		read_confirm_default "Reinstall?" "n" REINSTALL
		[[ "$REINSTALL" != "y" ]] && { log_warn "Skipped"; return 0; }
	fi

	_install_deps || return 1
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Downloading Node.js linux-arm64" _download || return 1
	loading "Stripping debug symbols" _strip || { log_error "strip failed"; return 1; }
	loading "Patching ELF interpreter" _patch || return 1
	loading "Installing CLI wrappers" _install_wrappers || { log_error "wrappers failed"; return 1; }
	log_success "Turbopack toolchain installed"
}

uninstall_turbopack() {
	if ! _has_glibc_node; then
		log_warn "Turbopack is not installed"
		return 1
	fi

	loading "Removing Node.js glibc" _uninstall_node
	loading "Removing CLI wrappers" _uninstall_wrappers
	log_success "Turbopack toolchain removed"
}

update_turbopack() { uninstall_turbopack && install_turbopack; }
reinstall_turbopack() { uninstall_turbopack && install_turbopack; }
