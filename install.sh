#!/usr/bin/env bash

# Core - multiplatform installer.
# Supported platforms: Termux/Android, Ubuntu Linux, Ubuntu (WSL).

set -e

readonly P_BORDER='\e[38;5;33m'
readonly P_PRIMARY='\e[38;5;39m'
readonly P_DIM='\e[38;5;244m'
readonly P_OK='\e[38;5;42m'
readonly P_FAIL='\e[1;31m'

REPO="${CORE_REPO:-https://github.com/DevCoreXOfficial/core-termux}"
BRANCH="${CORE_BRANCH:-main}"
INSTALL_DIR="${CORE_INSTALL_DIR:-$HOME/.core}"

TOTAL_STEPS=4
CURRENT_STEP=0

_cols() {
  if command -v tput &>/dev/null; then
    tput cols
  else
    echo 80
  fi
}

progress_bar() {
  local current=$1 total=$2 width=${3:-40}
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  printf -v bar "%*s" "$filled" ""
  bar="${bar// /█}"
  printf -v space "%*s" "$empty" ""
  space="${space// /░}"
  printf "\r  ${P_BORDER}│${P_NC}${P_OK}%s${P_NC}${P_DIM}%s${P_NC}${P_BORDER}│${P_NC} ${P_PRIMARY}%3d%%${P_NC}" "${bar}" "${space}" "$percentage"
}

log_step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  printf "\r%*s\r" "$(_cols)" ""
  echo -e "\n  ${P_BORDER}◆${P_NC}  ${P_PRIMARY}${CURRENT_STEP}/${TOTAL_STEPS}${P_NC}  $1"
}

log_ok() { echo -e "  ${P_OK}✔${P_NC}  $1"; }
log_fail() { echo -e "  ${P_FAIL}✖${P_NC}  $1" >&2; }
log_info() { echo -e "  ${P_BORDER}→${P_NC}  $1"; }

separator() {
  local line
  line=$(printf "%$(_cols)s")
  echo -e "${P_DIM}${line// /─}${P_NC}"
}

banner() {
  echo
  echo -e "  ${P_BORDER}┌─────────────────────────────────────────┐${P_NC}"
  echo -e "  ${P_BORDER}│${P_NC}       ${P_PRIMARY}         ◈ CORE ◈${P_NC}                 ${P_BORDER}│${P_NC}"
  echo -e "  ${P_BORDER}│${P_NC} ${P_DIM}One CLI — Your environment. Everywhere.${D_NC} ${P_BORDER}│${P_NC}"
  echo -e "  ${P_BORDER}└─────────────────────────────────────────┘${P_NC}"
  echo
}

# ---------------------------------------------------------------------------
# Platform detection (standalone: runs before Core exists)
# ---------------------------------------------------------------------------

