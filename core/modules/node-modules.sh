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
	local has_changes=false

	# TypeScript
	if command -v tsc &>/dev/null; then
		log_info "TypeScript ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing TypeScript..."
		npm install -g typescript &>>"$LOG_FILE"
		has_changes=true
	fi

	# NestJS CLI
	if command -v nest &>/dev/null; then
		log_info "NestJS CLI ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing NestJS CLI..."
		npm install -g @nestjs/cli &>>"$LOG_FILE"
		has_changes=true
	fi

	# Prettier
	if command -v prettier &>/dev/null; then
		log_info "Prettier ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Prettier..."
		npm install -g prettier &>>"$LOG_FILE"
		has_changes=true
	fi

	# Live Server
	if command -v live-server &>/dev/null; then
		log_info "Live Server ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Live Server..."
		npm install -g live-server &>>"$LOG_FILE"
		has_changes=true
	fi

	# Local_tunnel
	if command -v localtunnel &>/dev/null; then
		log_info "Localtunnel ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Local_tunnel..."
		npm install -g localtunnel &>>"$LOG_FILE"
		has_changes=true
	fi

	# Vercel CLI
	if command -v vercel &>/dev/null; then
		log_info "Vercel CLI ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Vercel CLI..."
		npm install -g vercel &>>"$LOG_FILE"
		has_changes=true
	fi

	# Markserv
	if command -v markserv &>/dev/null; then
		log_info "Markserv ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Markserv..."
		npm install -g markserv &>>"$LOG_FILE"
		has_changes=true
	fi

	# PSQL Format
	if command -v psqlformat &>/dev/null; then
		log_info "PSQL Format ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing PSQL Format..."
		npm install -g psqlformat &>>"$LOG_FILE"
		has_changes=true
	fi

	# NPM Check Updates
	if command -v ncu &>/dev/null; then
		log_info "NPM Check Updates ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing NPM Check Updates..."
		npm install -g npm-check-updates &>>"$LOG_FILE"
		has_changes=true
	fi

	# Ngrok
	if command -v ngrok &>/dev/null; then
		log_info "Ngrok ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Ngrok..."
		npm install -g ngrok &>>"$LOG_FILE"
		has_changes=true
	fi

	return 0
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
