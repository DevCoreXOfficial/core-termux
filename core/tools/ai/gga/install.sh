#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"
GGA_DATA_DIR="$CORE_DATA/gga-termux"

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
	loading "Cloning or updating gga-termux repo" _gga_clone_or_update_repo_impl
}

_gga_clone_or_update_repo_impl() {
	local repo_url="https://github.com/DevCoreXOfficial/gga-termux.git"

	if [ -d "$GGA_DATA_DIR/.git" ]; then
		if ! git -C "$GGA_DATA_DIR" pull --ff-only &>>"$LOG_FILE"; then
			log_error "Failed to update gga-termux repo"
			return 1
		fi
	else
		mkdir -p "$(dirname "$GGA_DATA_DIR")"
		if ! git clone "$repo_url" "$GGA_DATA_DIR" &>>"$LOG_FILE"; then
			log_error "Failed to clone gga-termux repo"
			return 1
		fi
	fi

	return 0
}

_gga_run_installer() {
	loading "Running gga-termux installer" _gga_run_installer_impl
}

_gga_run_installer_impl() {
	if [ ! -d "$GGA_DATA_DIR" ] || [ ! -f "$GGA_DATA_DIR/install.sh" ]; then
		log_error "gga-termux repo not found at $GGA_DATA_DIR"
		return 1
	fi

	if ! (cd "$GGA_DATA_DIR" && bash ./install.sh < /dev/null) &>>"$LOG_FILE"; then
		log_error "gga-termux install.sh failed (see $LOG_FILE)"
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
		log_info "Running gga-termux uninstaller..."
		if ! (cd "$GGA_DATA_DIR" && printf "n\n" | bash ./uninstall.sh) &>>"$LOG_FILE"; then
			log_warn "gga-termux uninstall.sh failed, falling back to manual cleanup"
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

update_gga() {
	log_info "Updating GGA..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_gga_clone_or_update_repo || return 1
	_gga_run_installer || return 1

	log_success "GGA updated"
	return 0
}

reinstall_gga() {
	uninstall_gga
	install_gga
}
