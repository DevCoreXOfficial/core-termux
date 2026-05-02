#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"

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

	if loading "Installing AI tools" _install_ai_tools_wrapper; then
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
		list_item "Codex ${GRAY}(${D_GREEN}codex${GRAY})"
		list_item "OpenCode ${GRAY}(${D_GREEN}opencode${GRAY})"
		list_item "Engram ${GRAY}(${D_GREEN}engram${GRAY})"
		echo
	else
		log_error "Failed to install AI tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

_install_ai_tools_wrapper() {
	import "@/tools/ai/all"
	install_all_ai_tools
}

uninstall_ai() {
	separator
	box "Uninstalling AI Tools"
	separator
	echo

	log_info "Uninstalling AI tools..."

	if loading "Uninstalling AI tools" _uninstall_ai_tools_wrapper; then
		log_success "AI tools uninstalled"
	else
		log_error "Failed to uninstall AI tools"
		return 1
	fi
}

_uninstall_ai_tools_wrapper() {
	import "@/tools/ai/all"
	uninstall_all_ai_tools
}

update_ai() {
	separator
	box "Updating AI Tools"
	separator
	echo

	log_info "Updating AI tools..."

	if loading "Updating AI tools" _update_ai_tools_wrapper; then
		log_success "AI tools updated"
	else
		log_error "Failed to update AI tools"
		return 1
	fi
}

_update_ai_tools_wrapper() {
	import "@/tools/ai/all"
	update_all_ai_tools
}