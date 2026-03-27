#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

# Mostrar banner de bienvenida
show_banner() {
	echo
	center_text "${D_CYAN}╔══════════════════════════════════════╗${NC}"
	center_text "${D_CYAN}║     Core-Termux Setup Wizard         ║${NC}"
	center_text "${D_CYAN}╚══════════════════════════════════════╝${NC}"
	echo
}

# Mostrar menú de instalación
show_menu() {
	box "Installation Menu"
	echo
	list_item "Press ${D_GREEN}1${NC} - Full installation (recommended)"
	list_item "Press ${D_GREEN}2${NC} - Custom installation"
	list_item "Press ${D_GREEN}3${NC} - Install only base packages"
	list_item "Press ${D_GREEN}4${NC} - Cancel"
	echo
	log_info "Enter your choice [1-4]:"
	echo
}

# Instalar paquetes base de Termux
update_termux_repositories() {
	separator
	box "Updating Termux Repositories"
	separator
	echo

	LOG_FILE="$CORE_CACHE/install_base.log"
	mkdir -p "$(dirname "$LOG_FILE")"

	log_info "Updating Termux repositories..."

	if loading "Updating repositories" _update_repos; then
		log_success "Repositories updated"
	else
		log_error "Failed to update repositories"
		return 1
	fi

	echo
}

# Funciones internas para loading
_update_repos() {
	yes | pkg update &>"$LOG_FILE"
	yes | pkg upgrade &>>"$LOG_FILE"
}

# Instalación completa (recomendada)
install_full() {
	show_banner

	box "Full Installation"
	echo
	log_info "This will install:"
	echo
	list_item "All base packages"
	list_item "Language packages (Node.js, Python, Perl, PHP, Rust, Go, C, C++)"
	list_item "Databases (PostgreSQL, MariaDB, SQLite, MongoDB)"
  list_item "AI tools (Qwen Code, Gemini CLI, Mistral Vibe, OpenCode, Claude Code, OpenClaw)"
  list_item "Code editor (Neovim + NvChad + Plugins)"
	list_item "Development tools"
	list_item "ZSH + Oh My Zsh + plugins"
	list_item "Termux UI configuration"
  list_item "Automation Tools (n8n)"
	echo

	read_confirm "Continue with full installation?" CONFIRM
	if [[ "$CONFIRM" != "y" ]]; then
		log_warn "Installation cancelled"
		return 1
	fi

	echo
	update_termux_repositories

	import "@/modules/language"
	import "@/modules/tools"
	import "@/modules/node-modules"
	import "@/modules/db"
	import "@/modules/ai"
	import "@/modules/editor"
	import "@/modules/shell"
	import "@/modules/ui"
  import "@/modules/automation"

	install_language
	install_tools
	install_node
	install_db
	install_ai
	install_editor
	install_shell
	setup_ui
  install_automation

	echo
	separator
	box "Installation Completed Successfully"
	separator
	echo
	log_success "Core-Termux framework is ready!"
	echo
	log_warn "Please restart Termux to apply all changes"
	echo
}

# Instalación personalizada
install_custom() {
	show_banner

	box "Custom Installation"
	echo
	log_info "Select modules to install:"
	echo
	separator_section "Module Selection"
	echo
	list_item "Use ${D_CYAN}↑↓${D_NC} to navigate and select"
	echo

	local -a selected=()

	# Menú interactivo con selección múltiple
	while true; do
		echo
		log_info "Selected: ${D_CYAN}${#selected[@]} modules${D_NC}"
		echo

		# Mostrar módulos seleccionados
		if [[ ${#selected[@]} -gt 0 ]]; then
			for s in "${selected[@]}"; do
				echo -e "    ${GREEN}✓${D_NC} $s"
			done
			echo
		fi

		# Leer selección con flechas
		local choice=""
		read_select "Select modules (↑↓ to navigate, Enter to toggle)" choice \
			"language" "db" "ai" "editor" "tools" "node" "shell" "ui" "automation" \
			"start" "cancel"

		echo

		case "$choice" in
		"start")
			break
			;;
		"cancel")
			log_warn "Installation cancelled"
			return 1
			;;
		*)
			# Toggle selección
			local found=0
			for s in "${selected[@]}"; do
				if [[ "$s" == "$choice" ]]; then
					found=1
					break
				fi
			done

			if [[ $found -eq 0 ]]; then
				selected+=("$choice")
				log_success "Added: $choice"
			else
				selected=()
				for s in "${selected[@]}"; do
					if [[ "$s" != "$choice" ]]; then
						selected+=("$s")
					fi
				done
				log_warn "Removed: $choice"
			fi
			;;
		esac
	done

	if [[ ${#selected[@]} -eq 0 ]]; then
		log_warn "No modules selected"
		return 1
	fi

	echo
	update_termux_repositories

	# Instalar módulos seleccionados
	for module in "${selected[@]}"; do
		echo
		case "$module" in
		language)
			import "@/modules/language"
			install_language
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
		esac
	done

	echo
	separator
	log_success "Custom installation completed"
	separator
	echo
	log_warn "Please restart Termux to apply all changes"
	echo
}

# Instalación básica (solo paquetes base)
install_base() {
	show_banner

	box "Base Installation"
	echo
	log_info "This will install only base packages"
	echo

	read_confirm "Continue?" CONFIRM
	if [[ "$CONFIRM" != "y" ]]; then
		log_warn "Installation cancelled"
		return 1
	fi

	echo
	update_termux_repositories
  import "@/modules/language"
  install_language

	echo
	separator
	log_success "Base installation completed"
	separator
	echo
}

# Función principal
setup_main() {
	# Verificar si se pasó un argumento para instalación no interactiva
	if [[ $# -gt 0 ]]; then
		case "$1" in
		full)
			install_full
			return
			;;
		base)
			install_base
			return
			;;
		*)
			log_error "Unknown option: $1"
			echo "Usage: core setup [full|base]"
			return 1
			;;
		esac
	fi

	# Modo interactivo
	show_banner

	# Menú principal con read_select
	local main_choice=""
	read_select "Select installation type" main_choice \
		"Full installation (recommended)" \
		"Custom installation" \
		"Base installation" \
		"Cancel"

	echo
	case "$main_choice" in
	"Full installation (recommended)")
		install_full
		;;
	"Custom installation")
		install_custom
		;;
	"Base installation")
		install_base
		;;
	"Cancel")
		log_warn "Setup cancelled"
		;;
	esac
}
