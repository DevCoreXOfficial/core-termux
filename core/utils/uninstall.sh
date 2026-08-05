#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

# ===== UNINSTALL CONFIG CLEANUP =====

# Asks whether to also delete the configuration directories/files that a
# tool creates, when uninstalling it. Default: keep (n).
#
# Usage: confirm_remove_configs "Tool Name" "/path/one" "/path/two" ...
#
# - Only asks if at least one of the given paths exists.
# - Only removes paths that actually exist.
# - Returns 0 if something was removed, 1 otherwise (kept or nothing to remove).
# - Called from uninstall_<tool>() BEFORE uninstalling the binary.
confirm_remove_configs() {
	local tool_name="$1"
	shift

	local paths=()
	local p
	for p in "$@"; do
		if [ -e "$p" ]; then
			paths+=("$p")
		fi
	done

	if [ ${#paths[@]} -eq 0 ]; then
		log_debug "No configuration files found for $tool_name"
		return 1
	fi

	local answer
	if read_confirm_default "Delete ${tool_name} config files?" "n" answer; then
		for p in "${paths[@]}"; do
			rm -rf "$p"
			log_success "Removed $p"
		done
		return 0
	fi

	log_info "Keeping $tool_name configuration files"
	return 1
}
