#!/usr/bin/env bash
# Installed = nvim binary + the Core-vendored NvChad config in ~/.config/nvim
command -v nvim >/dev/null 2>&1 || exit 1
[[ -f "$HOME/.config/nvim/lua/chadrc.lua" || -f "$HOME/.config/nvim/lua/custom/chadrc.lua" ]] || exit 1
exit 0
