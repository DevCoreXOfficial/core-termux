#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

install_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Install"
		echo
		log_info "Usage: core install <target>"
		echo
		log_info "Available targets:"
		echo
		list_item "full       - Install everything (recommended)"
    list_item "language   - Language packages (Node.js, Python, Perl, PHP, Rust, Go, C, C++)"
		list_item "db         - Databases (PostgreSQL, MariaDB, SQLite, MongoDB)"
		list_item "ai         - AI tools (Qwen Code, Gemini CLI, Mistral Vibe, OpenCode)"
		list_item "editor     - Code editor (Neovim + NvChad)"
		list_item "tools      - Development tools"
		list_item "node       - Node.js global modules (npm packages)"
		list_item "shell      - ZSH + Oh My Zsh + plugins"
		list_item "ui         - Termux UI (font, cursor, extra-keys)"
    list_item "automation - Automation Tools (n8n)"

		echo
		return
	fi

	for arg in "$@"; do
		case "$arg" in
		full)
			separator
			box "Installing Complete Environment"
			separator
			echo

			import "@/modules/language"
			import "@/modules/db"
			import "@/modules/ai"
			import "@/modules/editor"
			import "@/modules/tools"
			import "@/modules/node-modules"
			import "@/modules/shell"
			import "@/modules/ui"
      import "@/modules/automation"

			install_language
			install_db
			install_ai
			install_editor
			install_tools
			install_node
			install_shell
			setup_ui
      install_automation

			separator
			log_success "Complete environment installed successfully"
			separator
			echo
			log_warn "Please restart Termux to apply all changes"
			echo
			;;
		db)
			import "@/modules/db"
			install_db
			;;
		ai)
			import "@/modules/ai"
			install_ai
			;;
		editor)
			import "@/modules/editor"
			install_editor
			;;
		language)
			import "@/modules/language"
			install_language
			;;
		tools)
			import "@/modules/tools"
			install_tools
			;;
		node)
			import "@/modules/node-modules"
			install_node
			;;
		shell)
			import "@/modules/shell"
			install_shell
			;;
		ui)
			import "@/modules/ui"
			setup_ui
			;;
		automation)
			import "@/modules/automation"
			install_automation
			;;
		*)
			log_warn "Unknown install target: $arg"
			echo "Run 'core install' to see available targets"
			;;
		esac
	done
}
