#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_appearance.log}"
FONT_DIR="$HOME/.local/share/fonts"

_wsl_windows_font() {
  # WSL renders with WINDOWS fonts, not the Linux filesystem. Best-effort:
  # copy the TTF into the Windows user Fonts folder and register it.
  local win_user win_fonts
  win_user=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
  [[ -z "$win_user" ]] && return 1
  win_fonts="/mnt/c/Users/${win_user}/AppData/Local/Microsoft/Windows/Fonts"
  mkdir -p "$win_fonts" 2>/dev/null || return 1
  cp "$1" "$win_fonts/MesloNerdFont.ttf" 2>/dev/null || return 1
  /mnt/c/Windows/System32/reg.exe add \
    "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts" \
    /v "Meslo Nerd Font (TrueType)" /t REG_SZ \
    /d "C:\\Users\\${win_user}\\AppData\\Local\\Microsoft\\Windows\\Fonts\\MesloNerdFont.ttf" \
    /f &>/dev/null || true
  echo "$win_user"
}

case "${1:-install}" in
  install)
    mkdir -p "$FONT_DIR" "$(dirname "$LOG_FILE")"
    FONT_SRC="$(dirname "$CORE_PATH")/assets/fonts/font.ttf"
    if [[ ! -f "$FONT_SRC" ]]; then
      log_error "Font file not found: $FONT_SRC"
      exit 1
    fi
    cp "$FONT_SRC" "$FONT_DIR/MesloNerdFont.ttf"
    command -v fc-cache >/dev/null 2>&1 || pm_install fontconfig
    fc-cache -f "$FONT_DIR" &>>"$LOG_FILE"

    if [[ "$CORE_ENV" == "wsl" ]]; then
      if WIN_USER="$(_wsl_windows_font "$FONT_DIR/MesloNerdFont.ttf")"; then
        log_success "Meslo Nerd Font installed (Windows user fonts + WSL)"
        list_item "Select 'Meslo Nerd Font' in Windows Terminal > Settings > Appearance"
        list_item "If it does not appear yet, sign out/in of Windows once"
      else
        log_success "Meslo Nerd Font installed in WSL (~/.local/share/fonts)"
        log_warn "Windows Terminal uses WINDOWS fonts - finish manually:"
        list_item "Open \\\\wsl$ and copy ~/.local/share/fonts/MesloNerdFont.ttf"
        list_item "Then: right-click the .ttf > Install (or Windows Settings > Fonts)"
      fi
    else
      log_success "Meslo Nerd Font installed (~/.local/share/fonts)"
      log_info "Select it in your terminal emulator settings"
    fi
    ;;
  update)
    mkdir -p "$FONT_DIR" "$(dirname "$LOG_FILE")"
    FONT_SRC="$(dirname "$CORE_PATH")/assets/fonts/font.ttf"
    if [[ ! -f "$FONT_SRC" ]]; then
      log_error "Font file not found: $FONT_SRC"
      exit 1
    fi
    cp "$FONT_SRC" "$FONT_DIR/MesloNerdFont.ttf"
    command -v fc-cache >/dev/null 2>&1 || pm_install fontconfig
    fc-cache -f "$FONT_DIR" &>>"$LOG_FILE"
    log_success "Meslo Nerd Font installed (~/.local/share/fonts)"
    log_info "Select it in your terminal emulator settings"
    ;;
  uninstall)
    rm -f "$FONT_DIR/MesloNerdFont.ttf"
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONT_DIR" &>/dev/null
    log_success "Font removed"
    ;;
  *) exit 0 ;;
esac
