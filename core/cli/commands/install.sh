#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/engine"

install_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box_large "Core Install"
    echo
    log_info "Usage: core install <tool>"
    log_info "Usage: core install <tool1> <tool2> ..."
    echo
    log_info "Every tool installs individually and is located by name:"
    echo
    list_item "${GRAY_19}core install opencode${D_NC}"
    list_item "${GRAY_19}core install nvchad${D_NC}            editor + NvChad in one shot"
    list_item "${GRAY_19}core install oh-my-zsh${D_NC}               shell + Oh My Zsh + 10 plugins"
    echo
    log_info "Discover tools by keyword (name, description or tags):"
    echo
    list_item "${GRAY_19}core search${D_NC}                    everything, with install status"
    list_item "${GRAY_19}core search tunnel${D_NC}             filtered by keyword"
    echo
    return
  fi

  # Flags mode: --tool flags resolved globally by name.
  local -a names=()
  local arg

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      names+=("${arg#--}")
    else
      names+=("$arg")
    fi
  done

  local name dir installed_count=0 failed_count=0 unknown_count=0

  for name in "${names[@]}"; do
    dir="$(manifest_tool_dir "$name")"

    if [[ -n "$dir" && "$(manifest_field "$dir" '.style // false')" == "true" ]]; then
      log_warn "'$name' is a style — apply it with: ${GRAY_19}core style $name${D_NC}"
      ((unknown_count++))
      continue
    fi

    if [[ -z "$dir" ]]; then
      log_warn "Unknown tool: $name (run 'core search' to see everything)"
      ((unknown_count++))
      continue
    fi

    if engine_install "$name"; then
      ((installed_count++))
    else
      ((failed_count++))
    fi
  done

  echo
  if [[ $installed_count -gt 0 ]]; then
    log_success "$installed_count tool(s) installed"
  fi
  if [[ $failed_count -gt 0 ]]; then
    log_warn "$failed_count tool(s) failed to install"
  fi
  if [[ $unknown_count -gt 0 ]]; then
    log_warn "$unknown_count unknown target(s) skipped"
  fi
  echo
}
