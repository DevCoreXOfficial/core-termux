#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"
import "@/lib/platform"

# Variables de PostgreSQL
PG_DATA="$PREFIX/var/lib/postgresql"
PG_LOG="$CORE_CACHE/postgresql.log"
PG_USER="postgres"

# Mostrar ayuda
pg_help() {
	echo
	box_large "Core PostgreSQL Manager"
	echo
	log_info "Usage: core pg <command> [options]"
	echo
	separator_section "Available Commands"
	echo
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "start" "Start PostgreSQL server"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "stop" "Stop PostgreSQL server"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "restart" "Restart PostgreSQL server"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "status" "Check PostgreSQL status"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "init" "Initialize PostgreSQL database"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "create" "Create a new database"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "drop" "Drop a database"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "list" "List all databases"
	printf "    ${GRAY_19}%-12s${D_NC} %s\n" "shell" "Open psql shell"
	echo
	separator_section "Examples"
	echo
	printf "    ${GRAY_19}core pg start${D_NC}              # Start PostgreSQL\n"
	printf "    ${GRAY_19}core pg stop${D_NC}               # Stop PostgreSQL\n"
	printf "    ${GRAY_19}core pg create mydb${D_NC}        # Create database 'mydb'\n"
	printf "    ${GRAY_19}core pg shell${D_NC}              # Open psql shell\n"
	echo
}

# Check if PostgreSQL is installed
check_pg_installed() {
	if ! command -v pg_ctl &>/dev/null; then
		log_error "PostgreSQL is not installed"
		log_info "Run: ${GRAY_19}core install db${NC}"
		return 1
	fi
	return 0
}

# Check if initialized (informational only)
check_pg_initialized() {
	# Check multiple possible paths
	local data_dirs=(
		"$PREFIX/var/lib/postgresql/data"
		"$PG_DATA/data"
		"$HOME/.termux/postgresql/data"
		"/data/data/com.termux/files/usr/var/lib/postgresql/data"
	)

	for dir in "${data_dirs[@]}"; do
		if [[ -d "$dir" ]] && [[ -f "$dir/PG_VERSION" ]]; then
			# Update PG_DATA to the correct path
			PG_DATA="$(dirname "$dir")"
			return 0
		fi
	done

	# Also check if the service is running
	if pg_ctl status &>/dev/null; then
		return 0
	fi

	return 1
}

# Inicializar PostgreSQL
pg_init() {
	separator
	box_large "Initializing PostgreSQL"
	separator
	echo

	check_pg_installed || return 1

	# Check if already initialized
	if check_pg_initialized; then
		log_warn "PostgreSQL is already initialized"
		echo
		list_item "Data directory: $PG_DATA"
		list_item "Run: ${GRAY_19}core pg start${NC}"
		echo
		return 0
	fi

	mkdir -p "$PG_DATA"

	log_info "Initializing PostgreSQL database..."

	if loading "Initializing database" _pg_init_db; then
		log_success "PostgreSQL initialized successfully"
		echo
		list_item "Data directory: $PG_DATA"
		list_item "Default user: $PG_USER"
		echo
		log_info "Start PostgreSQL with: ${GRAY_19}core pg start${NC}"
	else
		log_error "Failed to initialize PostgreSQL"
		log_warn "Check log: $PG_LOG"
		return 1
	fi

	echo
}

_pg_init_db() {
	initdb -D "$PG_DATA" &>"$PG_LOG"
}

# Iniciar PostgreSQL
pg_start() {
	separator
	box_large "Starting PostgreSQL"
	separator
	echo

	check_pg_installed || return 1

	# Intentar detectar la ruta de datos antes de iniciar
	local found_dir=""
	local data_dirs=(
		"$PREFIX/var/lib/postgresql"
		"$PREFIX/var/lib/postgresql/data"
		"$PG_DATA"
		"$PG_DATA/data"
		"$HOME/.termux/postgresql"
		"$HOME/.termux/postgresql/data"
	)

	for dir in "${data_dirs[@]}"; do
		if [[ -d "$dir" ]] && [[ -f "$dir/PG_VERSION" ]]; then
			PG_DATA="$dir"
			found_dir="$dir"
			break
		fi
	done

	log_info "Starting PostgreSQL server..."

	if loading "Starting PostgreSQL" _pg_start_server; then
		log_success "PostgreSQL started successfully"
		echo
		list_item "Listening on: localhost:5432"
		list_item "User: $PG_USER"
		echo
	else
		log_error "Failed to start PostgreSQL"
		log_warn "PostgreSQL may not be initialized. Run: core pg init"
		return 1
	fi

	echo
}

_pg_start_server() {
	pg_ctl -D "$PG_DATA" -l "$PG_LOG" start &>/dev/null
	sleep 1
}

