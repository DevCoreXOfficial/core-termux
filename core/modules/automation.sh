#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_automation.log"

# Instalar herramientas de automatización
install_automation() {
	separator
	box "Installing Automation Tools"
	separator
	echo

	log_info "Installing Automation Tools..."
	echo
	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar prerequisitos
	if loading "Installing Automation prerequisites" _install_automation_prerequisites; then
		log_success "Automation prerequisites installed"
	else
		log_warn "Some prerequisites may have failed"
	fi
	# Instalar herramientas de automatización
	if loading "Installing Automation Tools" _install_automation_tools; then
		log_success "Automation Tools installed successfully"
		separator
		echo
		list_item "n8n"
		echo
	else
		log_error "Failed to install Automation Tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar prerequisitos
_install_automation_prerequisites() {
	# Actualizar repositorios e instalar dependencias del sistema
  pkg install nodejs-lts python sqlite build-essential binutils make clang -y &>>"$LOG_FILE"

	# Instalar setuptools
	pip install setuptools &>>"$LOG_FILE"
}

# Función interna para instalar herramientas
_install_automation_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	npm install -g n8n &>>"$LOG_FILE"
}

# Desinstalar herramientas de automatización
uninstall_automation() {
	separator
	box "Uninstalling Automation Tools"
	separator
	echo

	log_info "Uninstalling Automation Tools..."

	if loading "Uninstalling Automation Tools" _uninstall_automation_tools; then
		log_success "Automation Tools uninstalled"
	else
		log_error "Failed to uninstall Automation Tools"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_automation_tools() {
	npm uninstall -g n8n &>"$LOG_FILE"
}

# Actualizar herramientas de IA
update_automation() {
	separator
	box "Updating Automation Tools"
	separator
	echo

	log_info "Updating Automation Tools..."

	if loading "Updating Automation Tools" _update_automation_tools; then
		log_success "Automation Tools updated"
	else
		log_error "Failed to update Automation Tools"
		return 1
	fi
}

# Función interna para actualizar
_update_automation_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24
	npm update -g n8n &>"$LOG_FILE"
}
