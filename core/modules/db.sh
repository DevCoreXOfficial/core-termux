#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_db.log"

# Paquetes de base de datos
DB_PACKAGES=(
	"postgresql"
	"mariadb"
	"sqlite"
	"tur-repo"
)

DB_EXTRA="mongodb"

# Instalar bases de datos
install_db() {
	separator
	box "Installing Databases"
	separator
	echo

	log_info "Installing databases..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing databases" _install_db_packages; then
		log_success "Databases installed successfully"
		separator
		echo
		list_item "PostgreSQL"
		list_item "MariaDB (MySQL)"
		list_item "SQLite"
		list_item "MongoDB"
		echo
	else
		log_error "Failed to install databases"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar
_install_db_packages() {
	pkg install "${DB_PACKAGES[@]}" -y &>"$LOG_FILE"
	pkg install "$DB_EXTRA" -y &>>"$LOG_FILE"
}

# Desinstalar bases de datos
uninstall_db() {
	separator
	box "Uninstalling Databases"
	separator
	echo

	log_info "Uninstalling databases..."

	if loading "Uninstalling databases" _uninstall_db_packages; then
		log_success "Databases uninstalled"
	else
		log_error "Failed to uninstall databases"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_db_packages() {
	pkg uninstall "${DB_PACKAGES[@]}" "$DB_EXTRA" -y &>"$LOG_FILE"
}

# Actualizar bases de datos
update_db() {
	separator
	box "Updating Databases"
	separator
	echo

	log_info "Updating databases..."

	if loading "Updating databases" _update_db_packages; then
		log_success "Databases updated"
	else
		log_error "Failed to update databases"
		return 1
	fi
}

# Función interna para actualizar
_update_db_packages() {
	pkg upgrade "${DB_PACKAGES[@]}" "$DB_EXTRA" -y &>"$LOG_FILE"
}
