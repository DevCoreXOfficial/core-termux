#!/bin/bash

# Importar funciones de log y colores para el help
import "@/utils/log"
import "@/utils/colors"

core_main() {
	local cmd="$1"
	shift || true

	# si no se pasa comando
	if [[ -z "$cmd" ]]; then
		core_help
		return
	fi

	local command_file="$CORE_PATH/cli/commands/$cmd.sh"

	# verificar si existe el comando
	if [[ -f "$command_file" ]]; then
		import "@/cli/commands/$cmd"
		"${cmd}_main" "$@"
	else
		log_error "Command not found: $cmd"
		echo
		core_help
		exit 1
	fi
}

core_help() {
	echo
	box_large "Core-Termux CLI v${CORE_VERSION}"
	echo
	log_info "Usage: core <command> [options]"
	echo
	separator_section "Available Commands"
	echo
	printf "    ${D_CYAN}%-12s${NC} %s\n" "setup" "Interactive installation wizard"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "install" "Install modules and packages"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "update" "Update modules or framework"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "uninstall" "Remove installed modules"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "list" "List available tools in modules"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "pg" "PostgreSQL database manager"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "init" "Configure existing projects"
	echo
	separator_section "Quick Start"
	echo
	list_item "Run: ${D_CYAN}core setup full${NC} (recommended)"
	list_item "Run: ${D_CYAN}core install full${NC} (alternative)"
	list_item "Run: ${D_CYAN}core update all${NC} (update all packages)"
	echo
	separator_section "Module Targets"
	echo
	log_info "Install, update, or uninstall:"
	echo
	printf "    ${D_GREEN}%-14s${NC} %s\n" "language" "Node.js, Python, Perl, PHP, Rust, C, C++"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "db" "PostgreSQL, MariaDB, SQLite, MongoDB"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "ai" "Qwen Code, Gemini CLI, Mistral Vibe, OpenClaude, Claude Code, OpenClaw, Ollama, Codex"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "editor" "Neovim + NvChad + Plugins"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "tools" "GitHub CLI, wget, curl, fzf, etc."
	printf "    ${D_GREEN}%-14s${NC} %s\n" "node" "Node.js global npm packages"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "shell" "ZSH + Oh My Zsh + 10 plugins"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "ui" "Termux UI (font, cursor, extra-keys)"
	printf "    ${D_GREEN}%-14s${NC} %s\n" "automation" "n8n"

	echo
	separator_section "Help"
	echo
	list_item "Run ${D_CYAN}core <command>${NC} for command-specific help"
	list_item "Example: ${D_CYAN}core pg${NC}, ${D_CYAN}core init${NC}"
	echo
}
