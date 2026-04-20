#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

install_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core Install"
		echo
		log_info "Usage: core install <target>"
		log_info "Usage: core install <target> --tool1 --tool2"
		echo
		log_info "Available targets:"
		echo
		list_item "full       - Install everything (recommended)"
		list_item "language   - Language packages (Node.js, Python, Perl, PHP, Rust, C, C++)"
		list_item "db         - Databases (PostgreSQL, MariaDB, SQLite, MongoDB)"
		list_item "ai         - AI tools (Qwen Code, Gemini CLI, Mistral Vibe, OpenClaude, Claude Code, OpenClaw, Ollama, Codex, OpenCode)"
		list_item "editor     - Code editor (Neovim + NvChad)"
		list_item "tools      - Development tools"
		list_item "node       - Node.js global modules (npm packages)"
		list_item "shell      - ZSH + Oh My Zsh + plugins"
		list_item "ui         - Termux UI (font, cursor, extra-keys)"
		list_item "automation - Automation Tools (n8n)"

		echo
		log_info "Install specific tools with flags:"
		echo
		list_item "core install ai --qwen-code --ollama"
		list_item "core install db --postgresql --sqlite"
		list_item "core install tools --gh --fzf --jq"
		list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
		echo
		return
	fi

	# Separate module target from tool flags
	local module_target=""
	local -a tool_flags=()

	for arg in "$@"; do
		if [[ "$arg" == --* ]]; then
			# Remove -- prefix and convert to lowercase
			local flag="${arg#--}"
			tool_flags+=("$flag")
		elif [[ -z "$module_target" ]]; then
			module_target="$arg"
		fi
	done

	# If no module target specified, show error
	if [[ -z "$module_target" ]]; then
		log_error "No target specified"
		echo "Run 'core install' to see available targets"
		return 1
	fi

	# If no tool flags, install entire module (original behavior)
	if [[ ${#tool_flags[@]} -eq 0 ]]; then
		_install_full_module "$module_target"
	else
		# Install specific tools
		_install_specific_tools "$module_target" "${tool_flags[@]}"
	fi
}

# Install entire module (original behavior)
_install_full_module() {
	local target="$1"

	case "$target" in
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
		log_warn "Unknown install target: $target"
		echo "Run 'core install' to see available targets"
		;;
	esac
}

# Install specific tools within a module
_install_specific_tools() {
	local module="$1"
	shift
	local -a tools=("$@")

	case "$module" in
	ai)
		import "@/tools/ai/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			qwen-code)
				if loading "Installing Qwen Code" install_qwen_code; then ((installed_count++)); else ((failed_count++)); fi
				;;
			gemini-cli)
				if loading "Installing Gemini CLI" install_gemini_cli; then ((installed_count++)); else ((failed_count++)); fi
				;;
			claude-code)
				if loading "Installing Claude Code" install_claude_code; then ((installed_count++)); else ((failed_count++)); fi
				;;
			mistral-vibe)
				if loading "Installing Mistral Vibe" install_mistral_vibe; then ((installed_count++)); else ((failed_count++)); fi
				;;
			openclaude)
				if loading "Installing OpenClaude" install_openclaude; then ((installed_count++)); else ((failed_count++)); fi
				;;
			openclaw)
				if loading "Installing OpenClaw" install_openclaw; then ((installed_count++)); else ((failed_count++)); fi
				;;
			ollama)
				if loading "Installing Ollama" install_ollama; then ((installed_count++)); else ((failed_count++)); fi
				;;
			codex)
				if loading "Installing Codex" install_codex; then ((installed_count++)); else ((failed_count++)); fi
				;;
			opencode)
				if loading "Installing OpenCode" install_opencode; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown AI tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count AI tool(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to install"
		fi
		echo
		;;
	db)
		import "@/tools/db/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			postgresql)
				if loading "Installing PostgreSQL" install_postgresql; then ((installed_count++)); else ((failed_count++)); fi
				;;
			mariadb)
				if loading "Installing MariaDB" install_mariadb; then ((installed_count++)); else ((failed_count++)); fi
				;;
			sqlite)
				if loading "Installing SQLite" install_sqlite; then ((installed_count++)); else ((failed_count++)); fi
				;;
			mongodb)
				if loading "Installing MongoDB" install_mongodb; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown database: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count database(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count database(s) failed to install"
		fi
		echo
		;;
	tools)
		import "@/tools/tools/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			gh)
				if loading "Installing GitHub CLI" install_gh; then ((installed_count++)); else ((failed_count++)); fi
				;;
			wget)
				if loading "Installing Wget" install_wget; then ((installed_count++)); else ((failed_count++)); fi
				;;
			curl)
				if loading "Installing Curl" install_curl; then ((installed_count++)); else ((failed_count++)); fi
				;;
			lsd)
				if loading "Installing LSD" install_lsd; then ((installed_count++)); else ((failed_count++)); fi
				;;
			bat)
				if loading "Installing Bat" install_bat; then ((installed_count++)); else ((failed_count++)); fi
				;;
			proot)
				if loading "Installing Proot" install_proot; then ((installed_count++)); else ((failed_count++)); fi
				;;
			ncurses)
				if loading "Installing Ncurses Utils" install_ncurses; then ((installed_count++)); else ((failed_count++)); fi
				;;
			tmate)
				if loading "Installing Tmate" install_tmate; then ((installed_count++)); else ((failed_count++)); fi
				;;
			cloudflared)
				if loading "Installing Cloudflared" install_cloudflared; then ((installed_count++)); else ((failed_count++)); fi
				;;
			translate)
				if loading "Installing Translate Shell" install_translate; then ((installed_count++)); else ((failed_count++)); fi
				;;
			html2text)
				if loading "Installing html2text" install_html2text; then ((installed_count++)); else ((failed_count++)); fi
				;;
			jq)
				if loading "Installing jq" install_jq; then ((installed_count++)); else ((failed_count++)); fi
				;;
			bc)
				if loading "Installing bc" install_bc; then ((installed_count++)); else ((failed_count++)); fi
				;;
			tree)
				if loading "Installing Tree" install_tree; then ((installed_count++)); else ((failed_count++)); fi
				;;
			fzf)
				if loading "Installing Fzf" install_fzf; then ((installed_count++)); else ((failed_count++)); fi
				;;
			imagemagick)
				if loading "Installing ImageMagick" install_imagemagick; then ((installed_count++)); else ((failed_count++)); fi
				;;
			shfmt)
				if loading "Installing Shfmt" install_shfmt; then ((installed_count++)); else ((failed_count++)); fi
				;;
			make)
				if loading "Installing Make" install_make; then ((installed_count++)); else ((failed_count++)); fi
				;;
			udocker)
				if loading "Installing udocker" install_udocker; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count tool(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to install"
		fi
		echo
		;;
	node)
		import "@/tools/node/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			typescript)
				if loading "Installing TypeScript" install_typescript; then ((installed_count++)); else ((failed_count++)); fi
				;;
			nestjs)
				if loading "Installing NestJS CLI" install_nestjs; then ((installed_count++)); else ((failed_count++)); fi
				;;
			prettier)
				if loading "Installing Prettier" install_prettier; then ((installed_count++)); else ((failed_count++)); fi
				;;
			live-server)
				if loading "Installing Live Server" install_live_server; then ((installed_count++)); else ((failed_count++)); fi
				;;
			localtunnel)
				if loading "Installing Localtunnel" install_localtunnel; then ((installed_count++)); else ((failed_count++)); fi
				;;
			vercel)
				if loading "Installing Vercel CLI" install_vercel; then ((installed_count++)); else ((failed_count++)); fi
				;;
			markserv)
				if loading "Installing Markserv" install_markserv; then ((installed_count++)); else ((failed_count++)); fi
				;;
			psqlformat)
				if loading "Installing PSQL Format" install_psqlformat; then ((installed_count++)); else ((failed_count++)); fi
				;;
			ncu)
				if loading "Installing NPM Check Updates" install_ncu; then ((installed_count++)); else ((failed_count++)); fi
				;;
			ngrok)
				if loading "Installing Ngrok" install_ngrok; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown node module: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count Node.js module(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count module(s) failed to install"
		fi
		echo
		;;
	language)
		import "@/tools/language/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			nodejs)
				if loading "Installing Node.js LTS" install_nodejs; then ((installed_count++)); else ((failed_count++)); fi
				;;
			python)
				if loading "Installing Python" install_python; then ((installed_count++)); else ((failed_count++)); fi
				;;
			perl)
				if loading "Installing Perl" install_perl; then ((installed_count++)); else ((failed_count++)); fi
				;;
			php)
				if loading "Installing PHP" install_php; then ((installed_count++)); else ((failed_count++)); fi
				;;
			rust)
				if loading "Installing Rust" install_rust; then ((installed_count++)); else ((failed_count++)); fi
				;;
			clang)
				if loading "Installing C/C++ (clang)" install_clang; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown language: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count language(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count language(s) failed to install"
		fi
		echo
		;;
	shell)
		import "@/tools/shell/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			powerlevel10k)
				if loading "Installing powerlevel10k" install_powerlevel10k; then ((installed_count++)); else ((failed_count++)); fi
				;;
			zsh-defer)
				if loading "Installing zsh-defer" install_zsh_defer; then ((installed_count++)); else ((failed_count++)); fi
				;;
			zsh-autosuggestions)
				if loading "Installing zsh-autosuggestions" install_zsh_autosuggestions; then ((installed_count++)); else ((failed_count++)); fi
				;;
			zsh-syntax-highlighting)
				if loading "Installing zsh-syntax-highlighting" install_zsh_syntax_highlighting; then ((installed_count++)); else ((failed_count++)); fi
				;;
			history-substring)
				if loading "Installing zsh-history-substring-search" install_history_substring; then ((installed_count++)); else ((failed_count++)); fi
				;;
			zsh-completions)
				if loading "Installing zsh-completions" install_zsh_completions; then ((installed_count++)); else ((failed_count++)); fi
				;;
			fzf-tab)
				if loading "Installing fzf-tab" install_fzf_tab; then ((installed_count++)); else ((failed_count++)); fi
				;;
			you-should-use)
				if loading "Installing zsh-you-should-use" install_you_should_use; then ((installed_count++)); else ((failed_count++)); fi
				;;
			zsh-autopair)
				if loading "Installing zsh-autopair" install_zsh_autopair; then ((installed_count++)); else ((failed_count++)); fi
				;;
			better-npm)
				if loading "Installing zsh-better-npm-completion" install_better_npm; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown plugin: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count plugin(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count plugin(s) failed to install"
		fi
		echo
		;;
	editor)
		import "@/tools/editor/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			neovim)
				if loading "Installing Neovim" install_neovim; then ((installed_count++)); else ((failed_count++)); fi
				;;
			nvchad)
				if loading "Installing NvChad" install_nvchad; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown editor component: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count editor component(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to install"
		fi
		echo
		;;
	ui)
		import "@/tools/ui/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			font)
				if loading "Installing Meslo Nerd Font" install_font; then ((installed_count++)); else ((failed_count++)); fi
				;;
			extra-keys)
				if loading "Configuring Extra Keys" install_extra_keys; then ((installed_count++)); else ((failed_count++)); fi
				;;
			cursor)
				if loading "Configuring Cursor Color" install_cursor; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown UI component: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count UI component(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count component(s) failed to install"
		fi
		echo
		;;
	automation)
		import "@/tools/automation/all"
		local installed_count=0
		local failed_count=0

		for tool in "${tools[@]}"; do
			case "$tool" in
			n8n)
				if loading "Installing n8n" install_n8n; then ((installed_count++)); else ((failed_count++)); fi
				;;
			*)
				log_warn "Unknown automation tool: --$tool"
				;;
			esac
		done

		echo
		if [[ $installed_count -gt 0 ]]; then
			log_success "$installed_count automation tool(s) installed"
		fi
		if [[ $failed_count -gt 0 ]]; then
			log_warn "$failed_count tool(s) failed to install"
		fi
		echo
		;;
	*)
		log_warn "Unknown install target: $module"
		echo "Run 'core install' to see available targets"
		;;
	esac
}