detect_platform() {
  if [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == */com.termux/* ]]; then
    PLATFORM="termux"
    PKG_MGR="pkg"
  elif grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    PLATFORM="wsl"
    PKG_MGR="apt"
  else
    PLATFORM="linux"
    PKG_MGR=""
    if [[ -f /etc/os-release ]]; then
      case "$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')" in
        ubuntu) PKG_MGR="apt" ;;
      esac
    fi
  fi

  SUDO=""
  if [[ "$PLATFORM" != "termux" ]] && [[ "$(id -u)" -ne 0 ]] && command -v sudo &>/dev/null; then
    SUDO="sudo"
  fi
}

install_packages() {
  # install_packages <pkg...>
  case "$PKG_MGR" in
    pkg) yes | pkg install -y "$@" &>/dev/null ;;
    apt)
      $SUDO apt-get update -qq &>/dev/null
      $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" &>/dev/null
      ;;
    *) return 1 ;;
  esac
}

bootstrap_dependencies() {
  # Essentials: Core cannot run without these.
  local needed=()
  local dep
  for dep in git curl jq unzip tput; do
    if [[ "$dep" == tput ]]; then
      command -v tput &>/dev/null || needed+=("ncurses-utils")
    elif ! command -v "$dep" &>/dev/null; then
      needed+=("$dep")
    fi
  done

  if [[ ${#needed[@]} -gt 0 && "$PKG_MGR" != "apt" && "$PKG_MGR" != "pkg" ]]; then
    log_fail "No supported package manager found (need: ${needed[*]})"
    exit 1
  fi

  local pkg
  for dep in "${needed[@]}"; do
    pkg="$dep"
    [[ "$dep" == "ncurses-utils" && "$PKG_MGR" == "apt" ]] && pkg="ncurses-bin"
    log_info "Installing $pkg..."
    progress_bar 0 10
    install_packages "$pkg"
    progress_bar 10 10
    echo
    log_ok "$pkg installed"
  done

  # Optional docs viewers: nice-to-have, never fatal.
  # 'glow' is NOT in the default Ubuntu repositories - only try when present.
  local viewer alt
  for viewer in glow bat; do
    command -v "$viewer" &>/dev/null && continue
    case "$PKG_MGR" in
      pkg)
        yes | pkg install -y "$viewer" &>/dev/null || true
        ;;
      apt)
        apt-cache show "$viewer" >/dev/null 2>&1 || continue
        $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "$viewer" &>/dev/null || true
        ;;
    esac
    command -v "$viewer" &>/dev/null \
      && log_ok "$viewer installed (optional)" \
      || log_info "Optional viewer '$viewer' skipped (docs will render as plain text)"
  done

  return 0
}

install_core() {
  if [[ -d "$INSTALL_DIR/core/.git" ]]; then
    log_info "Existing installation found — updating..."
    git -C "$INSTALL_DIR/core" fetch origin "$BRANCH" &>/dev/null
    git -C "$INSTALL_DIR/core" reset --hard "origin/$BRANCH" &>/dev/null
  else
    mkdir -p "$INSTALL_DIR"
    git clone --depth 1 -b "$BRANCH" "$REPO.git" "$INSTALL_DIR/core" &>/dev/null
  fi
}

link_binary() {
  local target="$INSTALL_DIR/core/core/bin/core"
  chmod +x "$target"

  if [[ "$PLATFORM" == "termux" ]]; then
    ln -sf "$target" "$PREFIX/bin/core"
  else
    mkdir -p "$HOME/.local/bin"
    ln -sf "$target" "$HOME/.local/bin/core"
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) return 0 ;;
    esac

    # Add automatically to the user's shell config + inform.
    local rc="$HOME/.bashrc"
    [[ -f "$HOME/.zshrc" && ! -f "$HOME/.bashrc" ]] && rc="$HOME/.zshrc"

    if ! grep -qs 'HOME/.local/bin' "$rc"; then
      printf '\n# Added by Core installer\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$rc"
      log_ok "Added ~/.local/bin to your PATH ($rc)"
      echo -e "      ${P_DIM}Run: source $rc   (or open a new terminal)${P_NC}"
    else
      log_ok "~/.local/bin already configured in $rc — open a new terminal"
    fi

    # Available in THIS session too, so core/tools work immediately.
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

main() {
  detect_platform

  case "$PLATFORM:$PKG_MGR" in
    termux:pkg) LABEL="Termux / Android" ;;
    wsl:apt) LABEL="Ubuntu (WSL)" ;;
    linux:apt) LABEL="Ubuntu Linux" ;;
    *)
      echo
      log_fail "Unsupported platform detected."
      echo "  Supported: Termux/Android, Ubuntu Linux, Ubuntu (WSL)."
      echo
      exit 1
      ;;
  esac

  separator
  banner
  separator

  log_step "Installing dependencies ($LABEL)"
  bootstrap_dependencies
  log_ok "Dependencies ready"

  log_step "Downloading Core"
  progress_bar 0 10
  install_core
  progress_bar 10 10
  echo
  log_ok "Core downloaded to $INSTALL_DIR/core"

  log_step "Creating binary link"
  link_binary
  log_ok "'core' is available on your PATH"

  log_step "Finalizing"
  VERSION=$(grep CORE_VERSION "$INSTALL_DIR/core/core/utils/env.sh" | cut -d'"' -f2)
  separator
  echo
  echo -e "  ${P_OK}✔${P_NC} Core v$VERSION installed successfully"
  echo
  echo -e "  Run ${P_PRIMARY}core${P_NC} to get started"
  echo
  separator
}

main "$@"
