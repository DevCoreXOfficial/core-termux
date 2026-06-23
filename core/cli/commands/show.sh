#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

show_main() {
	if [[ $# -eq 0 ]]; then
		echo
		box "Core Show"
		echo
		log_info "Usage: core show <module> --<tool>"
		echo
		log_info "Display help information for a specific tool."
		echo
		log_info "Available targets:"
		echo
		list_item "core show ai --opencode"
		list_item "core show ai --ollama"
		list_item "core show db --postgresql"
		list_item "core show dev --gh"
		list_item "core show npm --typescript"
		list_item "core show all --<tool>"
		echo
		log_info "Run ${D_CYAN}core list <module>${NC} to see available tools"
		echo
		return
	fi

	local module=""
	local tool=""

	for arg in "$@"; do
		if [[ "$arg" == --* ]]; then
			tool="${arg#--}"
		elif [[ -z "$module" ]]; then
			module="$arg"
		fi
	done

	if [[ -z "$module" ]]; then
		log_error "Usage: core show <module> --<tool>"
		return 1
	fi

	if [[ -z "$tool" ]]; then
		separator_section "$module - Available Tools"
		echo
		local tool_dir="$CORE_PATH/tools/$module"
		if [[ ! -d "$tool_dir" ]]; then
			log_error "Unknown module: $module"
			return 1
		fi
		for t in "$tool_dir"/*/; do
			local name="${t%/}"
			name="${name##*/}"
			if [[ -f "$tool_dir/$name/README.md" ]]; then
				local first_line
				first_line=$(head -1 "$tool_dir/$name/README.md" 2>/dev/null)
				printf "    ${D_CYAN}%-16s${NC} %s\n" "$name" "${first_line#\# }"
			fi
		done
		echo
		log_info "Run ${D_CYAN}core show $module --<tool>${NC} for details"
		echo
		return
	fi

	local readme_path="$CORE_PATH/tools/$module/$tool/README.md"

	if [[ ! -f "$readme_path" ]]; then
		log_error "No documentation found for $module/$tool"
		return 1
	fi

	separator_section "$tool ($module)"

	if command -v glow &>/dev/null; then
		glow "$readme_path"
	elif command -v pygmentize &>/dev/null; then
		pygmentize -l markdown "$readme_path" 2>/dev/null | less -R
	else
		log_info "Showing documentation for $module/$tool:"
		echo
		cat "$readme_path"
	fi

	echo
	separator
	echo
}