# Detener PostgreSQL
pg_stop() {
	separator
	box_large "Stopping PostgreSQL"
	separator
	echo

	check_pg_installed || return 1

	# Intentar detectar la ruta de datos
	local found_dir=""
	local data_dirs=(
		"$PREFIX/var/lib/postgresql"
		"$PREFIX/var/lib/postgresql/data"
		"$PG_DATA"
		"$PG_DATA/data"
		"$HOME/.termux/postgresql"
		"$HOME/.termux/postgresql/data"
	)

	for dir in "${data_dirs[@]}"; do
		if [[ -d "$dir" ]] && [[ -f "$dir/PG_VERSION" ]]; then
			PG_DATA="$dir"
			found_dir="$dir"
			break
		fi
	done

	log_info "Stopping PostgreSQL server..."

	if loading "Stopping PostgreSQL" _pg_stop_server; then
		log_success "PostgreSQL stopped successfully"
	else
		log_error "Failed to stop PostgreSQL"
		log_warn "PostgreSQL may not be running"
		return 1
	fi

	echo
}

_pg_stop_server() {
	pg_ctl -D "$PG_DATA" stop &>/dev/null
}

# Reiniciar PostgreSQL
pg_restart() {
	separator
	box_large "Restarting PostgreSQL"
	separator
	echo

	check_pg_installed || return 1
	check_pg_initialized || return 1

	pg_stop
	sleep 1
	pg_start

	echo
	separator
	log_success "PostgreSQL restarted"
	separator
	echo
}

# Estado de PostgreSQL
pg_status() {
	separator
	box_large "PostgreSQL Status"
	separator
	echo

	check_pg_installed || return 1

	# Try to detect the data path
	local found_dir=""
	# In Termux, data may live directly in the directory or in /data
	local data_dirs=(
		"$PREFIX/var/lib/postgresql"
		"$PREFIX/var/lib/postgresql/data"
		"$PG_DATA"
		"$PG_DATA/data"
		"$HOME/.termux/postgresql"
		"$HOME/.termux/postgresql/data"
	)

	for dir in "${data_dirs[@]}"; do
		if [[ -d "$dir" ]] && [[ -f "$dir/PG_VERSION" ]]; then
			PG_DATA="$dir"
			found_dir="$dir"
			break
		fi
	done

	log_info "Checking PostgreSQL status..."
	echo

	# Check status
	if [[ -n "$found_dir" ]]; then
		if pg_ctl -D "$found_dir" status &>/dev/null; then
			log_success "PostgreSQL is RUNNING"
			echo
			list_item "Data directory: $PG_DATA"
			list_item "Port: 5432"
			list_item "User: $PG_USER"
		else
			log_warn "PostgreSQL is STOPPED"
			echo
			list_item "Data directory: $PG_DATA"
			list_item "Run: ${GRAY_19}core pg start${NC}"
		fi
	else
		log_info "PostgreSQL data directory not found"
		echo
		list_item "Run: ${GRAY_19}core pg init${NC}"
	fi

	echo
}

# Crear base de datos
pg_create() {
	local db_name="$1"

	if [[ -z "$db_name" ]]; then
		log_error "Database name required"
		log_info "Usage: core pg create <database_name>"
		return 1
	fi

	check_pg_installed || return 1

	# Detectar ruta de datos
	_detect_pg_data

	log_info "Creating database: $db_name..."

	if su - "$PG_USER" -c "createdb $db_name" &>/dev/null; then
		log_success "Database '$db_name' created successfully"
	else
		log_error "Failed to create database '$db_name'"
		log_warn "PostgreSQL may not be running or initialized"
		return 1
	fi
}

# Drop database
pg_drop() {
	local db_name="$1"

	if [[ -z "$db_name" ]]; then
		log_error "Database name required"
		log_info "Usage: core pg drop <database_name>"
		return 1
	fi

	check_pg_installed || return 1

	log_warn "This will permanently delete database: $db_name"

	read_confirm "Are you sure?" CONFIRM
	if [[ "$CONFIRM" != "y" ]]; then
		log_warn "Operation cancelled"
		return 0
	fi

	# Detectar ruta de datos
	_detect_pg_data

	log_info "Dropping database: $db_name..."

	if su - "$PG_USER" -c "dropdb $db_name" &>/dev/null; then
		log_success "Database '$db_name' dropped successfully"
	else
		log_error "Failed to drop database '$db_name'"
		return 1
	fi
}

# Listar bases de datos
pg_list() {
	separator
	box_large "PostgreSQL Databases"
	separator
	echo

	check_pg_installed || return 1

	# Detectar ruta de datos
	_detect_pg_data

	log_info "Listing databases..."
	echo

	su - "$PG_USER" -c "psql -c '\l'" 2>/dev/null || {
		log_error "Failed to list databases"
		log_warn "PostgreSQL may not be running"
		return 1
	}

	echo
}

# Abrir shell psql
pg_shell() {
	check_pg_installed || return 1

	# Detectar ruta de datos
	_detect_pg_data

	log_info "Opening psql shell..."
	echo

	su - "$PG_USER" -c "psql" 2>/dev/null
}

