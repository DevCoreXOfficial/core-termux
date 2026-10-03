#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Official installation method.
# Verbs: install | uninstall | update | reinstall | version-local | version-remote
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"
import "@/lib/platform"
import "@/lib/engine"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install.log}"

HERDR_MANIFEST_URL="https://herdr.dev/latest.json"
HERDR_BIN_DIR="$HOME/.local/bin"

# Herdr publishes release binaries for linux/macos/windows. The linux assets are
# fully static ELF binaries, so they run on glibc and musl systems alike.
# This follows the upstream installer: same release manifest, same target
# selection, same SHA-256 verification before install.

_herdr_arch() {
	local arch
	arch=$(uname -m 2>/dev/null)

	case "$arch" in
	x86_64 | amd64) echo "x86_64" ;;
	aarch64 | arm64) echo "aarch64" ;;
	*)
		log_error "Unsupported architecture for Herdr: $arch"
		return 1
		;;
	esac
}

_herdr_manifest_field() {
	local field="$1" manifest="$2" value

	value=$(printf '%s\n' "$manifest" | awk -v key="\"${field}\"" '
		$0 ~ "^[ \t]*" key "[ \t]*:" {
			sub(/^.*:[ \t]*"/, "")
			sub(/".*$/, "")
			print
			exit
		}
	')

	echo "$value"
}

_herdr_manifest_entry() {
	local block="$1" target="$2" manifest="$3" value

	value=$(printf '%s\n' "$manifest" | awk -v key="\"${block}\"" -v target="\"${target}\"" '
		$0 ~ "^[ \t]*" key "[ \t]*:" { in_block = 1; next }
		in_block && /^[ \t]*}/ { exit }
		in_block && index($0, target) {
			sub(/^.*:[ \t]*"/, "")
			sub(/".*$/, "")
			print
			exit
		}
	')

	echo "$value"
}

_get_latest_herdr_version() {
	local raw
	raw=$(_spin_capture "Checking Herdr" curl -fsSL "$HERDR_MANIFEST_URL" 2>/dev/null)
	_parse_version "$(_herdr_manifest_field "version" "$raw")"
}

_get_latest_herdr_version_silent() {
	local raw
	raw=$(curl -fsSL "$HERDR_MANIFEST_URL" 2>/dev/null)
	_parse_version "$(_herdr_manifest_field "version" "$raw")"
}

_install_herdr_bin() {
	loading "Installing Herdr" _install_herdr_bin_impl
}

_install_herdr_bin_impl() {
	local arch target manifest url sha256 tmpdir actual

	arch=$(_herdr_arch) || return 1
	target="linux-$arch"

	manifest=$(curl -fsSL --retry 3 --connect-timeout 10 --max-time 20 "$HERDR_MANIFEST_URL" 2>/dev/null)
	if [ -z "$manifest" ]; then
		log_error "Failed to fetch Herdr release manifest"
		return 1
	fi

	url=$(_herdr_manifest_entry "assets" "$target" "$manifest")
	sha256=$(_herdr_manifest_entry "sha256" "$target" "$manifest")

	if [ -z "$url" ]; then
		log_error "Release manifest has no binary for $target"
		return 1
	fi
	if [ "${#sha256}" -ne 64 ] || printf '%s\n' "$sha256" | grep -q '[^0-9A-Fa-f]'; then
		log_error "Release manifest has no valid SHA-256 for $target"
		return 1
	fi
	sha256=$(printf '%s\n' "$sha256" | tr 'A-Z' 'a-z')

	tmpdir=$(mktemp -d)
	if ! curl -fsSL --retry 3 --connect-timeout 10 --max-time 300 "$url" -o "$tmpdir/herdr" &>>"$LOG_FILE"; then
		rm -rf "$tmpdir"
		log_error "Failed to download Herdr"
		return 1
	fi

	actual=$(sha256sum <"$tmpdir/herdr" | awk '{print $1}')
	if [ "$actual" != "$sha256" ]; then
		rm -rf "$tmpdir"
		log_error "Herdr checksum did not match"
		return 1
	fi

	chmod +x "$tmpdir/herdr"
	mkdir -p "$HERDR_BIN_DIR"
	if ! mv -f "$tmpdir/herdr" "$HERDR_BIN_DIR/herdr" &>>"$LOG_FILE"; then
		rm -rf "$tmpdir"
		log_error "Failed to install Herdr to $HERDR_BIN_DIR"
		return 1
	fi

	rm -rf "$tmpdir"
	return 0
}

_impl_install() {
	if command -v herdr &>/dev/null; then
		log_info "herdr is already installed"
		return 2
	fi

	separator
	box_large "Installing Herdr"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Installing Herdr" _install_herdr_bin
}

_impl_uninstall() {
	if ! command -v herdr &>/dev/null; then
		log_info "herdr is not installed"
		return 2
	fi

	separator
	box_large "Uninstalling Herdr"
	separator
	echo

	confirm_remove_configs "Herdr" \
		"$HOME/.config/herdr" \
		"${HERDR_HOME:-$HOME/.herdr}"

	mkdir -p "$(dirname "$LOG_FILE")"

	loading "Uninstalling Herdr" _uninstall_herdr_bin
}

_uninstall_herdr_bin() {
	if rm -f "$HERDR_BIN_DIR/herdr" &>>"$LOG_FILE"; then
		log_success "Herdr uninstalled"
		return 0
	fi
	log_error "Failed to uninstall Herdr"
	return 1
}

_impl_update() {
	loading "Updating Herdr" _update_herdr_bin
}

_update_herdr_bin() {
	rm -f "$HERDR_BIN_DIR/herdr"
	_install_herdr_bin_impl
}

_impl_vlocal() {
	_spin_capture "Detecting Herdr version" herdr --version 2>/dev/null
}

_impl_vremote() {
	_get_latest_herdr_version_silent
}

case "${1:-}" in
  install)      _impl_install ;;
  uninstall)    _impl_uninstall ;;
  update)       _check_update_needed "Herdr" "$(_impl_vlocal)" "$(_impl_vremote)" _impl_update ;;
  reinstall)    _impl_uninstall >/dev/null 2>&1 || true ; _impl_install ;;
  version-local)  _impl_vlocal ;;
  version-remote) _impl_vremote ;;
  *)
    exit 0
    ;;
esac
