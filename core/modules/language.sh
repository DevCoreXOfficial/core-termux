#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_language.log"

# Paquetes de lenguaje
LANGUAGE_PACKAGES=(
	"nodejs-lts"
	"python"
	"perl"
	"php"
	"rust"
	"clang"
	"golang"
)

# Instalar paquetes de lenguaje
install_language() {
	separator
	box "Installing Language Packages"
	separator
	echo

	log_info "Installing language packages..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing language packages" _install_language_packages; then
		log_success "Language packages installed successfully"
		separator
		echo
		list_item "Node.js LTS"
		list_item "Python"
		list_item "Perl"
		list_item "PHP"
		list_item "Rust"
		list_item "C/C++ (clang)"
		list_item "Go (golang)"
		echo
	else
		log_error "Failed to install language packages"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar
_install_language_packages() {
	pkg install "${LANGUAGE_PACKAGES[@]}" -y &>"$LOG_FILE"
}

# Desinstalar paquetes de lenguaje
uninstall_language() {
	separator
	box "Uninstalling Language Packages"
	separator
	echo

	log_info "Uninstalling language packages..."

	if loading "Uninstalling language packages" _uninstall_language_packages; then
		log_success "Language packages uninstalled"
	else
		log_error "Failed to uninstall language packages"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_language_packages() {
	pkg uninstall "${LANGUAGE_PACKAGES[@]}" -y &>"$LOG_FILE"
}

# Actualizar paquetes de lenguaje
update_language() {
	separator
	box "Updating Language Packages"
	separator
	echo

	log_info "Updating language packages..."

	if loading "Updating language packages" _update_language_packages; then
		log_success "Language packages updated"
	else
		log_error "Failed to update language packages"
		return 1
	fi
}

# Función interna para actualizar
_update_language_packages() {
	pkg upgrade "${LANGUAGE_PACKAGES[@]}" -y &>"$LOG_FILE"
}
