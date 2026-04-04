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
	echo
	log_info "☕ Grab a coffee! This process typically takes 15-30 minutes."
	log_info "   Don't worry, it's normal for this to take a while..."
	echo

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
		list_item "Qwen Code ${GRAY}(${D_GREEN}qwen${GRAY})"
		list_item "Gemini CLI ${GRAY}(${D_GREEN}gemini${GRAY})"
		list_item "Mistral Vibe ${GRAY}(${D_GREEN}vibe${GRAY})"
		list_item "OpenClaude ${GRAY}(${D_GREEN}openclaude${GRAY})"
		list_item "Claude Code ${GRAY}(${D_GREEN}claude${GRAY})"
		list_item "OpenClaw ${GRAY}(${D_GREEN}openclaw${GRAY})"
		list_item "Ollama ${GRAY}(${D_GREEN}ollama${GRAY})"
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
	pkg install nodejs-lts python git clang make rust libffi openssl pkg-config ollama -y &>>"$LOG_FILE"

	# Actualizar pip, setuptools y wheel para mistral-vibe
	pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
}

# Función interna para instalar herramientas
_install_ai_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	local has_changes=false

	# Qwen Code
	if command -v qwen &>/dev/null; then
		log_info "Qwen Code ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Qwen Code..."
		npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"
		has_changes=true
	fi

	# Gemini CLI
	if command -v gemini &>/dev/null; then
		log_info "Gemini CLI ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Gemini CLI..."
		npm install -g @google/gemini-cli &>>"$LOG_FILE"
		has_changes=true
	fi

	# Claude Code
	if command -v claude &>/dev/null; then
		log_info "Claude Code ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Claude Code..."
		npm install -g @anthropic-ai/claude-code &>>"$LOG_FILE"
		has_changes=true
	fi

	# Mistral Vibe
	if command -v vibe &>/dev/null; then
		log_info "Mistral Vibe ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Mistral Vibe..."
		pip install mistral-vibe &>>"$LOG_FILE"
		has_changes=true
	fi

	# OpenClaude
	if command -v openclaude &>/dev/null; then
		log_info "OpenClaude ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing OpenClaude..."
		npm install -g @gitlawb/openclaude &>>"$LOG_FILE"
		has_changes=true
	fi

	# OpenClaw
	if command -v openclaw &>/dev/null; then
		log_info "OpenClaw ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing OpenClaw..."
		npm install -g openclaw@latest &>>"$LOG_FILE"
		has_changes=true
	fi

	# Return success even if nothing was installed (all already present)
	return 0
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
	npm uninstall -g @qwen-code/qwen-code @google/gemini-cli @anthropic-ai/claude-code openclaw @gitlawb/openclaude &>"$LOG_FILE"
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
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24
	npm update -g @qwen-code/qwen-code @google/gemini-cli @anthropic-ai/claude-code openclaw @gitlawb/openclaude &>>"$LOG_FILE"
	pip install --upgrade mistral-vibe &>>"$LOG_FILE"
}
