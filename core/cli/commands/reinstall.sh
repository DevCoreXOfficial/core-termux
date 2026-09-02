#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/engine"

reinstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box_large "Core Reinstall"
    echo
    log_info "Usage: core reinstall <tool> [<tool2> ...]"
    echo
    list_item "${GRAY_19}core reinstall opencode${D_NC}"
    echo
    return
  fi

  local name dir ok=0 fail=0 unknown=0
  for name in "$@"; do
    dir="$(manifest_tool_dir "$name")"
    if [[ -z "$dir" ]]; then
      log_warn "Unknown tool: $name (run 'core search' to see everything)"
      ((unknown++))
      continue
    fi
    if engine_reinstall "$name"; then
      ((ok++))
    else
      ((fail++))
    fi
  done

  echo
  [[ $ok -gt 0 ]] && log_success "$ok tool(s) reinstalled"
  [[ $fail -gt 0 ]] && log_warn "$fail tool(s) failed"
  [[ $unknown -gt 0 ]] && log_warn "$unknown unknown target(s) skipped"
  echo
}
