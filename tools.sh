#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${HOME}/.core-termux/config"
if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
else
  # shellcheck disable=SC1091
  source "${ROOT_DIR}/config"
fi

: "${GREEN:=\e[1;32m}" "${CYAN:=\e[1;36m}" "${YELLOW:=\e[1;33m}" "${RED:=\e[1;31m}" "${WHITE:=\e[1;37m}" "${D_CYAN:=\e[0;36m}"

BACKUP_DIR="${HOME}/.core-termux/backups"
mkdir -p "${BACKUP_DIR}"

timestamp() { date +%Y%m%d-%H%M%S; }

backup() {
  local bdir="${BACKUP_DIR}/backup-$(timestamp)"
  mkdir -p "${bdir}"
  # configs
  [[ -f "${HOME}/.zshrc" ]] && cp -f "${HOME}/.zshrc" "${bdir}/.zshrc"
  [[ -d "${HOME}/.termux" ]] && cp -a "${HOME}/.termux" "${bdir}/termux"
  [[ -d "${HOME}/.config/nvim" ]] && cp -a "${HOME}/.config/nvim" "${bdir}/nvim"
  [[ -d "${HOME}/.core-termux" ]] && cp -a "${HOME}/.core-termux" "${bdir}/core-termux"
  echo "${bdir}" > "${BACKUP_DIR}/LATEST"
  echo -e "${GREEN}Backup created:${WHITE} ${bdir}"
}

restore() {
  if [[ ! -f "${BACKUP_DIR}/LATEST" ]]; then
    echo -e "${YELLOW}No backup found.${WHITE}"
    exit 0
  fi
  local bdir
  bdir="$(cat "${BACKUP_DIR}/LATEST")"
  if [[ ! -d "${bdir}" ]]; then
    echo -e "${YELLOW}Latest backup path missing:${WHITE} ${bdir}"
    exit 1
  fi
  echo -e "${CYAN}Restoring from:${WHITE} ${bdir}"
  [[ -f "${bdir}/.zshrc" ]] && cp -f "${bdir}/.zshrc" "${HOME}/.zshrc"
  if [[ -d "${bdir}/termux" ]]; then
    rm -rf "${HOME}/.termux"
    cp -a "${bdir}/termux" "${HOME}/.termux"
  fi
  if [[ -d "${bdir}/nvim" ]]; then
    rm -rf "${HOME}/.config/nvim"
    mkdir -p "${HOME}/.config"
    cp -a "${bdir}/nvim" "${HOME}/.config/nvim"
  fi
  echo -e "${GREEN}Restore completed.${WHITE}"
  command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings || true
}

uninstall() {
  echo -e "${YELLOW}This will remove Core-Termux configs and try to restore your last backup.${WHITE}"
  read -r -p "Continue? [y/N] " ans
  if [[ "${ans}" != "y" && "${ans}" != "Y" ]]; then
    echo "Abort."
    exit 0
  fi
  restore || true
  rm -rf "${HOME}/.core-termux"
  # keep backups
  echo -e "${GREEN}Uninstalled.${WHITE} Backups kept at ${BACKUP_DIR}"
}

case "${1:-}" in
  backup) backup ;;
  restore) restore ;;
  uninstall) uninstall ;;
  *) echo "Usage: $0 {backup|restore|uninstall}"; exit 2 ;;
esac
