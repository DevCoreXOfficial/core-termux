#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_lang.log"
BUN_DATA_DIR="$HOME/.local/share/core-termux-data/bun"
BUN_REPO="oven-sh/bun"

_bun_detect_ubuntu_root() {
	local root
	root="$(find /data/data/com.termux -maxdepth 10 -type d \
		-name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

	if [ -z "$root" ]; then
		root="$(find /data/data/com.termux -maxdepth 10 -type d \
			-name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
	fi

	echo "$root"
}

_bun_proot_ubuntu() {
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- "$@"
}

_get_latest_bun_version() {
	_get_remote_github_version "$BUN_REPO"
}

_bun_fetch_version() {
	local raw tag
	raw="$(curl -fsSL "https://api.github.com/repos/$BUN_REPO/releases/latest" 2>/dev/null)"
	tag="$(echo "$raw" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
	if [ -z "$tag" ]; then
		raw="$(curl -fsSL "https://api.github.com/repos/$BUN_REPO/tags?per_page=100" 2>/dev/null)"
		tag="$(echo "$raw" | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | sort -V | tail -1)"
	fi
	_parse_version "$tag"
}

_bun_install_deps_native() {
	loading "Installing glibc and dependencies" _bun_install_deps_native_impl
}

_bun_install_deps_native_impl() {
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
		["unzip"]="unzip"
		["curl"]="curl"
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

_download_bun_binary_native() {
	loading "Downloading Bun (glibc)" _download_bun_binary_native_impl
}

_download_bun_binary_native_impl() {
	local version
	version="$(_bun_fetch_version)"
	if [ -z "$version" ]; then
		log_error "Failed to fetch latest Bun version"
		return 1
	fi

	local arch
	arch="$(uname -m)"
	if [ "$arch" != "aarch64" ] && [ "$arch" != "arm64" ]; then
		log_error "Bun native build only supports aarch64 (got: $arch)"
		return 1
	fi

	mkdir -p "$BUN_DATA_DIR"

	local zip_name="bun-linux-aarch64.zip"
	curl -fsSL "https://github.com/$BUN_REPO/releases/download/bun-v$version/$zip_name" \
		-o "$BUN_DATA_DIR/$zip_name" &>>"$LOG_FILE" || {
		log_error "Failed to download Bun binary"
		return 1
	}

	if ! unzip -o "$BUN_DATA_DIR/$zip_name" -d "$BUN_DATA_DIR" &>>"$LOG_FILE"; then
		log_error "Failed to extract Bun binary"
		return 1
	fi

	rm -f "$BUN_DATA_DIR/$zip_name"

	local extracted="$BUN_DATA_DIR/bun-linux-aarch64/bun"
	if [ ! -f "$extracted" ]; then
		log_error "Bun binary not found after extraction"
		return 1
	fi

	mv -f "$extracted" "$BUN_DATA_DIR/bun.real"
	rm -rf "$BUN_DATA_DIR/bun-linux-aarch64"

	if [ ! -f "$BUN_DATA_DIR/bun.real" ]; then
		log_error "Bun binary not found after extraction"
		return 1
	fi

	chmod +x "$BUN_DATA_DIR/bun.real"
	return 0
}

_compile_bun_helper() {
	loading "Compiling bun helper" _compile_bun_helper_impl
}

_compile_bun_helper_impl() {
	local shim_src="$CORE_PATH/tools/lang/bun/src/bun-shim.c"
	local wrapper_src="$CORE_PATH/tools/lang/bun/src/bun_wrapper.c"

	if [ ! -f "$shim_src" ]; then
		log_error "Shim source not found at $shim_src"
		return 1
	fi

	if [ ! -f "$wrapper_src" ]; then
		log_error "Wrapper source not found at $wrapper_src"
		return 1
	fi

	mkdir -p "$PREFIX/lib"

	if ! clang -O2 -fPIC -shared -nostdlib -o "$PREFIX/lib/bun-shim.so" "$shim_src" &>>"$LOG_FILE"; then
		log_error "Failed to compile bun shim"
		return 1
	fi
	chmod +x "$PREFIX/lib/bun-shim.so"

	local wrapper_tmp="$TMPDIR/bun_wrapper_$$.c"
	sed "s|__BUN_REAL__|$BUN_DATA_DIR/bun.real|g" "$wrapper_src" >"$wrapper_tmp"

	if ! clang -O2 -o "$PREFIX/bin/bun" "$wrapper_tmp" &>>"$LOG_FILE"; then
		rm -f "$wrapper_tmp"
		log_error "Failed to compile bun wrapper"
		return 1
	fi
	chmod +x "$PREFIX/bin/bun"
	rm -f "$wrapper_tmp"

	return 0
}

_install_bun_native() {
	_bun_install_deps_native || return 1
	_download_bun_binary_native || return 1
	_compile_bun_helper || return 1
	ln -sf bun "$PREFIX/bin/bunx"
	log_success "Bun installed natively (glibc build)"
	return 0
}

_install_bun_proot() {
	loading "Installing Bun (proot-distro)" _install_bun_proot_impl
}

_install_bun_proot_impl() {
	mkdir -p "$(dirname "$LOG_FILE")"

	if ! command -v proot-distro &>/dev/null; then
		yes | pkg install proot-distro &>>"$LOG_FILE"
	fi

	if [ ! -d "$(_bun_detect_ubuntu_root)" ]; then
		proot-distro install ubuntu:24.04 &>>"$LOG_FILE"
	fi

	local version
	version="$(_bun_fetch_version)"
	if [ -z "$version" ]; then
		log_error "Failed to fetch latest Bun version"
		return 1
	fi

	local download_url="https://github.com/$BUN_REPO/releases/download/bun-v$version/bun-linux-aarch64.zip"

	_bun_proot_ubuntu /bin/bash -c \
		'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates unzip' \
		&>>"$LOG_FILE"

	_bun_proot_ubuntu /bin/bash -c "
		export HOME=/root TMPDIR=/tmp
		cd /tmp &&
		curl -fsSL '$download_url' -o bun.zip &&
		unzip -o bun.zip >/dev/null 2>&1 &&
		mkdir -p /usr/local/bin &&
		mv bun-linux-aarch64/bun /usr/local/bin/bun &&
		chmod +x /usr/local/bin/bun &&
		rm -rf bun.zip bun-linux-aarch64
	" &>>"$LOG_FILE"

	local ubuntu_root
	ubuntu_root="$(_bun_detect_ubuntu_root)"

	if [ -z "$ubuntu_root" ]; then
		log_error "Ubuntu rootfs not found"
		return 1
	fi

	local bun_bin="$ubuntu_root/usr/local/bin/bun"

	if [ ! -f "$bun_bin" ]; then
		log_error "Bun binary not found after install"
		return 1
	fi

	local wrapper_src="$CORE_PATH/tools/lang/bun/bin/bun"
	if [ ! -f "$wrapper_src" ]; then
		log_error "Wrapper template not found at $wrapper_src"
		return 1
	fi
	sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" >"$PREFIX/bin/bun"
	chmod +x "$PREFIX/bin/bun"

	return 0
}

install_bun() {
	if command -v bun &>/dev/null; then
		log_info "Bun is already installed"
		return 2
	fi

	log_info "Select installation method for Bun:"

	read_select "Installation method" SELECTED_METHOD \
		"Native (recommended) - glibc build with shim" \
		"Proot-distro (alternative) - Ubuntu container"

	case "$SELECTED_METHOD" in
	*Native*)
		_install_bun_native
		;;
	*Proot-distro*)
		_install_bun_proot
		;;
	esac
}

