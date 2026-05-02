#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

DB_TOOLS=(
	"postgresql"
	"mariadb"
	"sqlite"
	"mongodb"
)

source "$(dirname "$BASH_SOURCE")/postgresql.sh"
source "$(dirname "$BASH_SOURCE")/mariadb.sh"
source "$(dirname "$BASH_SOURCE")/sqlite.sh"
source "$(dirname "$BASH_SOURCE")/mongodb.sh"

install_all_db_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${DB_TOOLS[@]}"; do
		case "$tool" in
		postgresql)
			if install_postgresql; then ((installed_count++)); else ((failed_count++)); fi
			;;
		mariadb)
			if install_mariadb; then ((installed_count++)); else ((failed_count++)); fi
			;;
		sqlite)
			if install_sqlite; then ((installed_count++)); else ((failed_count++)); fi
			;;
		mongodb)
			if install_mongodb; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_db_tools() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${DB_TOOLS[@]}"; do
		case "$tool" in
		postgresql)
			if uninstall_postgresql; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		mariadb)
			if uninstall_mariadb; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		sqlite)
			if uninstall_sqlite; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		mongodb)
			if uninstall_mongodb; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_db_tools() {
	local updated_count=0
	local failed_count=0

	for tool in "${DB_TOOLS[@]}"; do
		case "$tool" in
		postgresql)
			if update_postgresql; then ((updated_count++)); else ((failed_count++)); fi
			;;
		mariadb)
			if update_mariadb; then ((updated_count++)); else ((failed_count++)); fi
			;;
		sqlite)
			if update_sqlite; then ((updated_count++)); else ((failed_count++)); fi
			;;
		mongodb)
			if update_mongodb; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}