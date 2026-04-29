#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

update_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Update"
		echo
		log_info "Usage: core update <target>"
		log_info "Usage: core update <target> --tool1 --tool2"
		echo
		log_info "Available targets:"
		echo
		list_item "all        - Update framework + all installed packages"
		list_item "core       - Update only Core-Termux framework"
		list_item "language   - Update language packages (pkg upgrade)"
		list_item "db         - Update databases"
		list_item "ai         - Update AI tools (npm/pip/pkg)"
		list_item "editor     - Update Neovim configuration"
		list_item "tools      - Update development tools"
		list_item "node       - Update Node.js global modules"
		list_item "shell      - Update ZSH plugins"
		list_item "ui         - Update Termux UI"
		list_item "automation - Update Automation Tools"
		echo
		log_info "Update specific tools with flags:"
		echo
		list_item "core update ai --qwen-code --ollama"
		list_item "core update db --postgresql --sqlite"
		list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
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
		echo "Run 'core update' to see available targets"
		return 1
	fi

	# If no tool flags, update entire module (original behavior)
	if [[ ${#tool_flags[@]} -eq 0 ]]; then
		_update_full_module "$module_target"
	else
		# Update specific tools
		_update_specific_tools "$module_target" "${tool_flags[@]}"
	fi
}

# Update entire module (original behavior)
_update_full_module() {
	local target="$1"

	case "$target" in
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
		log_warn "Unknown update target: $target"
		echo "Run 'core update' to see available targets"
		;;
	esac
}

# Update specific tools within a module
_update_specific_tools() {
	local module="$1"
	shift
	local -a tools=("$@")

	case "$module" in
	ai)
		import "@/tools/ai/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			qwen-code)
				if loading "Updating Qwen Code" update_qwen_code; then ((updated_count++)); else ((failed_count++)); fi
				;;
			gemini-cli)
				if loading "Updating Gemini CLI" update_gemini_cli; then ((updated_count++)); else ((failed_count++)); fi
				;;
			claude-code)
				if loading "Updating Claude Code" update_claude_code; then ((updated_count++)); else ((failed_count++)); fi
				;;
			mistral-vibe)
				if loading "Updating Mistral Vibe" update_mistral_vibe; then ((updated_count++)); else ((failed_count++)); fi
				;;
			openclaude)
				if loading "Updating OpenClaude" update_openclaude; then ((updated_count++)); else ((failed_count++)); fi
				;;
			openclaw)
				if loading "Updating OpenClaw" update_openclaw; then ((updated_count++)); else ((failed_count++)); fi
				;;
			ollama)
				if loading "Updating Ollama" update_ollama; then ((updated_count++)); else ((failed_count++)); fi
				;;
			codex)
				if loading "Updating Codex" update_codex; then ((updated_count++)); else ((failed_count++)); fi
				;;
			opencode)
				if loading "Updating OpenCode" update_opencode; then ((updated_count++)); else ((failed_count++)); fi
				;;
			engram)
				if loading "Updating Engram" update_engram; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown AI tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count AI tool(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to update"
		fi
		echo
		;;
	db)
		import "@/tools/db/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			postgresql)
				if loading "Updating PostgreSQL" update_postgresql; then ((updated_count++)); else ((failed_count++)); fi
				;;
			mariadb)
				if loading "Updating MariaDB" update_mariadb; then ((updated_count++)); else ((failed_count++)); fi
				;;
			sqlite)
				if loading "Updating SQLite" update_sqlite; then ((updated_count++)); else ((failed_count++)); fi
				;;
			mongodb)
				if loading "Updating MongoDB" update_mongodb; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown database: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count database(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count database(s) failed to update"
		fi
		echo
		;;
	tools)
		import "@/tools/tools/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			gh)
				if loading "Updating GitHub CLI" update_gh; then ((updated_count++)); else ((failed_count++)); fi
				;;
			wget)
				if loading "Updating Wget" update_wget; then ((updated_count++)); else ((failed_count++)); fi
				;;
			curl)
				if loading "Updating Curl" update_curl; then ((updated_count++)); else ((failed_count++)); fi
				;;
			lsd)
				if loading "Updating LSD" update_lsd; then ((updated_count++)); else ((failed_count++)); fi
				;;
			bat)
				if loading "Updating Bat" update_bat; then ((updated_count++)); else ((failed_count++)); fi
				;;
			proot)
				if loading "Updating Proot" update_proot; then ((updated_count++)); else ((failed_count++)); fi
				;;
			ncurses)
				if loading "Updating Ncurses Utils" update_ncurses; then ((updated_count++)); else ((failed_count++)); fi
				;;
			tmate)
				if loading "Updating Tmate" update_tmate; then ((updated_count++)); else ((failed_count++)); fi
				;;
			cloudflared)
				if loading "Updating Cloudflared" update_cloudflared; then ((updated_count++)); else ((failed_count++)); fi
				;;
			translate)
				if loading "Updating Translate Shell" update_translate; then ((updated_count++)); else ((failed_count++)); fi
				;;
			html2text)
				if loading "Updating html2text" update_html2text; then ((updated_count++)); else ((failed_count++)); fi
				;;
			jq)
				if loading "Updating jq" update_jq; then ((updated_count++)); else ((failed_count++)); fi
				;;
			bc)
				if loading "Updating bc" update_bc; then ((updated_count++)); else ((failed_count++)); fi
				;;
			tree)
				if loading "Updating Tree" update_tree; then ((updated_count++)); else ((failed_count++)); fi
				;;
			fzf)
				if loading "Updating Fzf" update_fzf; then ((updated_count++)); else ((failed_count++)); fi
				;;
			imagemagick)
				if loading "Updating ImageMagick" update_imagemagick; then ((updated_count++)); else ((failed_count++)); fi
				;;
			shfmt)
				if loading "Updating Shfmt" update_shfmt; then ((updated_count++)); else ((failed_count++)); fi
				;;
			make)
				if loading "Updating Make" update_make; then ((updated_count++)); else ((failed_count++)); fi
				;;
			udocker)
				if loading "Updating Udocker" update_udocker; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count tool(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to update"
		fi
		echo
		;;
	node)
		import "@/tools/node/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			typescript)
				if loading "Updating TypeScript" update_typescript; then ((updated_count++)); else ((failed_count++)); fi
				;;
			nestjs)
				if loading "Updating NestJS CLI" update_nestjs; then ((updated_count++)); else ((failed_count++)); fi
				;;
			prettier)
				if loading "Updating Prettier" update_prettier; then ((updated_count++)); else ((failed_count++)); fi
				;;
			live-server)
				if loading "Updating Live Server" update_live_server; then ((updated_count++)); else ((failed_count++)); fi
				;;
			localtunnel)
				if loading "Updating Localtunnel" update_localtunnel; then ((updated_count++)); else ((failed_count++)); fi
				;;
			vercel)
				if loading "Updating Vercel CLI" update_vercel; then ((updated_count++)); else ((failed_count++)); fi
				;;
			markserv)
				if loading "Updating Markserv" update_markserv; then ((updated_count++)); else ((failed_count++)); fi
				;;
			psqlformat)
				if loading "Updating PSQL Format" update_psqlformat; then ((updated_count++)); else ((failed_count++)); fi
				;;
			ncu)
				if loading "Updating NPM Check Updates" update_ncu; then ((updated_count++)); else ((failed_count++)); fi
				;;
			ngrok)
				if loading "Updating Ngrok" update_ngrok; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown node module: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count Node.js module(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count module(s) failed to update"
		fi
		echo
		;;
	language)
		import "@/tools/language/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			nodejs)
				if loading "Updating Node.js LTS" update_nodejs; then ((updated_count++)); else ((failed_count++)); fi
				;;
			python)
				if loading "Updating Python" update_python; then ((updated_count++)); else ((failed_count++)); fi
				;;
			perl)
				if loading "Updating Perl" update_perl; then ((updated_count++)); else ((failed_count++)); fi
				;;
			php)
				if loading "Updating PHP" update_php; then ((updated_count++)); else ((failed_count++)); fi
				;;
			rust)
				if loading "Updating Rust" update_rust; then ((updated_count++)); else ((failed_count++)); fi
				;;
			clang)
				if loading "Updating C/C++ (clang)" update_clang; then ((updated_count++)); else ((failed_count++)); fi
				;;
			golang)
				if loading "Updating Go (golang)" update_golang; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown language: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count language(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count language(s) failed to update"
		fi
		echo
		;;
	shell)
		import "@/tools/shell/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			powerlevel10k)
				if loading "Updating powerlevel10k" update_powerlevel10k; then ((updated_count++)); else ((failed_count++)); fi
				;;
			zsh-defer)
				if loading "Updating zsh-defer" update_zsh_defer; then ((updated_count++)); else ((failed_count++)); fi
				;;
			zsh-autosuggestions)
				if loading "Updating zsh-autosuggestions" update_zsh_autosuggestions; then ((updated_count++)); else ((failed_count++)); fi
				;;
			zsh-syntax-highlighting)
				if loading "Updating zsh-syntax-highlighting" update_zsh_syntax_highlighting; then ((updated_count++)); else ((failed_count++)); fi
				;;
			history-substring)
				if loading "Updating zsh-history-substring-search" update_history_substring; then ((updated_count++)); else ((failed_count++)); fi
				;;
			zsh-completions)
				if loading "Updating zsh-completions" update_zsh_completions; then ((updated_count++)); else ((failed_count++)); fi
				;;
			fzf-tab)
				if loading "Updating fzf-tab" update_fzf_tab; then ((updated_count++)); else ((failed_count++)); fi
				;;
			you-should-use)
				if loading "Updating zsh-you-should-use" update_you_should_use; then ((updated_count++)); else ((failed_count++)); fi
				;;
			zsh-autopair)
				if loading "Updating zsh-autopair" update_zsh_autopair; then ((updated_count++)); else ((failed_count++)); fi
				;;
			better-npm)
				if loading "Updating zsh-better-npm-completion" update_better_npm; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown plugin: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count plugin(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count plugin(s) failed to update"
		fi
		echo
		;;
	editor)
		import "@/tools/editor/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			neovim)
				if loading "Updating Neovim" update_neovim; then ((updated_count++)); else ((failed_count++)); fi
				;;
			nvchad)
				if loading "Updating NvChad" update_nvchad; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown editor component: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count editor component(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to update"
		fi
		echo
		;;
	ui)
		import "@/tools/ui/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			font)
				if loading "Updating Meslo Nerd Font" update_font; then ((updated_count++)); else ((failed_count++)); fi
				;;
			extra-keys)
				if loading "Updating Extra Keys" update_extra_keys; then ((updated_count++)); else ((failed_count++)); fi
				;;
			cursor)
				if loading "Updating Cursor Color" update_cursor; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown UI component: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count UI component(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to update"
		fi
		echo
		;;
	automation)
		import "@/tools/automation/all"
		local updated_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			n8n)
				if loading "Updating n8n" update_n8n; then ((updated_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown automation tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $updated_count -gt 0 ]]; then
			log_success "$updated_count automation tool(s) updated"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to update"
		fi
		echo
		;;
	*)
		log_warn "Unknown update target: $module"
		echo "Run 'core update' to see available targets"
		;;
	esac
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