# Helper function to detect the data path
_detect_pg_data() {
	local data_dirs=(
		"$PREFIX/var/lib/postgresql"
		"$PREFIX/var/lib/postgresql/data"
		"$PG_DATA"
		"$PG_DATA/data"
		"$HOME/.termux/postgresql"
		"$HOME/.termux/postgresql/data"
	)

	for dir in "${data_dirs[@]}"; do
		if [[ -d "$dir" ]] && [[ -f "$dir/PG_VERSION" ]]; then
			PG_DATA="$dir"
			return 0
		fi
	done

	return 1
}

# ---------------------------------------------------------------------------
# Ubuntu / WSL implementations — PostgreSQL runs as a system service.
# ---------------------------------------------------------------------------

_pg_sys_super() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo -u postgres "$@"
  else
    log_error "Need root or sudo to manage PostgreSQL as the postgres user"
    return 1
  fi
}

_pg_ubuntu_service() {
  local action="$1"
  if command -v systemctl &>/dev/null; then
    $CORE_SUDO systemctl "$action" postgresql &>>"$PG_LOG"
  else
    $CORE_SUDO service postgresql "$action" &>>"$PG_LOG"
  fi
}

pg_ubuntu_start() {
  separator; box_large "Starting PostgreSQL"; separator; echo
  loading "Starting PostgreSQL service" _pg_ubuntu_service start &&
    log_success "PostgreSQL started" || { log_error "Failed to start (log: $PG_LOG)"; return 1; }
  echo
}

pg_ubuntu_stop() {
  separator; box_large "Stopping PostgreSQL"; separator; echo
  loading "Stopping PostgreSQL service" _pg_ubuntu_service stop &&
    log_success "PostgreSQL stopped" || { log_error "Failed to stop"; return 1; }
  echo
}

pg_ubuntu_restart() {
  separator; box_large "Restarting PostgreSQL"; separator; echo
  loading "Restarting PostgreSQL service" _pg_ubuntu_service restart &&
    log_success "PostgreSQL restarted" || { log_error "Failed to restart"; return 1; }
  echo
}

pg_ubuntu_status() {
  if command -v systemctl &>/dev/null; then
    $CORE_SUDO systemctl is-active --quiet postgresql \
      && log_success "PostgreSQL is running" \
      || log_warn "PostgreSQL is not running"
  else
    $CORE_SUDO service postgresql status
  fi
}

pg_ubuntu_init() {
  separator; box_large "Initializing PostgreSQL"; separator; echo
  if command -v pg_lsclusters &>/dev/null && pg_lsclusters | grep -q online; then
    log_success "PostgreSQL cluster already initialized and online"
    pg_lsclusters
    return 0
  fi
  command -v psql >/dev/null 2>&1 || { pm_install postgresql || return 1; }
  log_info "Cluster created automatically by apt on install."
  log_info "Set the postgres password with:"
  list_item "${GRAY_19}$_pg_sudo_user psql -c \"ALTER USER postgres PASSWORD '...';\"${D_NC}"
  echo
}

_pg_sudo_user() {
  if [[ "$(id -u)" -eq 0 ]]; then runuser -u postgres -- psql
  else sudo -u postgres psql; fi
}

pg_ubuntu_create() {
  local db="$1"
  [[ -z "$db" ]] && { log_error "Usage: core pg create <name>"; return 1; }
  _pg_sys_super createdb "$db" && log_success "Database '$db' created"
}

pg_ubuntu_drop() {
  local db="$1"
  [[ -z "$db" ]] && { log_error "Usage: core pg drop <name>"; return 1; }
  _pg_sys_super dropdb "$db" && log_success "Database '$db' dropped"
}

pg_ubuntu_list() {
  _pg_sys_super psql -lqt | cut -d'|' -f1 | grep -w ':' | sed 's/ //g'
}

pg_ubuntu_shell() {
  _pg_sys_super psql
}

# Main function
pg_main() {
	local cmd="$1"
	shift || true

	core_detect_platform

	if [[ "$CORE_ENV" != "termux" ]]; then
		case "$cmd" in
		start) pg_ubuntu_start ;;
		stop) pg_ubuntu_stop ;;
		restart) pg_ubuntu_restart ;;
		status) pg_ubuntu_status ;;
		init) pg_ubuntu_init ;;
		create) pg_ubuntu_create "$2" ;;
		drop) pg_ubuntu_drop "$2" ;;
		list | ls) pg_ubuntu_list ;;
		shell | psql) pg_ubuntu_shell ;;
		"") pg_help ;;
		*)
			log_error "Unknown command: $cmd"
			pg_help
			exit 1
			;;
		esac
		return
	fi

	case "$cmd" in
	start)
		pg_start
		;;
	stop)
		pg_stop
		;;
	restart)
		pg_restart
		;;
	status)
		pg_status
		;;
	init)
		pg_init
		;;
	create)
		pg_create "$2"
		;;
	drop)
		pg_drop "$2"
		;;
	list | ls)
		pg_list
		;;
	shell | psql)
		pg_shell
		;;
	"")
		pg_help
		;;
	*)
		log_error "Unknown command: $cmd"
		pg_help
		exit 1
		;;
	esac
}
