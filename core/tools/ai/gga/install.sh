#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"

LOG_FILE="$CORE_CACHE/install_ai.log"
GGA_DATA_DIR="$CORE_DATA/gentleman-guardian-angel"
GGA_PATCH_DIR="${BASH_SOURCE[0]:+$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
: "${GGA_PATCH_DIR:=$CORE_PATH/tools/ai/gga}"

_gga_dependencies() {
	loading "Installing dependencies" _gga_dependencies_impl
}

_gga_dependencies_impl() {
	declare -A DEPS=(
		["git"]="git"
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

_gga_clone_or_update_repo() {
	loading "Cloning or updating GGA repo" _gga_clone_or_update_repo_impl
}

_gga_clone_or_update_repo_impl() {
	local repo_url="https://github.com/Gentleman-Programming/gentleman-guardian-angel.git"

	if [ -d "$GGA_DATA_DIR/.git" ]; then
		if ! git -C "$GGA_DATA_DIR" pull --ff-only &>>"$LOG_FILE"; then
			log_error "Failed to update GGA repo"
			return 1
		fi
	else
		mkdir -p "$(dirname "$GGA_DATA_DIR")"
		if ! git clone "$repo_url" "$GGA_DATA_DIR" &>>"$LOG_FILE"; then
			log_error "Failed to clone GGA repo"
			return 1
		fi
	fi

	return 0
}

_gga_apply_termux_patches() {
	loading "Applying Termux patches" _gga_apply_termux_patches_impl
}

_gga_apply_termux_patches_impl() {
	local patch_script="$GGA_PATCH_DIR/termux.patch"

	if [ ! -f "$patch_script" ]; then
		log_error "Termux patch script not found at $patch_script"
		return 1
	fi

	# Reset any previous patches to ensure clean state
	git -C "$GGA_DATA_DIR" checkout -- . &>/dev/null || true

	if ! bash "$patch_script" "$GGA_DATA_DIR" &>>"$LOG_FILE"; then
		log_error "Failed to apply Termux patches"
		return 1
	fi

	return 0
}

_gga_run_installer() {
	loading "Running GGA installer" _gga_run_installer_impl
}

_gga_run_installer_impl() {
	if [ ! -d "$GGA_DATA_DIR" ] || [ ! -f "$GGA_DATA_DIR/install.sh" ]; then
		log_error "GGA repo not found at $GGA_DATA_DIR"
		return 1
	fi

	if ! (cd "$GGA_DATA_DIR" && bash ./install.sh < /dev/null) &>>"$LOG_FILE"; then
		log_error "GGA install.sh failed (see $LOG_FILE)"
		return 1
	fi

	return 0
}

install_gga() {
	if command -v gga &>/dev/null; then
		log_info "GGA is already installed"
		return 2
	fi

	log_info "Installing GGA..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_gga_dependencies || return 1
	_gga_clone_or_update_repo || return 1
	_gga_apply_termux_patches || return 1
	_gga_run_installer || return 1

	log_success "GGA installed"
	return 0
}

uninstall_gga() {
	if ! command -v gga &>/dev/null; then
		log_info "GGA is not installed"
		return 2
	fi
	log_info "Uninstalling GGA..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if [ -d "$GGA_DATA_DIR" ] && [ -f "$GGA_DATA_DIR/uninstall.sh" ]; then
		log_info "Running GGA uninstaller..."
		# Apply patches first so uninstall.sh knows about Termux paths
		_gga_apply_termux_patches_impl &>/dev/null || true
		if ! (cd "$GGA_DATA_DIR" && printf "n\n" | bash ./uninstall.sh) &>>"$LOG_FILE"; then
			log_warn "GGA uninstall.sh failed, falling back to manual cleanup"
		fi
	fi

	rm -f "$PREFIX/bin/gga"
	rm -rf "${PREFIX:-/data/data/com.termux/files/usr}/share/gga"
	rm -rf "$GGA_DATA_DIR"

	if [ ! -f "$PREFIX/bin/gga" ] && [ ! -d "$GGA_DATA_DIR" ]; then
		log_success "GGA uninstalled"
		return 0
	else
		log_error "Failed to uninstall GGA"
		return 1
	fi
}

_update_gga() {
	mkdir -p "$(dirname "$LOG_FILE")"

	_gga_clone_or_update_repo || return 1
	_gga_apply_termux_patches || return 1
	_gga_run_installer || return 1

	log_success "GGA updated"
	return 0
}

update_gga() {
	_check_update_needed "GGA" "$(_get_installed_version gga)" "$(_get_remote_github_version Gentleman-Programming/gentleman-guardian-angel)" _update_gga
}

reinstall_gga() {
	uninstall_gga
	install_gga
}
