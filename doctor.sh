#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

CONFIG_FILE="${HOME}/.core-termux/config"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
else
  # shellcheck disable=SC1091
  source "${ROOT_DIR}/config"
fi

: "${GREEN:=\e[1;32m}" "${CYAN:=\e[1;36m}" "${YELLOW:=\e[1;33m}" "${RED:=\e[1;31m}" "${WHITE:=\e[1;37m}" "${D_CYAN:=\e[0;36m}"

say() { echo -e "$*"; }

ok() { say "${GREEN}✓${WHITE} $*"; }
warn() { say "${YELLOW}!${WHITE} $*"; }
bad() { say "${RED}✗${WHITE} $*"; }

have() { command -v "$1" >/dev/null 2>&1; }

fix_pkg() {
  local pkg="$1"
  warn "Installing missing package: ${pkg}"
  yes | pkg install "${pkg}"
}

fix_npm() {
  local module="$1"
  warn "Installing missing npm module: ${module}"
  npm install -g "${module}"
}

say "${CYAN}Core-Termux Doctor${WHITE}"
say "${D_CYAN}Checking system and common issues...${WHITE}"
echo

# Termux basics
if [[ -n "${PREFIX:-}" && "${PREFIX}" == *"/com.termux/"* ]]; then
  ok "Running inside Termux"
else
  warn "Not detected as Termux environment (PREFIX=${PREFIX:-unset})"
fi

# storage permission (optional)
if [[ -d "${HOME}/storage" ]]; then
  ok "Termux storage seems set up (~/storage)"
else
  warn "Storage not set up (optional). Run: termux-setup-storage"
fi

# required commands
required_pkgs=(git zsh node npm curl wget python perl)
for c in "${required_pkgs[@]}"; do
  if have "${c}"; then
    ok "Command available: ${c}"
  else
    bad "Missing command: ${c}"
  fi
done

echo
say "${D_CYAN}Quick fixes:${WHITE}"
echo "  1) Install missing Termux packages"
echo "  2) Install missing npm modules (common)"
echo "  3) Repair Termux properties (extra-keys/cursor)"
echo "  0) Skip"
read -r -p "Choose a fix option: " fixopt

case "${fixopt}" in
  1)
    # attempt to install common packages if missing
    for c in "${required_pkgs[@]}"; do
      if ! have "${c}"; then
        fix_pkg "${c}"
      fi
    done
    ;;
  2)
    # common npm modules used by this setup
    modules=(typescript "@nestjs/cli" prettier live-server localtunnel vercel markserv psqlformat "npm-check-updates" ngrok)
    for m in "${modules[@]}"; do
      # attempt to infer binary
      case "${m}" in
        "@nestjs/cli") bin="nest" ;;
        "npm-check-updates") bin="ncu" ;;
        *) bin="${m##*/}" ;;
      esac
      if ! command -v "${bin}" >/dev/null 2>&1; then
        fix_npm "${m}"
      else
        ok "npm tool present: ${bin}"
      fi
    done
    ;;
  3)
    mkdir -p "${HOME}/.termux"
    new_line="extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"
    if [[ -f "${HOME}/.termux/termux.properties" ]]; then
      if grep -q '^extra-keys' "${HOME}/.termux/termux.properties"; then
        sed -i "s|^extra-keys =.*|${new_line}|" "${HOME}/.termux/termux.properties"
      else
        echo "${new_line}" >> "${HOME}/.termux/termux.properties"
      fi
    else
      printf "terminal-cursor-blink-rate=500\n\n%s\n" "${new_line}" > "${HOME}/.termux/termux.properties"
    fi
    if [[ ! -f "${HOME}/.termux/colors.properties" ]] || ! grep -q '^cursor=' "${HOME}/.termux/colors.properties"; then
      echo "cursor=#00FF00" >> "${HOME}/.termux/colors.properties"
    fi
    ok "Termux properties updated. Run: termux-reload-settings"
    ;;
  0|*)
    warn "No fixes applied."
    ;;
esac

echo
say "${GREEN}Doctor finished.${WHITE}"
