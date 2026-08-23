#!/usr/bin/env bash

# Core - Installed tools registry.
#
# The registry records which tools were installed through Core and which
# dependencies Core actually installed on their behalf. It powers
# `core search` status output and orphan dependency detection on uninstall.

[[ -n "${__CORE_REGISTRY_LOADED:-}" ]] && return
__CORE_REGISTRY_LOADED=1

CORE_REGISTRY_DIR="$CORE_DATA/registry"
CORE_REGISTRY_TOOLS="$CORE_REGISTRY_DIR/tools"

registry_init() {
  mkdir -p "$CORE_REGISTRY_TOOLS"
}

# registry_record <tool-name> [deps-installed...]
registry_record() {
  local name="$1"
  shift
  registry_init
  {
    echo "installed_at=$(date +%s)"
    echo "deps_installed=${*:-}"
  } >"$CORE_REGISTRY_TOOLS/$name.conf"
}

# registry_remove <tool-name>
registry_remove() {
  rm -f "$CORE_REGISTRY_TOOLS/$1.conf" 2>/dev/null
}

# registry_is_installed <tool-name> : 0 when Core recorded an install.
registry_is_installed() {
  [[ -f "$CORE_REGISTRY_TOOLS/$1.conf" ]]
}

# registry_deps_installed_by_core <tool-name> : prints dep names, one per line.
registry_deps_installed_by_core() {
  local conf="$CORE_REGISTRY_TOOLS/$1.conf"
  [[ -f "$conf" ]] && grep '^deps_installed=' "$conf" | cut -d= -f2- | tr ' ' '\n' | grep -v '^$'
}

# registry_list : prints every registered tool name.
registry_list() {
  local conf name
  for conf in "$CORE_REGISTRY_TOOLS"/*.conf; do
    [[ -e "$conf" ]] || continue
    basename "$conf" .conf
  done
}

# ---------------------------------------------------------------------------
# Orphan dependency detection
#
# A dependency is orphaned when no other installed tool (per its manifest)
# still requires it. Shared dependencies are never removed automatically.
# ---------------------------------------------------------------------------

# deps_other_tools_using <dep-name> [<exclude-tool>] : prints tool names.
deps_other_tools_using() {
  local dep="$1" exclude="${2:-}"
  local tool_dir tool_name check
  for tool_dir in "$CORE_PATH/tools/"*/; do
    [[ -f "$tool_dir/manifest.json" ]] || continue
    tool_name="$(basename "$tool_dir")"
    [[ "$tool_name" == "$exclude" ]] && continue
    # Only consider tools that are actually present on the system.
    check="$(manifest_check_cmd "$tool_dir")"
    if [[ -n "$check" ]]; then
      command -v "$check" &>/dev/null || continue
    else
      registry_is_installed "$tool_name" || continue
    fi
    while IFS='|' read -r dname _rest; do
      [[ "$dname" == "$dep" ]] && echo "$tool_name"
    done < <(manifest_deps "$tool_dir")
  done
}

# deps_orphans <tool-dir> [<exclude-tool>] : dependencies that can be safely
# offered for removal after uninstalling the given tool.
deps_orphans() {
  local dir="$1" exclude="${2:-$1}"
  local line dep check
  while IFS='|' read -r dep check _pkg_t _pkg_a; do
    [[ -z "$dep" ]] && continue
    if [[ -n "$check" ]] && ! command -v "$check" &>/dev/null; then
      continue # dependency is not even present anymore
    fi
    if [[ -z "$(deps_other_tools_using "$dep" "$(basename "$exclude")")" ]]; then
      echo "$dep|$check|$_pkg_t|$_pkg_a"
    fi
  done < <(manifest_deps "$dir")
}
