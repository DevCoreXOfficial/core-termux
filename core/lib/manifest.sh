#!/usr/bin/env bash

# Core - Tool manifest system.
#
# Every tool lives flat in $CORE_PATH/tools/<tool>/ and declares itself
# through a manifest.json. The engine reads manifests instead of hard-coded
# case statements, so adding a tool means adding one directory.

[[ -n "${__CORE_MANIFEST_LOADED:-}" ]] && return
__CORE_MANIFEST_LOADED=1

# manifest_tool_dir <tool-name> : prints the directory of a tool.
# Tools live flat in $CORE_PATH/tools/<tool>/. Echoes nothing (and returns 1)
# when the tool does not exist.
manifest_tool_dir() {
  local name="$1"
  local dir="$CORE_PATH/tools/$name"
  [[ -f "$dir/manifest.json" ]] && echo "$dir" && return 0
  return 1
}

# manifest_read <tool-dir> : echoes raw manifest JSON.
manifest_read() {
  local dir="$1"
  [[ -f "$dir/manifest.json" ]] && cat "$dir/manifest.json"
}

# manifest_field <tool-dir> <jq-filter> [default]
manifest_field() {
  local dir="$1" filter="$2" default="${3:-}"
  local out
  out=$(jq -r "$filter // empty" "$dir/manifest.json" 2>/dev/null)
  if [[ -z "$out" || "$out" == "null" ]]; then
    echo "$default"
  else
    echo "$out"
  fi
}

# manifest shortcuts
manifest_name() { manifest_field "$1" '.name' "$(basename "$1")"; }
manifest_display() { manifest_field "$1" '.display' "$(basename "$1")"; }
manifest_description() { manifest_field "$1" '.description // .summary // ""'; }
manifest_homepage() { manifest_field "$1" '.homepage // ""'; }
manifest_check_cmd() { manifest_field "$1" '.check_cmd // ""'; }

# manifest_check_list <tool-dir> : prints every accepted binary (one per line).
# Accepts both forms:
#   "check_cmd": "sqlite3"
#   "check_cmd": ["mongosh", "mongod"]
# A tool is considered installed when ANY of them is present on PATH.
manifest_check_list() {
  jq -r 'if (.check_cmd | type) == "array" then .check_cmd[] else .check_cmd end' \
    "$1/manifest.json" 2>/dev/null | grep -v '^$'
}

# manifest_is_installed <tool-dir> : 0 when any check binary is present.
manifest_is_installed() {
  local bin
  while IFS= read -r bin; do
    [[ -z "$bin" ]] && continue
    command -v "$bin" &>/dev/null && return 0
  done < <(manifest_check_list "$1")
  return 1
}

# manifest_supports_platform <tool-dir> : 0 when current platform is declared.
manifest_supports_platform() {
  local dir="$1"
  local platforms
  platforms=$(manifest_field "$dir" '.platforms // []' "")
  [[ -z "$platforms" ]] && return 0 # no restriction declared
  local p
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if platform_matches "$p"; then
      return 0
    fi
  done < <(echo "$platforms" | tr -d ',"' | tr ' ' '\n')
  return 1
}

# manifest_deps <tool-dir> : prints one dependency per line as
#   "<dep-name>|<check-cmd>|<pkg-termux>|<pkg-apt>"
manifest_deps() {
  local dir="$1"
  jq -r '
    (.dependencies // [])[] |
    [
      .name,
      (.check // ""),
      (.pkg.termux // .pkg.pkg // ""),
      (.pkg.apt // .pkg.ubuntu // "")
    ] | @tsv
  ' "$dir/manifest.json" 2>/dev/null |
    while IFS=$'\t' read -r name check pkg_termux pkg_apt; do
      echo "${name}|${check}|${pkg_termux}|${pkg_apt}"
    done
}

# manifest_dep_names <tool-dir> : one dependency name per line.
manifest_dep_names() {
  jq -r '(.dependencies // [])[]?.name' "$1/manifest.json" 2>/dev/null
}

# manifest_has_uninstall <tool-dir> : 0 when the platform script handles uninstall.
manifest_has_uninstall() {
  grep -qE '"uninstall"[[:space:]]*:[[:space:]]*true' "$1/manifest.json" 2>/dev/null
}
