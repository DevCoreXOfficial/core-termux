#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/fix_localtunnel.log"

# Fix para el error de localtunnel en Android
# El problema: localtunnel usa la librería 'openurl' que no reconoce Android
# Solución: Agregar el caso 'android' para usar 'termux-open-url'

fix_localtunnel_openurl() {
	local openurl_file="${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js"

	# Verificar si el archivo existe
	if [[ ! -f "$openurl_file" ]]; then
		log_warn "localtunnel/openurl.js not found. Make sure localtunnel is installed."
		return 1
	fi

	# Verificar si el fix ya fue aplicado
	if grep -q "case 'android':" "$openurl_file" 2>/dev/null; then
		log_success "localtunnel fix already applied"
		return 0
	fi

	# Crear backup del archivo original
	local backup_file="${openurl_file}.bak"
	if [[ ! -f "$backup_file" ]]; then
		cp "$openurl_file" "$backup_file"
	fi

	# Aplicar el fix usando sed
	if sed -i "/case 'win32'/,/break;/ {
		/break;/a\    case 'android':\n        command = 'termux-open-url';\n        break;
	}" "$openurl_file" 2>/dev/null; then
		return 0
	else
		return 1
	fi
}

# Función principal para aplicar fix (usada por loading)
_apply_localtunnel_fix() {
	fix_localtunnel_openurl &>"$LOG_FILE"
}

# Aplicar fix con loading
apply_localtunnel_fix() {
	log_info "Applying localtunnel fix for Android..."

	if loading "Fixing localtunnel" _apply_localtunnel_fix; then
		log_success "localtunnel fix applied successfully"
		echo
		box "Fix Applied"
		echo
		list_item "Added Android case to openurl.js"
		list_item "Command: termux-open-url"
		echo
		return 0
	else
		log_error "Failed to apply localtunnel fix"
		return 1
	fi
}

# Restaurar el archivo original
restore_localtunnel_original() {
	local openurl_file="${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js"
	local backup_file="${openurl_file}.bak"

	if [[ ! -f "$backup_file" ]]; then
		log_warn "Backup file not found. Cannot restore."
		return 1
	fi

	if cp "$backup_file" "$openurl_file"; then
		log_success "localtunnel restored to original state"
		return 0
	else
		log_error "Failed to restore localtunnel"
		return 1
	fi
}

# Verificar el estado del fix
check_localtunnel_status() {
	local openurl_file="${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js"

	if [[ ! -f "$openurl_file" ]]; then
		log_warn "localtunnel not installed"
		return 1
	fi

	if grep -q "case 'android':" "$openurl_file" 2>/dev/null; then
		log_success "localtunnel fix is applied"
		return 0
	else
		log_warn "localtunnel fix NOT applied"
		return 1
	fi
}

# Función principal para fix (usada desde CLI)
fix_localtunnel() {
	separator
	box "Fixing localtunnel for Android"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	apply_localtunnel_fix

	echo
	separator
	log_success "localtunnel fix process completed"
	separator
	echo
}

# Función para uninstall (remover fix)
uninstall_localtunnel_fix() {
	separator
	box "Removing localtunnel Fix"
	separator
	echo

	log_info "Removing localtunnel fix..."

	if restore_localtunnel_original; then
		log_success "localtunnel fix removed"
	else
		log_warn "No fix to remove or restore failed"
	fi

	echo
	separator
	log_success "localtunnel fix removal completed"
	separator
	echo
}
