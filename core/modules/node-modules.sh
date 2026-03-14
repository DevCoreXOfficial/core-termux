#!/bin/bash

import "@/utils/log"
import "@/utils/colors"
import "@/fix/localtunnel"

# Variables
NPM_GLOBAL_PACKAGES=(
	"typescript"
	"@nestjs/cli"
	"prettier"
	"live-server"
	"localtunnel"
	"vercel"
	"markserv"
	"psqlformat"
	"npm-check-updates"
	"ngrok"
)

LOG_FILE="$CORE_CACHE/install_node_modules.log"

# Instalar paquetes npm globales
install_node_modules() {
	log_info "Installing Node.js global modules..."

	# Crear archivo de log
	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar con loading y redirigir output a log
	if loading "Installing npm global packages" _install_npm_packages; then
		log_success "Node.js global modules installed"
		echo
		list_item "TypeScript"
		list_item "NestJS CLI"
		list_item "Prettier"
		list_item "Live Server"
		list_item "Localtunnel"
		list_item "Vercel CLI"
		list_item "Markserv"
		list_item "PSQL Format"
		list_item "NPM Check Updates"
		list_item "Ngrok"
		echo

		# Aplicar fix de localtunnel
		apply_localtunnel_fix

		return 0
	else
		log_error "Failed to install Node.js global modules"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar (usada por loading)
_install_npm_packages() {
	npm install -g "${NPM_GLOBAL_PACKAGES[@]}" &>"$LOG_FILE"
}

# Aplicar fix de localtunnel
apply_localtunnel_fix() {
	log_info "Applying localtunnel fix for Android..."

	if fix_localtunnel_openurl &>>"$LOG_FILE"; then
		log_success "Localtunnel fix applied"
	else
		log_warn "Localtunnel fix failed (may not be needed)"
	fi
}

# Desinstalar paquetes npm
uninstall_node_modules() {
	log_info "Uninstalling Node.js global modules..."

	if loading "Uninstalling npm global packages" _uninstall_npm_packages; then
		log_success "Node.js global modules uninstalled"
		return 0
	else
		log_error "Failed to uninstall Node.js global modules"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_npm_packages() {
	npm uninstall -g "${NPM_GLOBAL_PACKAGES[@]}" &>"$LOG_FILE"
}

# Actualizar paquetes npm
update_node_modules() {
	log_info "Updating Node.js global modules..."

	if loading "Updating npm global packages" _update_npm_packages; then
		log_success "Node.js global modules updated"
		return 0
	else
		log_error "Failed to update Node.js global modules"
		return 1
	fi
}

# Función interna para actualizar
_update_npm_packages() {
	npm update -g "${NPM_GLOBAL_PACKAGES[@]}" &>"$LOG_FILE"
}

# Función principal para instalar
install_node() {
	separator
	box "Installing Node.js Modules"
	separator
	echo

	install_node_modules

	echo
	separator
	log_success "Node.js modules installation completed"
	separator
	echo
}

# Función principal para desinstalar
uninstall_node() {
	separator
	box "Uninstalling Node.js Modules"
	separator
	echo

	uninstall_node_modules

	echo
	separator
	log_success "Node.js modules uninstallation completed"
	separator
	echo
}

# Función principal para actualizar
update_node() {
	separator
	box "Updating Node.js Modules"
	separator
	echo

	update_node_modules

	echo
	separator
	log_success "Node.js modules update completed"
	separator
	echo
}
