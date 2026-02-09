#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Core-Termux launcher (menu + commands)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${HOME}/.core-termux/config"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
else
  # shellcheck disable=SC1091
  source "${ROOT_DIR}/config"
fi

# Colors fallback if config not sourced
: "${GREEN:=\e[1;32m}" "${CYAN:=\e[1;36m}" "${YELLOW:=\e[1;33m}" "${RED:=\e[1;31m}" "${WHITE:=\e[1;37m}" "${D_CYAN:=\e[0;36m}"

LOG_DIR="${HOME}/.core-termux/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/core-$(date +%Y%m%d-%H%M%S).log"

log() { printf "%b\n" "$*" | tee -a "${LOG_FILE}"; }

ensure_termux() {
  if [[ -z "${PREFIX:-}" || "${PREFIX}" != *"/com.termux/"* ]]; then
    log "${YELLOW}Warning:${WHITE} This looks like it's not running inside Termux. Some steps may fail."
  fi
}

pause() { read -r -p "Press Enter to continue..." _; }

run_script() {
  local script="$1"; shift || true
  ensure_termux
  if [[ ! -f "${ROOT_DIR}/${script}" ]]; then
    log "${RED}Missing script:${WHITE} ${script}"
    return 1
  fi
  log "${CYAN}==> Running:${WHITE} ${script} $*"
  bash "${ROOT_DIR}/${script}" "$@" 2>&1 | tee -a "${LOG_FILE}"
}

print_header() {
  clear || true
  log "${CYAN}${PROJECT_NAME:-core-termux}${WHITE}  ${YELLOW}v${VERSION:-unknown}${WHITE}"
  log "${D_CYAN}${DESCRIPTION:-}${WHITE}"
  log "${D_CYAN}Log:${WHITE} ${LOG_FILE}"
  echo
}

menu() {
  while true; do
    print_header
    cat <<'EOF'
1) Install (Full)
2) Install (Minimal)
3) Install (Web stack)
4) Install (CLI tools only)
5) Update / Bootstrap
6) Doctor (Diagnostics + Fixes)
7) Backup configs
8) Restore last backup
9) Uninstall (remove configs + restore backup)
0) Exit
EOF
    echo
    read -r -p "Select an option: " opt
    case "${opt}" in
      1) run_script "setup.sh" --profile full --yes ;;
      2) run_script "setup.sh" --profile minimal --yes ;;
      3) run_script "setup.sh" --profile web --yes ;;
      4) run_script "setup.sh" --profile cli --yes ;;
      5) run_script "bootstrap.sh" ;;
      6) run_script "doctor.sh" ;;
      7) run_script "tools.sh" backup ;;
      8) run_script "tools.sh" restore ;;
      9) run_script "tools.sh" uninstall ;;
      0) exit 0 ;;
      *) log "${YELLOW}Invalid option.${WHITE}"; pause ;;
    esac
    pause
  done
}

# direct commands
cmd="${1:-menu}"
shift || true
case "${cmd}" in
  menu) menu ;;
  install) run_script "setup.sh" "$@" ;;
  update|bootstrap) run_script "bootstrap.sh" ;;
  doctor) run_script "doctor.sh" ;;
  backup) run_script "tools.sh" backup ;;
  restore) run_script "tools.sh" restore ;;
  uninstall) run_script "tools.sh" uninstall ;;
  *) log "${RED}Unknown command:${WHITE} ${cmd}"; exit 2 ;;
esac
