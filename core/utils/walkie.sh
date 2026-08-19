#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# walkie.sh — shared helpers for the walkie P2P agent
# integration. Agent installers call _walkie_remove_wrapper so
# their uninstall also drops the launcher wrapper walkie
# generates in ~/.local/bin — otherwise `core reinstall <agent>`
# keeps detecting the orphaned wrapper as "still installed".
# ============================================================

import "@/utils/log"

# _walkie_remove_wrapper <bin...> — remove walkie-generated wrapper
# binaries for the given commands from ~/.local/bin. Only files
# carrying the "# walkie agent wrapper" marker are removed, so a
# real binary (or the user's own script) of the same name is never
# touched.
_walkie_remove_wrapper() {
	local wrap_dir="$HOME/.local/bin"
	[[ -d "$wrap_dir" ]] || return 0
	local bin
	for bin in "$@"; do
		[[ -f "$wrap_dir/$bin" ]] || continue
		if grep -q "# walkie agent wrapper" "$wrap_dir/$bin" 2>/dev/null; then
			rm -f "$wrap_dir/$bin"
			log_info "Removed walkie wrapper for $bin"
		fi
	done
}
