#!/usr/bin/env bash

CORE_VERSION="3.7.4"

# -------------------------
# Directorios del usuario
# -------------------------

# configuración
CORE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/core-termux"

# cache
CORE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/core-termux"

# datos del usuario
CORE_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/core-termux-data"

# -------------------------
# Rutas internas del CLI
# -------------------------

CORE_BIN="$CORE_PATH/bin"
CORE_MODULES="$CORE_PATH/modules"
CORE_UTILS="$CORE_PATH/utils"
CORE_CLI="$CORE_PATH/cli"

# -------------------------
# Crear directorios
# -------------------------

mkdir -p \
  "$CORE_CONFIG" \
  "$CORE_CACHE" \
  "$CORE_DATA"
