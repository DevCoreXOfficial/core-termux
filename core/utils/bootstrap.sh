#!/usr/bin/env bash

# Core - Bootstrap. Defines the import mechanism used by every module.
# Kept tiny and dependency-free so it can run on any supported platform.

# avoid redeclaration
[[ -n "${__CORE_BOOTSTRAP_LOADED:-}" ]] && return
__CORE_BOOTSTRAP_LOADED=1

# import registry
declare -A __CORE_IMPORTED

import() {
  local path="${1//@/$CORE_PATH}.sh"

  if [[ -n "${__CORE_IMPORTED[$path]}" ]]; then
    return
  fi

  if [[ ! -f "$path" ]]; then
    echo "core: import error: $path not found" >&2
    exit 1
  fi

  __CORE_IMPORTED[$path]=1
  source "$path"
}
