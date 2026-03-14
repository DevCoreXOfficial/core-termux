#!/bin/bash

# evitar redeclaraciones
[[ -n "${__CORE_BOOTSTRAP_LOADED:-}" ]] && return
__CORE_BOOTSTRAP_LOADED=1

# registro de imports
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
