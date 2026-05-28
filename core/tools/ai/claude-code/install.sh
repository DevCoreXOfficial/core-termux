#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
CLAUDE_DATA_DIR="$HOME/.local/share/core-termux-data/claude"
HELPER_SRC="$CORE_PATH/tools/ai/claude-code/helper/claude_helper.c"

_detect_ubuntu_root() {
	local root
	root="$(find /data/data/com.termux -maxdepth 10 -type d \
		-name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

	if [ -z "$root" ]; then
		root="$(find /data/data/com.termux -maxdepth 10 -type d \
			-name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
	fi

	echo "$root"
}

_proot_ubuntu() {
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- "$@"
}

_get_latest_claude_version() {
	curl -fsSL https://api.github.com/repos/anthropics/claude-code/releases/latest \
		| grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

_install_deps_native() {
	if ! pkg install glibc-repo -y &>>"$LOG_FILE"; then
		log_error "Failed to install glibc-repo"
		return 1
	fi

	if ! pkg install glibc clang curl tar -y &>>"$LOG_FILE"; then
		log_error "Failed to install native dependencies"
		return 1
	fi

	log_success "Dependencies installed"
	return 0
}

_download_claude_binary() {
	local latest_version
	latest_version=$(_get_latest_claude_version)
	if [ -z "$latest_version" ]; then
		log_error "Failed to fetch latest Claude Code version"
		return 1
	fi

	log_info "Latest version: ${D_CYAN}$latest_version${NC}"

	mkdir -p "$CLAUDE_DATA_DIR"

	local tarball="claude-linux-arm64.tar.gz"
	local download_url="https://github.com/anthropics/claude-code/releases/download/$latest_version/$tarball"

	if ! curl -fsSL "$download_url" -o "$CLAUDE_DATA_DIR/$tarball" &>>"$LOG_FILE"; then
		log_error "Failed to download Claude Code binary"
		return 1
	fi

	if ! tar -zxf "$CLAUDE_DATA_DIR/$tarball" -C "$CLAUDE_DATA_DIR" &>>"$LOG_FILE"; then
		log_error "Failed to extract Claude Code binary"
		return 1
	fi

	rm -f "$CLAUDE_DATA_DIR/$tarball"

	if [ ! -f "$CLAUDE_DATA_DIR/claude" ]; then
		log_error "Claude Code binary not found after extraction"
		return 1
	fi

	chmod +x "$CLAUDE_DATA_DIR/claude"
	log_success "Claude Code binary downloaded"
	return 0
}

_compile_claude_helper() {
	if [ ! -f "$HELPER_SRC" ]; then
		log_error "Helper source not found at $HELPER_SRC"
		return 1
	fi

	if ! clang -O2 -o "$PREFIX/bin/claude" "$HELPER_SRC" &>>"$LOG_FILE"; then
		log_error "Failed to compile claude helper"
		return 1
	fi

	chmod +x "$PREFIX/bin/claude"
	log_success "Bootstrapper compiled"
	return 0
}

_install_claude_native() {
	if ! loading "Installing dependencies" _install_deps_native; then
		return 1
	fi

	if ! loading "Downloading Claude Code" _download_claude_binary; then
		return 1
	fi

	if ! loading "Compiling bootstrapper" _compile_claude_helper; then
		return 1
	fi

	log_success "Claude Code installed natively"
	return 0
}

_install_claude_proot() {
	log_info "Installing Claude Code (proot-distro)..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if ! command -v proot-distro &>/dev/null; then
		pkg install proot-distro -y &>>"$LOG_FILE"
	fi

	if [ ! -d "$(_detect_ubuntu_root)" ]; then
		proot-distro install ubuntu &>>"$LOG_FILE"
	fi

	_proot_ubuntu /bin/bash -c \
		'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
		&>>"$LOG_FILE"

	_proot_ubuntu /bin/bash -c '
		export SHELL=/bin/bash
		export TMPDIR=/tmp
		export HOME=/root
		curl -fsSL https://claude.ai/install.sh | bash
	' &>>"$LOG_FILE"

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"

	if [ -z "$ubuntu_root" ]; then
		log_error "Ubuntu rootfs not found"
		return 1
	fi

	if ! _proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
		log_error "Claude Code binary not found after install"
		return 1
	fi

	local wrapper_src="$CORE_PATH/tools/ai/claude-code/bin/claude"
	if [ ! -f "$wrapper_src" ]; then
		log_error "Wrapper template not found at $wrapper_src"
		return 1
	fi
	sed "s|__UBUNTU_ROOTFS__|$ubuntu_root|g" "$wrapper_src" > "$PREFIX/bin/claude"
	chmod +x "$PREFIX/bin/claude"

	if ! grep -q '.local/bin' "$ubuntu_root/root/.bashrc" 2>/dev/null; then
		printf '\n# claude-code\nexport PATH=/root/.local/bin:$PATH\n' >>"$ubuntu_root/root/.bashrc"
	fi

	log_success "Claude Code installed (proot-distro)"
	return 0
}

install_claude_code() {
	if command -v claude &>/dev/null; then
		return 0
	fi

	log_info "Select installation method for Claude Code:"

	read_select "Installation method" SELECTED_METHOD \
		"Native (recommended) - Run with glibc support" \
		"Proot-distro (alternative) - Ubuntu container"

	case "$SELECTED_METHOD" in
	*Native*)
		_install_claude_native
		;;
	*Proot-distro*)
		_install_claude_proot
		;;
	esac
}

uninstall_claude_code() {
	log_info "Uninstalling Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if [ -f "$CLAUDE_DATA_DIR/claude" ]; then
		rm -f "$PREFIX/bin/claude"
		rm -rf "$CLAUDE_DATA_DIR"
		log_success "Claude Code (native) uninstalled"
		return 0
	fi

	_proot_ubuntu /bin/bash -c \
		'rm -f /root/.local/bin/claude && rm -rf /root/.claude && rm -rf /root/.local/share/claude' \
		&>>"$LOG_FILE"

	local ubuntu_bashrc
	ubuntu_bashrc="$(_detect_ubuntu_root)/root/.bashrc"

	if [ -f "$ubuntu_bashrc" ]; then
		sed -i '/# claude-code/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
	fi

	if rm -f "$PREFIX/bin/claude" &>>"$LOG_FILE"; then
		log_success "Claude Code (proot-distro) uninstalled"
		return 0
	else
		log_error "Failed to uninstall Claude Code"
		return 1
	fi
}

update_claude_code() {
	log_info "Updating Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if [ -f "$CLAUDE_DATA_DIR/claude" ]; then
		_install_claude_native
		return $?
	fi

	_proot_ubuntu /bin/bash -c '
		export HOME=/root
		curl -fsSL https://claude.ai/install.sh | bash
	' &>>"$LOG_FILE"

	if ! _proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
		log_error "Claude Code binary not found after update"
		return 1
	fi

	log_success "Claude Code (proot-distro) updated"
	return 0
}
