#!/bin/bash
set -euo pipefail


source "$HOME/.core-termux/config"

# Detect if script is sourced (e.g., from .zshrc)
is_sourced() { [[ "${BASH_SOURCE[0]}" != "${0}" ]]; }

# timestamp file
TIMESTAMP_FILE=~/.core-termux/.last_update_check
CHECK_INTERVAL=$((24 * 60 * 60))

# check updates
should_check_updates() {
	if [ ! -f "$TIMESTAMP_FILE" ]; then
		return 0 # first time
	fi

	local last_check=$(cat "$TIMESTAMP_FILE")
	local current_time=$(date +%s)
	local time_diff=$((current_time - last_check))

	[ $time_diff -ge $CHECK_INTERVAL ]
}

# update timestamp
update_timestamp() {
	date +%s >"$TIMESTAMP_FILE"
}

# update only if the interval exceeds the specified time frame
if ! should_check_updates; then
  echo ""
  if is_sourced; then
    return 0
  else
    exit 0
  fi
fi

if [ -t 0 ] && [ -r /dev/tty ]; then
  exec </dev/tty
fi

# core-termux update
if [ -z "${core:-}" ] || [ ! -d "${core}" ]; then
  echo -e "${RED}Core-Termux path is not set. Re-run setup.sh.${WHITE}"
  update_timestamp
  if is_sourced; then return 0; else exit 0; fi
fi

cd "${core}"
git fetch
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse origin/HEAD)

if [ "${local_commit}" != "${remote_commit}" ]; then
	echo -e -n "${D_CYAN}A new update is available. Would you like to update ${CYAN}Core-Termux${D_CYAN}? [Y/n] ${WHITE}"
	read -r updateOption

	if [[ "${updateOption}" == "y" || "${updateOption}" == "Y" ]]; then
		git pull --ff-only
		update_timestamp
		bash bootstrap.sh
	elif [[ "${updateOption}" == "n" || "${updateOption}" == "N" ]]; then
		echo -e "Abort"
		update_timestamp
		cd
	else
		echo -e "Error"
		update_timestamp
		cd
	fi
else
	echo -e ""
	update_timestamp
fi

# nvchad-termux update
cd ~/.core-termux/nvchad-termux/
git fetch
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse origin/HEAD)

if [ "${local_commit}" != "${remote_commit}" ]; then
	echo -e -n "${D_CYAN}A new update is available. Would you like to update ${CYAN}NvChad-Termux${D_CYAN}? [Y/n] ${WHITE}"
	read -r nvchadUpdate

	if [[ "${nvchadUpdate}" == "y" || "${nvchadUpdate}" == "Y" ]]; then
		git pull --ff-only
		bash bootstrap.sh
	elif [[ "${nvchadUpdate}" == "n" || "${nvchadUpdate}" == "N" ]]; then
		echo -e "Abort"
		cd
	else
		echo -e "Error"
		cd
	fi
else
	cd
fi
