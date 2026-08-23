#!/usr/bin/env bash

CORE_VERSION="5.0.0"

# -------------------------
# User directories
#
# Named after the project ("core"). Legacy core-termux directories are
# migrated once so existing Termux installations keep their data.
# -------------------------

CORE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/core"
CORE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/core"
CORE_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/core-data"

_core_migrate_legacy_dir() {
  # _core_migrate_legacy_dir <legacy> <current>
  # Moves legacy core-termux directories to their Core equivalents and leaves
  # a symlink behind so binaries compiled against the old absolute paths
  # (e.g. the bun shim) keep working.
  local legacy="$1" current="$2"
  [[ -d "$legacy" ]] || return 0
  [[ -e "$current" ]] && return 0
  if mv "$legacy" "$current" 2>/dev/null; then
    ln -s "$current" "$legacy" 2>/dev/null || true
  fi
}

if [[ ! -e "$CORE_DATA" && -d "${XDG_DATA_HOME:-$HOME/.local/share}/core-data" ]]; then
  _core_migrate_legacy_dir "${XDG_DATA_HOME:-$HOME/.local/share}/core-data" "$CORE_DATA"
fi
if [[ ! -e "$CORE_CACHE" && -d "${XDG_CACHE_HOME:-$HOME/.cache}/core" ]]; then
  _core_migrate_legacy_dir "${XDG_CACHE_HOME:-$HOME/.cache}/core" "$CORE_CACHE"
fi
if [[ ! -e "$CORE_CONFIG" && -d "${XDG_CONFIG_HOME:-$HOME/.config}/core-termux" ]]; then
  _core_migrate_legacy_dir "${XDG_CONFIG_HOME:-$HOME/.config}/core-termux" "$CORE_CONFIG"
fi

# -------------------------
# Internal CLI paths
# -------------------------

CORE_BIN="$CORE_PATH/bin"
CORE_LIB="$CORE_PATH/lib"
CORE_UTILS="$CORE_PATH/utils"
CORE_CLI="$CORE_PATH/cli"

# -------------------------
# Create directories
# -------------------------

mkdir -p \
  "$CORE_CONFIG" \
  "$CORE_CACHE" \
  "$CORE_DATA"
