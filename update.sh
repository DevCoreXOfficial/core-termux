#!/bin/bash

source ~/.core-termux/config

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
  return 0
fi

exec </dev/tty

# core-termux update
cd ${core}
git fetch
local_commit=$(git rev-parse main)
remote_commit=$(git rev-parse origin/main)

if [ "${local_commit}" != "${remote_commit}" ]; then
	echo -e -n "${D_CYAN}A new update is available. Would you like to update ${CYAN}Core-Termux${D_CYAN}? [Y/n] ${WHITE}"
	read -r updateOption

	if [[ "${updateOption}" == "y" || "${updateOption}" == "Y" ]]; then
		git pull origin main
		update_timestamp
		exec bash bootstrap.sh
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
local_commit=$(git rev-parse main)
remote_commit=$(git rev-parse origin/main)

if [ "${local_commit}" != "${remote_commit}" ]; then
	echo -e -n "${D_CYAN}A new update is available. Would you like to update ${CYAN}NvChad-Termux${D_CYAN}? [Y/n] ${WHITE}"
	read -r nvchadUpdate

	if [[ "${nvchadUpdate}" == "y" || "${nvchadUpdate}" == "Y" ]]; then
		git pull origin main
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
