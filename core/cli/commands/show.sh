#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/manifest"

# Resolve a documentation file for a tool.
#   _show_doc_path <tool-dir> [lang]  -> echoes the best matching doc path.
_show_doc_path() {
  local dir="$1" lang="${2:-en}"
  local candidates=(
    "$dir/docs/$lang.md"
    "$dir/docs/en.md" # English is the default and the fallback
    "$dir/README.md"  # legacy location kept for compatibility
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    [[ -f "$candidate" ]] && {
      echo "$candidate"
      return 0
    }
  done
  return 1
}

_show_doc_for_tool() {
  local name="$1" lang="$2"
  local dir doc_path label

  dir="$(manifest_tool_dir "$name")"
  if [[ -z "$dir" ]]; then
    log_error "Unknown tool: $name"
    echo "Run 'core search' to see available tools"
    return 1
  fi

  doc_path="$(_show_doc_path "$dir" "$lang")"
  if [[ -z "$doc_path" ]]; then
    log_error "No documentation found for $name"
    return 1
  fi

  if [[ "$lang" == "es" && "$doc_path" == *"/en.md" ]]; then
    log_warn "Spanish documentation not available yet for $name — showing English"
    echo
  fi

  separator_section "$(manifest_display "$dir") ($name)"

  if command -v glow &>/dev/null; then
    glow "$doc_path"
  elif command -v bat &>/dev/null; then
    bat --language=markdown --paging=always "$doc_path"
  else
    cat "$doc_path"
  fi

  echo
  separator
  echo
}

show_main() {
  if [[ $# -eq 0 ]]; then
    echo
    box "Core Show / About"
    echo
    log_info "Usage: core show <tool>"
    log_info "Usage: core show <tool>:es        (Spanish documentation)"
    echo
    log_info "'about' is an alias of 'show': both display tool documentation."
    echo
    list_item "${D_CYAN}core show opencode${D_NC}"
    list_item "${D_CYAN}core about opencode:es${D_NC}"
    echo
    log_info "Run ${D_CYAN}core search${D_NC} to see all available tools"
    echo
    return
  fi

  local arg="$1" lang="en"

  # Language suffix support: tool:es
  if [[ "$arg" == *:* ]]; then
    lang="${arg##*:}"
    arg="${arg%%:*}"
  fi

  _show_doc_for_tool "$arg" "$lang"
}
