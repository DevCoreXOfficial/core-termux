#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"

# Instalar herramientas de IA
install_ai() {
	separator
	box "Installing AI Tools"
	separator
	echo

	log_info "Installing AI tools..."

	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar prerequisitos
	if loading "Installing AI prerequisites" _install_ai_prerequisites; then
		log_success "AI prerequisites installed"
	else
		log_warn "Some prerequisites may have failed"
	fi

	# Instalar herramientas de IA
	if loading "Installing AI tools" _install_ai_tools; then
		log_success "AI tools installed successfully"
		separator
		echo
		list_item "Qwen Code"
		list_item "Gemini CLI"
		list_item "Mistral Vibe"
		echo
	else
		log_error "Failed to install AI tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar prerequisitos
_install_ai_prerequisites() {
	# Actualizar repositorios e instalar dependencias del sistema
	pkg install nodejs-lts python git clang make rust libffi openssl pkg-config -y &>>"$LOG_FILE"
	
	# Actualizar pip, setuptools y wheel para mistral-vibe
	pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
}

# Función interna para instalar herramientas
_install_ai_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	npm install -g @qwen-code/qwen-code @google/gemini-cli &>>"$LOG_FILE"
	pip install mistral-vibe &>>"$LOG_FILE"
}

# Desinstalar herramientas de IA
uninstall_ai() {
	separator
	box "Uninstalling AI Tools"
	separator
	echo

	log_info "Uninstalling AI tools..."

	if loading "Uninstalling AI tools" _uninstall_ai_tools; then
		log_success "AI tools uninstalled"
	else
		log_error "Failed to uninstall AI tools"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_ai_tools() {
	npm uninstall -g @qwen-code/qwen-code @google/gemini-cli &>"$LOG_FILE"
	pip uninstall mistral-vibe -y &>>"$LOG_FILE"
}

# Actualizar herramientas de IA
update_ai() {
	separator
	box "Updating AI Tools"
	separator
	echo

	log_info "Updating AI tools..."

	if loading "Updating AI tools" _update_ai_tools; then
		log_success "AI tools updated"
	else
		log_error "Failed to update AI tools"
		return 1
	fi
}

# Función interna para actualizar
_update_ai_tools() {
	npm update -g @qwen-code/qwen-code @google/gemini-cli &>"$LOG_FILE"
	pip install --upgrade mistral-vibe &>>"$LOG_FILE"
}
