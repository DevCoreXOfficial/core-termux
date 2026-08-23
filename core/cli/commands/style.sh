#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/platform"
import "@/lib/engine"

core_detect_platform

# Markers accepted as "applied" — includes the legacy Core-Termux ones so
# v4 installations are recognized without re-applying.
BANNER_MARKERS=("# ===== Core Banner =====" "# ===== Core-Termux Banner =====")
CURSOR_RC_MARKER="# ===== Core Cursor ====="

# Tools that configure the environment instead of installing software.
STYLE_TOOLS=(font banner cursor-color extra-keys)

# style_is_applied <tool> : 0 when the configuration is present on disk.
style_is_applied() {
  local tool="$1"
  case "$tool" in
    font)
      [[ -f "$HOME/.termux/font.ttf" || -f "$HOME/.local/share/fonts/MesloNerdFont.ttf" ]]
      ;;
    banner)
      local rc="$HOME/.zshrc"; [[ -f "$rc" ]] || rc="$HOME/.bashrc"
      [[ -f "$rc" ]] || return 1
      local m
      for m in "${BANNER_MARKERS[@]}"; do
        grep -qF "$m" "$rc" && return 0
      done
      return 1
      ;;
    cursor-color)
      # Termux: colors.properties written by the v4/v5 installer.
      if [[ -f "$HOME/.termux/colors.properties" ]] &&
         grep -qi "^cursor=" "$HOME/.termux/colors.properties"; then
        return 0
      fi
      # Ubuntu/WSL: OSC marker in the rc file.
      local rc="$HOME/.zshrc"; [[ -f "$rc" ]] || rc="$HOME/.bashrc"
      [[ -f "$rc" ]] && grep -qF "$CURSOR_RC_MARKER" "$rc"
      ;;
    extra-keys)
      [[ -f "$HOME/.termux/termux.properties" ]] &&
        grep -qi "extra-keys" "$HOME/.termux/termux.properties"
      ;;
    *) return 1 ;;
  esac
}

style_main() {
  local action="apply"
  local -a tools=()
  local arg

  for arg in "$@"; do
    case "$arg" in
      --remove | -r) action="remove" ;;
      --help | -h) action="help" ;;
      *) tools+=("$arg") ;;
    esac
  done

  if [[ ${#tools[@]} -eq 0 && "$action" != "help" ]]; then
    action="list"
  fi

  case "$action" in
    help | list)
      echo
      box_large "Core Style"
      echo
      log_info "Configure your terminal environment — apply or remove anytime."
      echo
      separator_section "Available Styles"
      echo
      table_start "Name" "Style" "Status"
      local t status
      for t in "${STYLE_TOOLS[@]}"; do
        if style_is_applied "$t"; then
          status="${D_GREEN}applied${NC}"
        else
          status="${D_RED}not applied${NC}"
        fi
        table_row "$(manifest_display "$CORE_PATH/tools/$t" 2>/dev/null || echo "$t")" "$t" "$status"
      done
      table_end
      echo
      separator_section "Usage"
      echo
      list_item "${D_CYAN}core style <style>${D_NC}             apply — e.g. ${D_CYAN}core style font${D_NC}"
      list_item "${D_CYAN}core style --remove <style>${D_NC}    remove — e.g. ${D_CYAN}core style -r font${D_NC}"
      echo
      list_item "These are environment tweaks, not packages: nothing to update."
      echo
      return
      ;;
  esac

  local t dir ok=0 fail=0 unknown=0

  for t in "${tools[@]}"; do
    # Validate it is a known style tool.
    local known=0
    for s in "${STYLE_TOOLS[@]}"; do
      [[ "$s" == "$t" ]] && known=1
    done
    if [[ $known -eq 0 ]]; then
      dir="$(manifest_tool_dir "$t")"
      if [[ -n "$dir" ]] && [[ "$(manifest_field "$dir" '.style // false')" != "true" ]]; then
        log_warn "'$t' is a regular tool — use ${D_CYAN}core install $t${D_NC}"
      else
        log_warn "Unknown style: $t"
      fi
      ((unknown++))
      continue
    fi

    dir="$(manifest_tool_dir "$t")"

    if [[ "$action" == "apply" ]]; then
      if style_is_applied "$t"; then
        log_info "$(manifest_display "$dir") is already applied"
        continue
      fi
      if engine_install "$t"; then
        ((ok++))
      else
        ((fail++))
      fi
    else
      if ! style_is_applied "$t"; then
        log_info "$(manifest_display "$dir") is not applied"
        continue
      fi
      if engine_uninstall "$t"; then
        ((ok++))
      else
        ((fail++))
      fi
    fi
  done

  echo
  if [[ $ok -gt 0 ]]; then
    [[ "$action" == "apply" ]] && log_success "$ok style(s) applied" || log_success "$ok style(s) removed"
  fi
  if [[ $fail -gt 0 ]]; then
    log_warn "$fail style(s) failed"
  fi
  echo
}
