#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/engine"
import "@/lib/manifest"

update_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box_large "Core Update"
    echo
    log_info "Usage: core update <tool> [tool2] [tool3] ..."
    log_info "Usage: core update core                (update the framework itself)"
    echo
    log_info "Update flow: local version → remote version → compare → suggest update."
    echo
    list_item "${GRAY_19}core update opencode${D_NC}           found by name automatically"
    list_item "${GRAY_19}core update opencode cline kilocode${D_NC}   multiple tools"
    echo
    return
  fi

  local rc=0
  for target in "$@"; do
    # Framework self-update.
    if [[ "$target" == "core" ]]; then
      separator
      box_large "Updating Core"
      separator
      echo
      if [[ -d "$CORE_PATH/.git" ]]; then
        loading "Pulling latest version" git -C "$CORE_PATH" pull --ff-only
        if [[ $? -eq 0 ]]; then
          log_success "Core updated to $(grep CORE_VERSION "$CORE_PATH/utils/env.sh" | cut -d'"' -f2)"
          list_item "Restart your shell to apply the new version"
        else
          log_error "Failed to update Core (see output above)"
          rc=1
        fi
      else
        log_warn "Core was not installed via git — reinstall to update:"
        list_item "${GRAY_19}curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core/main/install.sh | bash${D_NC}"
      fi
      echo
      continue
    fi

    local dir
    dir="$(manifest_tool_dir "$target")"

    if [[ -n "$dir" ]]; then
      engine_update "$target" || rc=1
      continue
    fi

    log_warn "Unknown tool: $target (run 'core search' to see everything)"
    rc=1
  done

  return $rc
}
