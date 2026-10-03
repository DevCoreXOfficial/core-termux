#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

LOG_FILE="$CORE_CACHE/install_dev.log"

HERDR_MANIFEST_URL="https://herdr.dev/latest.json"
HERDR_BIN_DIR="$PREFIX/bin"

# Herdr publishes release binaries for linux/macos/windows only. Its own
# installer refuses to run when `uname -o` reports Android, so the upstream
# `curl -fsSL https://herdr.dev/install.sh | sh` cannot be used here.
#
# The linux-aarch64 / linux-x86_64 assets are fully static ELF binaries, so
# they run on Termux (bionic) without a glibc or musl shim. This reimplements
# the upstream installer minus the Android gate, keeping the same manifest and
# the same SHA-256 verification.

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

# Read one entry out of a nested manifest block such as "assets" or "sha256",
# both of which map a target id directly to a string value.
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

install_herdr() {
	if command -v herdr &>/dev/null; then
		log_info "Herdr is already installed"
		return 2
	fi

	separator
	box_large "Installing Herdr"
	separator
	echo

	log_info "Installing Herdr..."

	mkdir -p "$(dirname "$LOG_FILE")"

	_install_herdr_bin || return 1
	log_success "Herdr installed"
	return 0
}

_uninstall_herdr_bin() {
	loading "Uninstalling Herdr" _uninstall_herdr_bin_impl
}

_uninstall_herdr_bin_impl() {
	if rm -f "$HERDR_BIN_DIR/herdr" &>>"$LOG_FILE"; then
		return 0
	fi
	log_error "Failed to uninstall Herdr"
	return 1
}

uninstall_herdr() {
	if ! command -v herdr &>/dev/null; then
		log_info "Herdr is not installed"
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

	_uninstall_herdr_bin || return 1
	log_success "Herdr uninstalled"
	return 0
}

_update_herdr_bin() {
	loading "Updating Herdr" _update_herdr_bin_impl
}

_update_herdr_bin_impl() {
	rm -f "$HERDR_BIN_DIR/herdr"
	_install_herdr_bin_impl
}

update_herdr() {
	_check_update_needed "Herdr" "$(_get_installed_version herdr)" \
		"$(_get_latest_herdr_version)" _update_herdr_bin
}

reinstall_herdr() {
	uninstall_herdr
	install_herdr
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_herdr; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_herdr; fi
if [[ "${1:-}" == "update" ]]; then update_herdr; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_herdr; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version herdr; fi
if [[ "${1:-}" == "version-remote" ]]; then _get_latest_herdr_version_silent; fi
