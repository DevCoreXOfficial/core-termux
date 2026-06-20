#!/data/data/com.termux/files/usr/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_codegraph_dependencies() {
	declare -A DEPS=(
		["nodejs-lts"]="node"
		["ripgrep"]="rg"
		["sqlite"]="sqlite"
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
			if ! pkg install "$pkg_name" -y &>>"$LOG_FILE"; then
				log_error "Failed to install $pkg_name"
				return 1
			fi
		fi
	done

	log_success "Dependencies installed"
	return 0
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
		log_info "CodeGraph is already installed"
		return 2
	fi
	log_info "Installing CodeGraph..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if ! _codegraph_dependencies; then
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
	if ! command -v codegraph &>/dev/null; then
		log_info "CodeGraph is not installed"
		return 2
	fi
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

	if ! _codegraph_dependencies; then
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

reinstall_codegraph() {
	uninstall_codegraph
	install_codegraph
}
