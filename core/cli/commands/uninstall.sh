#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/engine"

uninstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box_large "Core Uninstall"
    echo
    log_info "Usage: core uninstall <tool> [<tool2> ...]"
    echo
    list_item "${GRAY_19}core uninstall opencode${D_NC}"
    echo
    log_info "After each uninstall Core offers removal of orphaned exclusive"
    log_info "dependencies (never shared ones)."
    echo
    log_info "Browse installed tools: ${GRAY_19}core search${D_NC}"
    echo
    log_warn "Warning: This will remove installed packages and configurations!"
    echo
    return
  fi

  local -a names=()
  local arg

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      names+=("${arg#--}")
    else
      names+=("$arg")
    fi
  done

  local name dir ok_count=0 fail_count=0 unknown_count=0

  for name in "${names[@]}"; do
    dir="$(manifest_tool_dir "$name")"

    if [[ -n "$dir" && "$(manifest_field "$dir" '.style // false')" == "true" ]]; then
      log_warn "'$name' is a style — remove it with: ${GRAY_19}core style -r $name${D_NC}"
      ((unknown_count++))
      continue
    fi

    if [[ -z "$dir" ]]; then
      log_warn "Unknown tool: $name (run 'core search' to see everything)"
      ((unknown_count++))
      continue
    fi

    if engine_uninstall "$name"; then
      ((ok_count++))
    else
      ((fail_count++))
    fi
  done

  echo
  if [[ $ok_count -gt 0 ]]; then
    log_success "$ok_count tool(s) uninstalled"
  fi
  if [[ $fail_count -gt 0 ]]; then
    log_warn "$fail_count tool(s) failed to uninstall"
  fi
  if [[ $unknown_count -gt 0 ]]; then
    log_warn "$unknown_count unknown target(s) skipped"
  fi
  echo
}
