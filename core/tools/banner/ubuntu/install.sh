#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL).
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_appearance.log}"
MARKER="# ===== Core Banner ====="

_detect_shell_config() {
  if [[ -f "$HOME/.zshrc" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  fi
}

case "${1:-install}" in
  install)
    RC="$(_detect_shell_config)"
    if [[ -z "$RC" ]]; then
      log_error "No shell config file found (.zshrc or .bashrc)"
      exit 1
    fi
    BANNER_SCRIPT="$CORE_PATH/utils/banner.sh"
    [[ -f "$BANNER_SCRIPT" ]] || { log_error "Banner script not found"; exit 1; }

    grep -qE -F -e "$MARKER" -e '# ===== Core-Termux Banner =====' "$RC" && { log_info "Core Banner already installed"; exit 0; }

    separator
    box_large "Installing Banner"
    separator
    echo

    mkdir -p "$(dirname "$LOG_FILE")"

    # Insert before p10k instant prompt (if present) to avoid its warning.
    P10K_MARKER="# Enable Powerlevel10k instant prompt."
    if grep -qF "$P10K_MARKER" "$RC"; then
      TMP="$RC.core_tmp"
      awk -v p10k="$P10K_MARKER" -v marker="$MARKER" -v script="$BANNER_SCRIPT" \
        '!inserted && index($0, p10k) == 1 {
           print marker
           print "source \"" script "\""
           inserted = 1
         }
         { print }' "$RC" >"$TMP" && mv "$TMP" "$RC"
    else
      cat >>"$RC" <<EOF

$MARKER
source "$BANNER_SCRIPT"
EOF
    fi
    log_success "Core Banner installed ($RC)"
    log_info "Run: source $RC to see it now"
    ;;
  update)
    RC="$(_detect_shell_config)"
    if [[ -z "$RC" ]]; then
      log_error "No shell config file found (.zshrc or .bashrc)"
      exit 1
    fi
    BANNER_SCRIPT="$CORE_PATH/utils/banner.sh"
    [[ -f "$BANNER_SCRIPT" ]] || { log_error "Banner script not found"; exit 1; }

    grep -qE -F -e "$MARKER" -e '# ===== Core-Termux Banner =====' "$RC" && { log_info "Core Banner already installed"; exit 0; }

    separator
    box_large "Installing Banner"
    separator
    echo

    mkdir -p "$(dirname "$LOG_FILE")"

    # Insert before p10k instant prompt (if present) to avoid its warning.
    P10K_MARKER="# Enable Powerlevel10k instant prompt."
    if grep -qF "$P10K_MARKER" "$RC"; then
      TMP="$RC.core_tmp"
      awk -v p10k="$P10K_MARKER" -v marker="$MARKER" -v script="$BANNER_SCRIPT" \
        '!inserted && index($0, p10k) == 1 {
           print marker
           print "source \"" script "\""
           inserted = 1
         }
         { print }' "$RC" >"$TMP" && mv "$TMP" "$RC"
    else
      cat >>"$RC" <<EOF

$MARKER
source "$BANNER_SCRIPT"
EOF
    fi
    log_success "Core Banner installed ($RC)"
    log_info "Run: source $RC to see it now"
    ;;
  uninstall)
    RC="$(_detect_shell_config)"
    [[ -z "$RC" ]] && exit 0

    separator
    box_large "Uninstalling Banner"
    separator
    echo

    if grep -qE -F -e "$MARKER" -e '# ===== Core-Termux Banner =====' "$RC"; then
      sed -i "/^$MARKER\$/d; /# ===== Core-Termux Banner =====/d; /utils\/banner.sh/d; /^source \"\$CORE_PATH\/utils\/banner.sh\"\$/d; /^source \"\/.*\/utils\/banner.sh\"\$/d" "$RC"
      log_success "Core Banner removed"
    else
      log_info "Core Banner not configured"
    fi
    ;;
  *) exit 0 ;;
esac
