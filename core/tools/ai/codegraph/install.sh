#!/data/data/com.termux/files/usr/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_install_codegraph_dependencies() {
	declare -A packages=(
		["nodejs-lts"]="node"
		["ripgrep"]="rg"
		["sqlite"]="sqlite"
		["git"]="git"
		["python"]="python"
		["clang"]="clang"
		["make"]="make"
		["curl"]="curl"
	)

	for pkg_name in "${!packages[@]}"; do
		if ! command -v "${packages[$pkg_name]}" &>/dev/null; then
			pkg install "$pkg_name" -y &>>"$LOG_FILE"
		fi
	done
}

_write_codegraph_wrapper() {
	local wrapper_src="$CORE_PATH/tools/ai/codegraph/bin/codegraph"
	if [ ! -f "$wrapper_src" ]; then
		log_error "Wrapper template not found at $wrapper_src"
		return 1
	fi
	cp "$wrapper_src" "$PREFIX/bin/codegraph"
	chmod +x "$PREFIX/bin/codegraph"
}

install_codegraph() {
	if command -v codegraph &>/dev/null; then
		log_success "CodeGraph is already installed"
		return 0
	fi
	log_info "Installing CodeGraph..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if ! _install_codegraph_dependencies; then
		log_error "Failed to install CodeGraph dependencies"
		return 1
	fi

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

	if ! rm -f $PREFIX/tmp/codegraph-linux-arm64.tar.gz &>>"$LOG_FILE"; then
		log_error "Failed to clean up temporary files"
		return 1
	fi

	if ! _write_codegraph_wrapper; then
		log_error "Failed to write CodeGraph wrapper"
		return 1
	fi

	log_success "CodeGraph installed"
	return 0
}

uninstall_codegraph() {
	log_info "Uninstalling CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if rm -rf "$CORE_DATA/codegraph-linux-arm64" && rm -f "$PREFIX/bin/codegraph" &>>"$LOG_FILE"; then
		log_success "CodeGraph uninstalled"
		return 0
	else
		log_error "Failed to uninstall CodeGraph"
		return 1
	fi
}

update_codegraph() {
	log_info "Updating CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if ! rm -rf "$CORE_DATA/codegraph-linux-arm64" &>>"$LOG_FILE"; then
		log_error "Failed to remove old CodeGraph installation"
		return 1
	fi

	if ! rm -f "$PREFIX/bin/codegraph" &>>"$LOG_FILE"; then
		log_error "Failed to remove old CodeGraph wrapper"
		return 1
	fi

	if ! _install_codegraph_dependencies; then
		log_error "Failed to install CodeGraph dependencies"
		return 1
	fi

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

	if ! rm -f $PREFIX/tmp/codegraph-linux-arm64.tar.gz &>>"$LOG_FILE"; then
		log_error "Failed to clean up temporary files"
		return 1
	fi

	if ! _write_codegraph_wrapper; then
		log_error "Failed to write CodeGraph wrapper"
		return 1
	fi

	log_success "CodeGraph updated"
	return 0
}
