#!/data/data/com.termux/files/usr/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_codegraph_dependencies() {
	loading "Installing dependencies" _codegraph_dependencies_impl
}

_codegraph_dependencies_impl() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["ripgrep"]="rg"
		["sqlite"]="sqlite3"
		["git"]="git"
		["python"]="python"
		["clang"]="clang"
		["make"]="make"
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

_download_codegraph() {
	loading "Downloading CodeGraph" _download_codegraph_impl
}

_download_codegraph_impl() {
	LATEST_VERSION=$(curl -sI https://github.com/colbymchenry/codegraph/releases/latest | grep -i location | sed -E 's#.*/tag/([^[:space:]]+).*#\1#')

	if [ -z "$LATEST_VERSION" ]; then
		log_error "Failed to fetch latest CodeGraph version"
		return 1
	fi

	if ! curl -L https://github.com/colbymchenry/codegraph/releases/download/${LATEST_VERSION}/codegraph-linux-arm64.tar.gz -o $PREFIX/tmp/codegraph-linux-arm64.tar.gz &>>"$LOG_FILE"; then
		log_error "Failed to download CodeGraph"
		return 1
	fi

	if ! tar -xzf $PREFIX/tmp/codegraph-linux-arm64.tar.gz -C "$CORE_DATA" &>>"$LOG_FILE"; then
		log_error "Failed to extract CodeGraph"
		return 1
	fi

	rm -f $PREFIX/tmp/codegraph-linux-arm64.tar.gz

	return 0
}

_write_codegraph_wrapper() {
	loading "Creating CodeGraph wrapper" _write_codegraph_wrapper_impl
}

_write_codegraph_wrapper_impl() {
	local wrapper_src="$CORE_PATH/tools/ai/codegraph/bin/codegraph"
	if [ ! -f "$wrapper_src" ]; then
		log_error "Wrapper template not found at $wrapper_src"
		return 1
	fi
	cp "$wrapper_src" "$PREFIX/bin/codegraph"
	chmod +x "$PREFIX/bin/codegraph"

	return 0
}

install_codegraph() {
	if command -v codegraph &>/dev/null; then
		log_info "CodeGraph is already installed"
		return 2
	fi
	log_info "Installing CodeGraph..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_codegraph_dependencies || return 1
	_download_codegraph || return 1
	_write_codegraph_wrapper || return 1

	log_success "CodeGraph installed"
	return 0
}

uninstall_codegraph() {
	if ! command -v codegraph &>/dev/null; then
		log_info "CodeGraph is not installed"
		return 2
	fi
	log_info "Uninstalling CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Removing CodeGraph" _uninstall_codegraph_impl

	log_success "CodeGraph uninstalled"
	return 0
}

_uninstall_codegraph_impl() {
	if rm -rf "$CORE_DATA/codegraph-linux-arm64" && rm -f "$PREFIX/bin/codegraph" &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to uninstall CodeGraph"
		return 1
	fi
}

update_codegraph() {
	log_info "Updating CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Removing old CodeGraph" _update_codegraph_remove_impl
	_codegraph_dependencies || return 1
	_download_codegraph || return 1
	_write_codegraph_wrapper || return 1

	log_success "CodeGraph updated"
	return 0
}

_update_codegraph_remove_impl() {
	if ! rm -rf "$CORE_DATA/codegraph-linux-arm64" &>>"$LOG_FILE"; then
		log_error "Failed to remove old CodeGraph installation"
		return 1
	fi

	if ! rm -f "$PREFIX/bin/codegraph" &>>"$LOG_FILE"; then
		log_error "Failed to remove old CodeGraph wrapper"
		return 1
	fi

	return 0
}

reinstall_codegraph() {
	uninstall_codegraph
	install_codegraph
}
