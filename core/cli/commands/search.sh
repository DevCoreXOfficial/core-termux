#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/manifest"
import "@/lib/registry"

# core search            -> every tool with install status
# core search <text>     -> filter by substring on tool name / description
search_main() {
  local query="${*,,}"

  local -a rows=()
  local tool_dir tool check installed desc

  for tool_dir in "$CORE_PATH/tools/"*/; do
    [[ -f "$tool_dir/manifest.json" ]] || continue
    tool="$(basename "$tool_dir")"
    check="$(manifest_check_cmd "$tool_dir")"
    if [[ -n "$check" ]] && command -v "$check" &>/dev/null; then
      installed="installed"
    elif registry_is_installed "$tool"; then
      installed="installed"
    else
      installed="not installed"
    fi

    if [[ -n "$query" ]]; then
      desc="$(manifest_description "$tool_dir")"
      local tags
      tags="$(manifest_field "$tool_dir" '.tags // [] | join(" ")' "")"
      local hay="${tool,,} ${desc,,} ${tags,,}"
      if [[ "$hay" != *"$query"* ]]; then
        continue
      fi
    fi

    rows+=("${tool}|${installed}")
  done

  if [[ ${#rows[@]} -eq 0 ]]; then
    log_warn "No tools match '${query}'"
    list_item "Run ${D_CYAN}core search${D_NC} to see everything"
    return 1
  fi

  echo
  if [[ -n "$query" ]]; then
    box "Core Search — matching '${query}' (${#rows[@]})"
  else
    box "Core Search — ${#rows[@]} tools"
  fi
  echo

  table_start "Tool" "Install Command" "Status"

  local row sorted
  while IFS= read -r sorted; do
    IFS='|' read -r tool installed <<<"$sorted"
    table_row "$tool" "core install $tool" "$installed"
  done < <(printf '%s\n' "${rows[@]}" | sort)

  table_end
  echo
  list_item "Install: ${D_CYAN}core install <tool>${D_NC}   Docs: ${D_CYAN}core show <tool>${D_NC} or ${D_CYAN}core about <tool>${D_NC}"
  echo
}
