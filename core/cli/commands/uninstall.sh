#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

uninstall_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Uninstall"
		echo
		log_info "Usage: core uninstall <target>"
		log_info "Usage: core uninstall <target> --tool1 --tool2"
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
    list_item "automation - Remove automation tools"
		echo
		log_info "Uninstall specific tools with flags:"
		echo
		list_item "core uninstall ai --qwen-code --ollama"
		list_item "core uninstall db --postgresql --sqlite"
		list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
		echo
		log_warn "Warning: This will remove installed packages and configurations!"
		echo
		return
	fi

	# Separate module target from tool flags
	local module_target=""
	local -a tool_flags=()

	for arg in "$@"; do
		if [[ "$arg" == --* ]]; then
			local flag="${arg#--}"
			tool_flags+=("$flag")
		elif [[ -z "$module_target" ]]; then
			module_target="$arg"
		fi
	done

	# If no module target specified, show error
	if [[ -z "$module_target" ]]; then
		log_error "No target specified"
		echo "Run 'core uninstall' to see available targets"
		return 1
	fi

	# If no tool flags, uninstall entire module (original behavior)
	if [[ ${#tool_flags[@]} -eq 0 ]]; then
		_uninstall_full_module "$module_target"
	else
		# Uninstall specific tools
		_uninstall_specific_tools "$module_target" "${tool_flags[@]}"
	fi
}

# Uninstall entire module (original behavior)
_uninstall_full_module() {
	local target="$1"

	case "$target" in
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
		import "@/modules/automation"

		uninstall_ai
		uninstall_db
		uninstall_editor
		uninstall_language
		uninstall_node
		uninstall_tools
		uninstall_shell
		uninstall_ui
		uninstall_localtunnel_fix
      uninstall_automation

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
    automation)
      import "@/modules/automation"
      uninstall_automation
      ;;
	*)
		log_warn "Unknown uninstall target: $target"
		echo "Run 'core uninstall' to see available targets"
		;;
	esac
}

# Uninstall specific tools within a module
_uninstall_specific_tools() {
	local module="$1"
	shift
	local -a tools=("$@")

	case "$module" in
	ai)
		import "@/tools/ai/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			qwen-code)
				if uninstall_qwen_code; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			gemini-cli)
				if uninstall_gemini_cli; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			claude-code)
				if uninstall_claude_code; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mistral-vibe)
				if uninstall_mistral_vibe; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			openclaude)
				if uninstall_openclaude; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			openclaw)
				if uninstall_openclaw; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ollama)
				if uninstall_ollama; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown AI tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count AI tool(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to uninstall"
		fi
		echo
		;;
	db)
		import "@/tools/db/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			postgresql)
				if uninstall_postgresql; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mariadb)
				if uninstall_mariadb; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			sqlite)
				if uninstall_sqlite; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mongodb)
				if uninstall_mongodb; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown database: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count database(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count database(s) failed to uninstall"
		fi
		echo
		;;
	tools)
		import "@/tools/tools/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			gh)
				if uninstall_gh; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			wget)
				if uninstall_wget; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			curl)
				if uninstall_curl; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			lsd)
				if uninstall_lsd; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			bat)
				if uninstall_bat; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			proot)
				if uninstall_proot; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ncurses)
				if uninstall_ncurses; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			tmate)
				if uninstall_tmate; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			cloudflared)
				if uninstall_cloudflared; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			translate)
				if uninstall_translate; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			html2text)
				if uninstall_html2text; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			jq)
				if uninstall_jq; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			bc)
				if uninstall_bc; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			tree)
				if uninstall_tree; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			fzf)
				if uninstall_fzf; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			imagemagick)
				if uninstall_imagemagick; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			shfmt)
				if uninstall_shfmt; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			make)
				if uninstall_make; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count tool(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to uninstall"
		fi
		echo
		;;
	node)
		import "@/tools/node/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			typescript)
				if uninstall_typescript; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			nestjs)
				if uninstall_nestjs; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			prettier)
				if uninstall_prettier; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			live-server)
				if uninstall_live_server; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			localtunnel)
				if uninstall_localtunnel; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			vercel)
				if uninstall_vercel; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			markserv)
				if uninstall_markserv; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			psqlformat)
				if uninstall_psqlformat; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ncu)
				if uninstall_ncu; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ngrok)
				if uninstall_ngrok; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown node module: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count Node.js module(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count module(s) failed to uninstall"
		fi
		echo
		;;
	language)
		import "@/tools/language/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			nodejs)
				if uninstall_nodejs; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			python)
				if uninstall_python; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			perl)
				if uninstall_perl; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			php)
				if uninstall_php; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			rust)
				if uninstall_rust; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			clang)
				if uninstall_clang; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown language: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count language(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count language(s) failed to uninstall"
		fi
		echo
		;;
	shell)
		import "@/tools/shell/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			powerlevel10k)
				if uninstall_powerlevel10k; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-defer)
				if uninstall_zsh_defer; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-autosuggestions)
				if uninstall_zsh_autosuggestions; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-syntax-highlighting)
				if uninstall_zsh_syntax_highlighting; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			history-substring)
				if uninstall_history_substring; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-completions)
				if uninstall_zsh_completions; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			fzf-tab)
				if uninstall_fzf_tab; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			you-should-use)
				if uninstall_you_should_use; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-autopair)
				if uninstall_zsh_autopair; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			better-npm)
				if uninstall_better_npm; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown plugin: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count plugin(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count plugin(s) failed to uninstall"
		fi
		echo
		;;
	editor)
		import "@/tools/editor/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			neovim)
				if uninstall_neovim; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			nvchad)
				if uninstall_nvchad; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown editor component: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count editor component(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to uninstall"
		fi
		echo
		;;
	ui)
		import "@/tools/ui/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			font)
				if uninstall_font; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			extra-keys)
				if uninstall_extra_keys; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			cursor)
				if uninstall_cursor; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown UI component: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count UI component(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to uninstall"
		fi
		echo
		;;
	automation)
		import "@/tools/automation/all"
		local uninstalled_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			n8n)
				if uninstall_n8n; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown automation tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $uninstalled_count -gt 0 ]]; then
			log_success "$uninstalled_count automation tool(s) uninstalled"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to uninstall"
		fi
		echo
		;;
	*)
		log_warn "Unknown uninstall target: $module"
		echo "Run 'core uninstall' to see available targets"
		;;
	esac
}
