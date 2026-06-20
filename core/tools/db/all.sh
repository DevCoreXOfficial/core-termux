#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

DB_TOOLS=(
	"postgresql"
	"mariadb"
	"sqlite"
	"mongodb"
)

source "$(dirname "$BASH_SOURCE")/postgresql/install.sh"
source "$(dirname "$BASH_SOURCE")/mariadb/install.sh"
source "$(dirname "$BASH_SOURCE")/sqlite/install.sh"
source "$(dirname "$BASH_SOURCE")/mongodb/install.sh"

install_all_db_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${DB_TOOLS[@]}"; do
		case "$tool" in
		postgresql)
			if loading "Installing PostgreSQL" install_postgresql; then ((installed_count++)); else ((failed_count++)); fi
			;;
		mariadb)
			if loading "Installing MariaDB" install_mariadb; then ((installed_count++)); else ((failed_count++)); fi
			;;
		sqlite)
			if loading "Installing SQLite" install_sqlite; then ((installed_count++)); else ((failed_count++)); fi
			;;
		mongodb)
			if loading "Installing MongoDB" install_mongodb; then ((installed_count++)); else ((failed_count++)); fi
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
			if loading "Uninstalling PostgreSQL" uninstall_postgresql; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		mariadb)
			if loading "Uninstalling MariaDB" uninstall_mariadb; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		sqlite)
			if loading "Uninstalling SQLite" uninstall_sqlite; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		mongodb)
			if loading "Uninstalling MongoDB" uninstall_mongodb; then ((uninstalled_count++)); else ((failed_count++)); fi
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
      if loading "Updating PostgreSQL" update_postgresql; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    mariadb)
      if loading "Updating MariaDB" update_mariadb; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    sqlite)
      if loading "Updating SQLite" update_sqlite; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    mongodb)
      if loading "Updating MongoDB" update_mongodb; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_db_tools() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${DB_TOOLS[@]}"; do
    case "$tool" in
    postgresql)
      if loading "Reinstalling PostgreSQL" reinstall_postgresql; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    mariadb)
      if loading "Reinstalling MariaDB" reinstall_mariadb; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    sqlite)
      if loading "Reinstalling SQLite" reinstall_sqlite; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    mongodb)
      if loading "Reinstalling MongoDB" reinstall_mongodb; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}