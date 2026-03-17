#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

update_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Update"
		echo
		log_info "Usage: core update <target>"
		echo
		log_info "Available targets:"
		echo
		list_item "all        - Update framework + all installed packages"
		list_item "core       - Update only Core-Termux framework"
		list_item "language   - Update language packages (pkg upgrade)"
		list_item "db         - Update databases"
		list_item "ai         - Update AI tools (npm/pip)"
		list_item "editor     - Update Neovim configuration"
		list_item "tools      - Update development tools"
		list_item "node       - Update Node.js global modules"
		list_item "shell      - Update ZSH plugins"
    list_item "ui         - Update Termux UI"
    list_item "automation - Update Automation Tools"
		echo
		log_info "Note: 'core update core' updates the framework code,"
		echo "      while 'core update all' updates everything including"
		echo "      system packages and dependencies."
		echo
		return
	fi

	for arg in "$@"; do
		case "$arg" in
		all)
			separator
			box "Updating Everything"
			separator
			echo

			update_core

			import "@/modules/language"
			import "@/modules/db"
			import "@/modules/ai"
			import "@/modules/editor"
			import "@/modules/tools"
			import "@/modules/node-modules"
			import "@/modules/shell"
			import "@/modules/ui"
			import "@/modules/automation"

			update_language
			update_db
			update_ai
			update_editor
			update_tools
			update_node
			update_shell
			update_ui
      update_automation

			separator
			log_success "All updates completed"
			separator
			echo
			;;
		core)
			update_core
			;;
		language)
			import "@/modules/language"
			update_language
			;;
		db)
			import "@/modules/db"
			update_db
			;;
		ai)
			import "@/modules/ai"
			update_ai
			;;
		editor)
			import "@/modules/editor"
			update_editor
			;;
		tools)
			import "@/modules/tools"
			update_tools
			;;
		node)
			import "@/modules/node-modules"
			update_node
			;;
		shell)
			import "@/modules/shell"
			update_shell
			;;
		ui)
			import "@/modules/ui"
			update_ui
			;;
    automation)
      import "@/modules/automation"
      update_automation
      ;;
		*)
			log_warn "Unknown update target: $arg"
			echo "Run 'core update' to see available targets"
			;;
		esac
	done
}

# Actualizar Core-Termux
update_core() {
	separator
	box "Updating Core-Termux Framework"
	separator
	echo

	log_info "Checking for Core-Termux updates..."

	if [[ -d "$CORE_PATH/../.git" ]]; then
		if loading "Updating Core-Termux" _update_core_repo; then
			log_success "Core-Termux framework updated"
			echo
			list_item "New features and bug fixes applied"
			list_item "Commands and modules updated"
			
			# Limpiar notificación de update
			rm -f "$CORE_CACHE/new_version"
			rm -f "$CORE_CACHE/last_version_check"
			
			echo
		else
			log_success "Core-Termux is already up to date"
		fi
	else
		log_warn "Not a git repository, cannot update"
		log_info "If you installed via curl, reinstall with:"
		echo "  curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash"
	fi

	echo
}

# Función interna para actualizar repo
_update_core_repo() {
	git -C "$CORE_PATH/.." pull &>/dev/null
}
