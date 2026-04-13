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
				if loading "Uninstalling Qwen Code" uninstall_qwen_code; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			gemini-cli)
				if loading "Uninstalling Gemini CLI" uninstall_gemini_cli; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			claude-code)
				if loading "Uninstalling Claude Code" uninstall_claude_code; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mistral-vibe)
				if loading "Uninstalling Mistral Vibe" uninstall_mistral_vibe; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			openclaude)
				if loading "Uninstalling OpenClaude" uninstall_openclaude; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			openclaw)
				if loading "Uninstalling OpenClaw" uninstall_openclaw; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ollama)
				if loading "Uninstalling Ollama" uninstall_ollama; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling PostgreSQL" uninstall_postgresql; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mariadb)
				if loading "Uninstalling MariaDB" uninstall_mariadb; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			sqlite)
				if loading "Uninstalling SQLite" uninstall_sqlite; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			mongodb)
				if loading "Uninstalling MongoDB" uninstall_mongodb; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling GitHub CLI" uninstall_gh; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			wget)
				if loading "Uninstalling Wget" uninstall_wget; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			curl)
				if loading "Uninstalling Curl" uninstall_curl; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			lsd)
				if loading "Uninstalling LSD" uninstall_lsd; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			bat)
				if loading "Uninstalling Bat" uninstall_bat; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			proot)
				if loading "Uninstalling Proot" uninstall_proot; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ncurses)
				if loading "Uninstalling Ncurses Utils" uninstall_ncurses; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			tmate)
				if loading "Uninstalling Tmate" uninstall_tmate; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			cloudflared)
				if loading "Uninstalling Cloudflared" uninstall_cloudflared; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			translate)
				if loading "Uninstalling Translate Shell" uninstall_translate; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			html2text)
				if loading "Uninstalling html2text" uninstall_html2text; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			jq)
				if loading "Uninstalling jq" uninstall_jq; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			bc)
				if loading "Uninstalling bc" uninstall_bc; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			tree)
				if loading "Uninstalling Tree" uninstall_tree; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			fzf)
				if loading "Uninstalling Fzf" uninstall_fzf; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			imagemagick)
				if loading "Uninstalling ImageMagick" uninstall_imagemagick; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			shfmt)
				if loading "Uninstalling Shfmt" uninstall_shfmt; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			make)
				if loading "Uninstalling Make" uninstall_make; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling TypeScript" uninstall_typescript; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			nestjs)
				if loading "Uninstalling NestJS CLI" uninstall_nestjs; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			prettier)
				if loading "Uninstalling Prettier" uninstall_prettier; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			live-server)
				if loading "Uninstalling Live Server" uninstall_live_server; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			localtunnel)
				if loading "Uninstalling Localtunnel" uninstall_localtunnel; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			vercel)
				if loading "Uninstalling Vercel CLI" uninstall_vercel; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			markserv)
				if loading "Uninstalling Markserv" uninstall_markserv; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			psqlformat)
				if loading "Uninstalling PSQL Format" uninstall_psqlformat; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ncu)
				if loading "Uninstalling NPM Check Updates" uninstall_ncu; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			ngrok)
				if loading "Uninstalling Ngrok" uninstall_ngrok; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling Node.js LTS" uninstall_nodejs; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			python)
				if loading "Uninstalling Python" uninstall_python; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			perl)
				if loading "Uninstalling Perl" uninstall_perl; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			php)
				if loading "Uninstalling PHP" uninstall_php; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			rust)
				if loading "Uninstalling Rust" uninstall_rust; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			clang)
				if loading "Uninstalling C/C++ (clang)" uninstall_clang; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling powerlevel10k" uninstall_powerlevel10k; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-defer)
				if loading "Uninstalling zsh-defer" uninstall_zsh_defer; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-autosuggestions)
				if loading "Uninstalling zsh-autosuggestions" uninstall_zsh_autosuggestions; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-syntax-highlighting)
				if loading "Uninstalling zsh-syntax-highlighting" uninstall_zsh_syntax_highlighting; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			history-substring)
				if loading "Uninstalling zsh-history-substring-search" uninstall_history_substring; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-completions)
				if loading "Uninstalling zsh-completions" uninstall_zsh_completions; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			fzf-tab)
				if loading "Uninstalling fzf-tab" uninstall_fzf_tab; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			you-should-use)
				if loading "Uninstalling zsh-you-should-use" uninstall_you_should_use; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			zsh-autopair)
				if loading "Uninstalling zsh-autopair" uninstall_zsh_autopair; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			better-npm)
				if loading "Uninstalling zsh-better-npm-completion" uninstall_better_npm; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling Neovim" uninstall_neovim; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			nvchad)
				if loading "Uninstalling NvChad" uninstall_nvchad; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling Meslo Nerd Font" uninstall_font; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			extra-keys)
				if loading "Uninstalling Extra Keys" uninstall_extra_keys; then ((uninstalled_count++)); else ((failed_count++)); fi
				;;
			cursor)
				if loading "Uninstalling Cursor Color" uninstall_cursor; then ((uninstalled_count++)); else ((failed_count++)); fi
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
				if loading "Uninstalling n8n" uninstall_n8n; then ((uninstalled_count++)); else ((failed_count++)); fi
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
