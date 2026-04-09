#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_db.log"

# ===== POSTGRESQL =====
install_postgresql() {
	if dpkg -s postgresql 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install postgresql -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_postgresql() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL uninstalled"
		return 0
	else
		log_error "Failed to uninstall PostgreSQL"
		return 1
	fi
}

update_postgresql() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade postgresql -y &>>"$LOG_FILE"; then
		log_success "PostgreSQL updated"
		return 0
	else
		log_error "Failed to update PostgreSQL"
		return 1
	fi
}

# ===== MARIADB =====
install_mariadb() {
	if dpkg -s mariadb 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install mariadb -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_mariadb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MariaDB"
		return 1
	fi
}

update_mariadb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mariadb -y &>>"$LOG_FILE"; then
		log_success "MariaDB updated"
		return 0
	else
		log_error "Failed to update MariaDB"
		return 1
	fi
}

# ===== SQLITE =====
install_sqlite() {
	if dpkg -s sqlite 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install sqlite -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_sqlite() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite uninstalled"
		return 0
	else
		log_error "Failed to uninstall SQLite"
		return 1
	fi
}

update_sqlite() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade sqlite -y &>>"$LOG_FILE"; then
		log_success "SQLite updated"
		return 0
	else
		log_error "Failed to update SQLite"
		return 1
	fi
}

# ===== MONGODB =====
install_mongodb() {
	if dpkg -s mongodb 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install mongodb -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_mongodb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB uninstalled"
		return 0
	else
		log_error "Failed to uninstall MongoDB"
		return 1
	fi
}

update_mongodb() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade mongodb -y &>>"$LOG_FILE"; then
		log_success "MongoDB updated"
		return 0
	else
		log_error "Failed to update MongoDB"
		return 1
	fi
}
