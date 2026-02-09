#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

CONFIG_FILE="${HOME}/.core-termux/config"
if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
else
  echo "Core-Termux not installed (missing ~/.core-termux/config)."
  return 0 2>/dev/null || exit 0
fi

# timestamp file
TIMESTAMP_FILE="${HOME}/.core-termux/.last_update_check"
CHECK_INTERVAL=$((24 * 60 * 60))

should_check_updates() {
  if [[ "${1:-}" == "--force" ]]; then
    return 0
  fi
  if [[ ! -f "${TIMESTAMP_FILE}" ]]; then
    return 0
  fi
  local last_check current_time time_diff
  last_check="$(cat "${TIMESTAMP_FILE}")"
  current_time="$(date +%s)"
  time_diff=$((current_time - last_check))
  [[ ${time_diff} -ge ${CHECK_INTERVAL} ]]
}

update_timestamp() {
  date +%s > "${TIMESTAMP_FILE}"
}

if ! should_check_updates "${1:-}"; then
  echo ""
  return 0 2>/dev/null || exit 0
fi

exec </dev/tty

cd "${core}"
git fetch --quiet

local_commit="$(git rev-parse HEAD)"
remote_commit="$(git rev-parse origin/main)"

if [[ "${local_commit}" != "${remote_commit}" ]]; then
  echo -e -n "${D_CYAN}Update available. Update ${CYAN}Core-Termux${D_CYAN}? [Y/n] ${WHITE}"
  read -r updateOption

  if [[ "${updateOption}" == "y" || "${updateOption}" == "Y" || -z "${updateOption}" ]]; then
    git pull origin main
    update_timestamp
    bash bootstrap.sh
  else
    echo -e "Abort"
    update_timestamp
    cd || true
  fi
else
  update_timestamp
fi
