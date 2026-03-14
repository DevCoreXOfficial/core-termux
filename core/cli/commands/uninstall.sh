#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

uninstall_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Uninstall"
		echo
		log_info "Usage: core uninstall <target>"
		echo
		log_info "Available targets:"
		echo
		list_item "all        - Uninstall everything (restore to default)"
		list_item "language   - Remove language packages"
		list_item "db         - Remove databases"
		list_item "ai         - Remove AI tools"
		list_item "editor     - Remove code editor"
		list_item "tools      - Remove development tools"
		list_item "node       - Remove Node.js global modules"
		list_item "shell      - Remove ZSH + Oh My Zsh"
		list_item "ui         - Restore Termux UI to default"
		echo
		log_warn "Warning: This will remove installed packages and configurations!"
		echo
		return
	fi

	for arg in "$@"; do
		case "$arg" in
		all)
			separator
			box "Uninstalling Everything"
			separator
			echo

			log_warn "This will remove all installed packages and configurations!"
			echo

			read_confirm "Are you sure you want to continue?" CONFIRM
			if [[ "$CONFIRM" != "y" ]]; then
				log_warn "Uninstall cancelled"
				return 1
			fi

			echo

			import "@/modules/ai"
			import "@/modules/db"
			import "@/modules/editor"
			import "@/modules/language"
			import "@/modules/node-modules"
			import "@/modules/tools"
			import "@/modules/shell"
			import "@/modules/ui"
			import "@/fix/localtunnel"

			uninstall_ai
			uninstall_db
			uninstall_editor
			uninstall_language
			uninstall_node
			uninstall_tools
			uninstall_shell
			uninstall_ui
			uninstall_localtunnel_fix

			# Eliminar directorios de Core-Termux
			log_info "Removing Core-Termux directories..."
			rm -rf "$CORE_DATA" "$CORE_CACHE" "$CORE_CONFIG"
			log_success "Core-Termux directories removed"

			# Eliminar symlink del comando core
			log_info "Removing core command..."
			rm -f "$PREFIX/bin/core"
			log_success "Core command removed"

			echo
			separator
			box "Uninstall Completed"
			separator
			echo
			log_warn "Termux has been restored to its default state"
			log_warn "Please restart Termux"
			echo
			;;
		language)
			import "@/modules/language"
			uninstall_language
			;;
		db)
			import "@/modules/db"
			uninstall_db
			;;
		ai)
			import "@/modules/ai"
			uninstall_ai
			;;
		editor)
			import "@/modules/editor"
			uninstall_editor
			;;
		tools)
			import "@/modules/tools"
			uninstall_tools
			;;
		node)
			import "@/modules/node-modules"
			uninstall_node
			;;
		shell)
			import "@/modules/shell"
			uninstall_shell
			;;
		ui)
			import "@/modules/ui"
			uninstall_ui
			;;
		*)
			log_warn "Unknown uninstall target: $arg"
			echo "Run 'core uninstall' to see available targets"
			;;
		esac
	done
}