_uninstall_bun_native() {
	rm -f "$PREFIX/bin/bun"
	rm -f "$PREFIX/bin/bunx"
	rm -f "$PREFIX/lib/bun-shim.so"
	rm -rf "$BUN_DATA_DIR"
	log_success "Bun (native) uninstalled"
	return 0
}

_uninstall_bun_proot() {
	_bun_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/bun' &>>"$LOG_FILE"

	if rm -f "$PREFIX/bin/bun" &>>"$LOG_FILE"; then
		log_success "Bun (proot-distro) uninstalled"
		return 0
	else
		log_error "Failed to uninstall Bun"
		return 1
	fi
}

uninstall_bun() {
	mkdir -p "$(dirname "$LOG_FILE")"

	if [ ! -f "$PREFIX/bin/bun" ]; then
		log_warn "Bun is not installed"
		return 2
	fi

	loading "Uninstalling Bun" _uninstall_bun_impl
}

_uninstall_bun_impl() {
	if [ -f "$BUN_DATA_DIR/bun.real" ]; then
		_uninstall_bun_native
		return $?
	fi
	_uninstall_bun_proot
}

_update_bun_native() {
	_download_bun_binary_native || return 1
	_compile_bun_helper || return 1
	log_success "Bun (native) updated"
	return 0
}

_update_bun_proot() {
	local version
	version="$(_get_latest_bun_version)"
	if [ -z "$version" ]; then
		log_error "Failed to fetch latest Bun version"
		return 1
	fi

	local download_url="https://github.com/$BUN_REPO/releases/download/bun-v$version/bun-linux-aarch64.zip"

	_bun_proot_ubuntu /bin/bash -c 'rm -f /usr/local/bin/bun' &>>"$LOG_FILE"

	_bun_proot_ubuntu /bin/bash -c "
		export HOME=/root TMPDIR=/tmp
		cd /tmp &&
		curl -fsSL '$download_url' -o bun.zip &&
		unzip -o bun.zip >/dev/null 2>&1 &&
		mkdir -p /usr/local/bin &&
		mv bun-linux-aarch64/bun /usr/local/bin/bun &&
		chmod +x /usr/local/bin/bun &&
		rm -rf bun.zip bun-linux-aarch64
	" &>>"$LOG_FILE"

	local ubuntu_root
	ubuntu_root="$(_bun_detect_ubuntu_root)"
	local bun_bin="$ubuntu_root/usr/local/bin/bun"

	if [ ! -f "$bun_bin" ]; then
		log_error "Bun binary not found after update"
		return 1
	fi

	log_success "Bun (proot-distro) updated"
	return 0
}

update_bun() {
	_check_update_needed "Bun" "$(_get_installed_version bun)" "$(_get_latest_bun_version)" _update_bun
}

_update_bun() {
	mkdir -p "$(dirname "$LOG_FILE")"

	if [ -f "$BUN_DATA_DIR/bun.real" ]; then
		_update_bun_native
		return $?
	fi
	loading "Updating Bun (proot-distro)" _update_bun_proot
}

reinstall_bun() {
	uninstall_bun
	install_bun
}
