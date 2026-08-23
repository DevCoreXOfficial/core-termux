#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/manifest"
import "@/lib/registry"

# core search              -> help for this command
# core search --all | -a   -> every tool with install status
# core search <text>       -> filter by name / description / tags
search_main() {
  local -a args=()
  local arg all=0

  for arg in "$@"; do
    case "$arg" in
      --all | -a) all=1 ;;
      *) args+=("$arg") ;;
    esac
  done

  # Bare invocation: show the search help.
  if [[ ${#args[@]} -eq 0 && $all -eq 0 ]]; then
    echo
    box_large "Core Search"
    echo
    log_info "Usage: core search <text>     filter tools by keyword"
    log_info "Usage: core search --all      list every tool with status"
    echo
    log_info "Searches match tool names, descriptions and tags:"
    echo
    list_item "${D_CYAN}core search tunnel${D_NC}     ngrok, cloudflared, localtunnel..."
    list_item "${D_CYAN}core search ai${D_NC}         AI agents & coding assistants"
    list_item "${D_CYAN}core search js${D_NC}         JavaScript/TypeScript ecosystem"
    echo
    list_item "Install: ${D_CYAN}core install <tool>${D_NC}   Docs: ${D_CYAN}core show <tool>${D_NC}"
    echo
    return
  fi

  local query=""
  if [[ $all -eq 0 ]]; then
    query="${*,,}"
  fi

  local -a rows=()
  local tool_dir tool display check installed desc tags

  for tool_dir in "$CORE_PATH/tools/"*/; do
    [[ -f "$tool_dir/manifest.json" ]] || continue
    # Style tools live under `core style`, not the tool catalog.
    [[ "$(manifest_field "$tool_dir" '.style // false')" == "true" ]] && continue
    tool="$(basename "$tool_dir")"
    display="$(manifest_display "$tool_dir")"
    if manifest_is_installed "$tool_dir"; then
      installed="installed"
    elif registry_is_installed "$tool"; then
      installed="installed"
    else
      installed="not installed"
    fi

    if [[ -n "$query" ]]; then
      desc="$(manifest_description "$tool_dir")"
      tags="$(manifest_field "$tool_dir" '.tags // [] | join(" ")' "")"
      local hay="${tool,,} ${display,,} ${desc,,} ${tags,,}"
      if [[ "$hay" != *"$query"* ]]; then
        continue
      fi
    fi

    rows+=("${tool}|${display}|${installed}")
  done

  if [[ ${#rows[@]} -eq 0 ]]; then
    log_warn "No tools match '${query}'"
    list_item "Run ${D_CYAN}core search --all${D_NC} to see everything"
    return 1
  fi

  echo
  if [[ $all -eq 1 ]]; then
    box_large "Core Tools — ${#rows[@]}"
  else
    box_large "Core Search — '${query}' (${#rows[@]})"
  fi
  echo

  table_start "Name" "Tool" "Status"

  local sorted
  while IFS= read -r sorted; do
    IFS='|' read -r tool display installed <<<"$sorted"
    if [[ "$installed" == "installed" ]]; then
      table_row "$display" "$tool" "${D_GREEN}installed${NC}"
    else
      table_row "$display" "$tool" "${D_RED}not installed${NC}"
    fi
  done < <(printf '%s\n' "${rows[@]}" | sort -t'|' -k2)

  table_end
  echo
  list_item "Install: ${D_CYAN}core install <tool>${D_NC}   Docs: ${D_CYAN}core show <tool>${D_NC}"
  echo
}
