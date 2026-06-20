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
			loading "Installing PostgreSQL" install_postgresql
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		mariadb)
			loading "Installing MariaDB" install_mariadb
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		sqlite)
			loading "Installing SQLite" install_sqlite
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		mongodb)
			loading "Installing MongoDB" install_mongodb
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
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
			loading "Uninstalling PostgreSQL" uninstall_postgresql
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		mariadb)
			loading "Uninstalling MariaDB" uninstall_mariadb
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		sqlite)
			loading "Uninstalling SQLite" uninstall_sqlite
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		mongodb)
			loading "Uninstalling MongoDB" uninstall_mongodb
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
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
      loading "Updating PostgreSQL" update_postgresql
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    mariadb)
      loading "Updating MariaDB" update_mariadb
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    sqlite)
      loading "Updating SQLite" update_sqlite
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    mongodb)
      loading "Updating MongoDB" update_mongodb
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
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
      loading "Reinstalling PostgreSQL" reinstall_postgresql
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mariadb)
      loading "Reinstalling MariaDB" reinstall_mariadb
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    sqlite)
      loading "Reinstalling SQLite" reinstall_sqlite
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mongodb)
      loading "Reinstalling MongoDB" reinstall_mongodb
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}