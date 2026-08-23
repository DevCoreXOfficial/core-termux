#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/platform"

CORE_DOCS_URL="https://devcorex-web.vercel.app/core"

open_url() {
  local url="$1"
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url" &>/dev/null &
  elif command -v termux-open-url &>/dev/null; then
    termux-open-url "$url"
  elif command -v wslview &>/dev/null; then
    wslview "$url" &>/dev/null
  else
    log_warn "No browser opener found. Open manually:"
    list_item "$url"
    return 1
  fi
}

open_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box_large "Core Open"
    echo
    log_info "Usage: core open <target>"
    echo
    log_info "Open official documentation in browser:"
    echo
    list_item "${D_CYAN}core open${D_NC}                Core documentation"
    list_item "${D_CYAN}core open devcorex${D_NC}       DevCoreX website"
    list_item "${D_CYAN}core open devcorex${D_NC}"
    echo
    return
  fi

  local target="$1"

  case "$target" in
  core)
    open_url "$CORE_DOCS_URL"
    log_info "Opening Core documentation..."
    ;;
  devcorex)
    open_url "https://devcorex-web.vercel.app/"
    log_info "Opening DevCoreX website..."
    ;;
  *)
    log_warn "Unknown target: $target"
    echo "Run 'core open' to see available targets"
    ;;
  esac
}
