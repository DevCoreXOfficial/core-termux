#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

list_main() {

	if [[ $# -eq 0 ]]; then
		echo
		box "Core List"
		echo
		log_info "Usage: core list <target>"
		echo
		log_info "Available targets:"
		echo
		list_item "language   - List language packages"
		list_item "db         - List database packages"
		list_item "ai         - List AI tools"
		list_item "editor     - List code editor components"
		list_item "tools      - List development tools"
		list_item "node       - List Node.js global modules"
		list_item "shell      - List ZSH plugins"
		list_item "ui         - List Termux UI components"
		list_item "automation - List automation tools"
		echo
		return
	fi

	for arg in "$@"; do
		case "$arg" in
		language)
			_list_language
			;;
		db)
			_list_db
			;;
		ai)
			_list_ai
			;;
		editor)
			_list_editor
			;;
		tools)
			_list_tools
			;;
		node)
			_list_node
			;;
		shell)
			_list_shell
			;;
		ui)
			_list_ui
			;;
		automation)
			_list_automation
			;;
		*)
			log_warn "Unknown list target: $arg"
			echo "Run 'core list' to see available targets"
			;;
		esac
	done
}

# ===== LIST LANGUAGE =====
_list_language() {
	echo
	box "Language Packages"
	echo
	log_info "Available packages and install commands:"
	echo

	table_start "Package" "Install Flag" "Status"
	table_row "Node.js LTS" "--nodejs" "$(_check_pkg "nodejs-lts")"
	table_row "Python" "--python" "$(_check_pkg "python")"
	table_row "Perl" "--perl" "$(_check_pkg "perl")"
	table_row "PHP" "--php" "$(_check_pkg "php")"
	table_row "Rust" "--rust" "$(_check_pkg "rust")"
	table_row "C/C++ (clang)" "--clang" "$(_check_pkg "clang")"
	table_row "Go (golang)" "--golang" "$(_check_pkg "golang")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install language --nodejs --python${NC}"
	log_info "Install all: ${D_CYAN}core install language${NC}"
	echo
}

# ===== LIST DB =====
_list_db() {
	echo
	box "Database Packages"
	echo
	log_info "Available packages and install commands:"
	echo

	table_start "Database" "Install Flag" "Status"
	table_row "PostgreSQL" "--postgresql" "$(_check_pkg "postgresql")"
	table_row "MariaDB" "--mariadb" "$(_check_pkg "mariadb")"
	table_row "SQLite" "--sqlite" "$(_check_pkg "sqlite")"
	table_row "MongoDB" "--mongodb" "$(_check_pkg "mongodb")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install db --postgresql --sqlite${NC}"
	log_info "Install all: ${D_CYAN}core install db${NC}"
	echo
}

# ===== LIST AI =====
_list_ai() {
	echo
	box "AI Tools"
	echo
	log_info "Available AI tools and install commands:"
	echo

	table_start "Tool" "Install Flag" "Command" "Status"
	table_row "Qwen Code" "--qwen-code" "qwen" "$(_check_cmd "qwen")"
	table_row "Gemini CLI" "--gemini-cli" "gemini" "$(_check_cmd "gemini")"
	table_row "Claude Code" "--claude-code" "claude" "$(_check_cmd "claude")"
	table_row "Mistral Vibe" "--mistral-vibe" "vibe" "$(_check_cmd "vibe")"
	table_row "OpenClaude" "--openclaude" "openclaude" "$(_check_cmd "openclaude")"
	table_row "OpenClaw" "--openclaw" "openclaw" "$(_check_cmd "openclaw")"
	table_row "Ollama" "--ollama" "ollama" "$(_check_pkg "ollama")"
	table_row "Codex" "--codex" "codex" "$(_check_pkg "codex")"
	table_row "OpenCode" "--opencode" "opencode" "$(_check_cmd "opencode")"
	table_row "Engram" "--engram" "engram" "$(_check_cmd "engram")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install ai --qwen-code --ollama${NC}"
	log_info "Install all: ${D_CYAN}core install ai${NC}"
	echo
}

# ===== LIST EDITOR =====
_list_editor() {
	echo
	box "Code Editor"
	echo
	log_info "Available components and install commands:"
	echo

	table_start "Component" "Install Flag" "Status"
	table_row "Neovim" "--neovim" "$(_check_pkg "neovim")"
	table_row "NvChad Config" "--nvchad" "$(_check_dir "$HOME/.config/nvim")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install editor --neovim${NC}"
	log_info "Install all: ${D_CYAN}core install editor${NC}"
	echo
}

# ===== LIST TOOLS =====
_list_tools() {
	echo
	box "Development Tools"
	echo
	log_info "Available tools and install commands:"
	echo

	table_start "Tool" "Install Flag" "Status"
	table_row "GitHub CLI" "--gh" "$(_check_pkg "gh")"
	table_row "Wget" "--wget" "$(_check_pkg "wget")"
	table_row "Curl" "--curl" "$(_check_pkg "curl")"
	table_row "LSD" "--lsd" "$(_check_pkg "lsd")"
	table_row "Bat" "--bat" "$(_check_pkg "bat")"
	table_row "Proot" "--proot" "$(_check_pkg "proot")"
	table_row "Ncurses Utils" "--ncurses" "$(_check_pkg "ncurses-utils")"
	table_row "Tmate" "--tmate" "$(_check_pkg "tmate")"
	table_row "Cloudflared" "--cloudflared" "$(_check_pkg "cloudflared")"
	table_row "Translate Shell" "--translate" "$(_check_pkg "translate-shell")"
	table_row "html2text" "--html2text" "$(_check_pkg "html2text")"
	table_row "jq" "--jq" "$(_check_pkg "jq")"
	table_row "bc" "--bc" "$(_check_pkg "bc")"
	table_row "Tree" "--tree" "$(_check_pkg "tree")"
	table_row "Fzf" "--fzf" "$(_check_pkg "fzf")"
	table_row "ImageMagick" "--imagemagick" "$(_check_pkg "imagemagick")"
	table_row "Shfmt" "--shfmt" "$(_check_pkg "shfmt")"
	table_row "Make" "--make" "$(_check_pkg "make")"
	table_row "Udocker" "--udocker" "$(_check_pkg "udocker")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install tools --gh --fzf --jq${NC}"
	log_info "Install all: ${D_CYAN}core install tools${NC}"
	echo
}

# ===== LIST NODE =====
_list_node() {
	echo
	box "Node.js Global Modules"
	echo
	log_info "Available modules and install commands:"
	echo

	table_start "Module" "Install Flag" "Command" "Status"
	table_row "TypeScript" "--typescript" "tsc" "$(_check_cmd "tsc")"
	table_row "NestJS CLI" "--nestjs" "nest" "$(_check_cmd "nest")"
	table_row "Prettier" "--prettier" "prettier" "$(_check_cmd "prettier")"
	table_row "Live Server" "--live-server" "live-server" "$(_check_cmd "live-server")"
	table_row "Localtunnel" "--localtunnel" "lt" "$(_check_cmd "lt")"
	table_row "Vercel CLI" "--vercel" "vercel" "$(_check_cmd "vercel")"
	table_row "Markserv" "--markserv" "markserv" "$(_check_cmd "markserv")"
	table_row "PSQL Format" "--psqlformat" "psqlformat" "$(_check_cmd "psqlformat")"
	table_row "NPM Check Updates" "--ncu" "ncu" "$(_check_cmd "ncu")"
	table_row "Ngrok" "--ngrok" "ngrok" "$(_check_cmd "ngrok")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install node --typescript --prettier${NC}"
	log_info "Install all: ${D_CYAN}core install node${NC}"
	echo
}

# ===== LIST SHELL =====
_list_shell() {
	echo
	box "ZSH Shell Plugins"
	echo
	log_info "Available plugins and install commands:"
	echo

	table_start "Plugin" "Install Flag" "Status"
	table_row "powerlevel10k" "--powerlevel10k" "$(_check_plugin "powerlevel10k")"
	table_row "zsh-defer" "--zsh-defer" "$(_check_plugin "zsh-defer")"
	table_row "zsh-autosuggestions" "--zsh-autosuggestions" "$(_check_plugin "zsh-autosuggestions")"
	table_row "zsh-syntax-highlighting" "--zsh-syntax-highlighting" "$(_check_plugin "zsh-syntax-highlighting")"
	table_row "zsh-history-substring-search" "--history-substring" "$(_check_plugin "zsh-history-substring-search")"
	table_row "zsh-completions" "--zsh-completions" "$(_check_plugin "zsh-completions")"
	table_row "fzf-tab" "--fzf-tab" "$(_check_plugin "fzf-tab")"
	table_row "zsh-you-should-use" "--you-should-use" "$(_check_plugin "zsh-you-should-use")"
	table_row "zsh-autopair" "--zsh-autopair" "$(_check_plugin "zsh-autopair")"
	table_row "zsh-better-npm-completion" "--better-npm" "$(_check_plugin "zsh-better-npm-completion")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install shell --powerlevel10k --fzf-tab${NC}"
	log_info "Install all: ${D_CYAN}core install shell${NC}"
	echo
}

# ===== LIST UI =====
_list_ui() {
	echo
	box "Termux UI Components"
	echo
	log_info "Available components and install commands:"
	echo

	table_start "Component" "Install Flag" "Status"
	table_row "Meslo Nerd Font" "--font" "$(_check_file "$HOME/.termux/font.ttf")"
	table_row "Extra Keys" "--extra-keys" "$(_check_file "$HOME/.termux/termux.properties")"
	table_row "Cursor Color" "--cursor" "$(_check_file "$HOME/.termux/colors.properties")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install ui --font --extra-keys${NC}"
	log_info "Install all: ${D_CYAN}core install ui${NC}"
	echo
}

# ===== LIST AUTOMATION =====
_list_automation() {
	echo
	box "Automation Tools"
	echo
	log_info "Available tools and install commands:"
	echo

	table_start "Tool" "Install Flag" "Command" "Status"
	table_row "n8n" "--n8n" "n8n" "$(_check_cmd "n8n")"
	table_end

	echo
	log_info "Install specific: ${D_CYAN}core install automation --n8n${NC}"
	log_info "Install all: ${D_CYAN}core install automation${NC}"
	echo
}

# ===== HELPER FUNCTIONS =====

# Check if command exists
_check_cmd() {
	local cmd="$1"
	if command -v "$cmd" &>/dev/null; then
		echo -e "${D_GREEN}installed${NC}"
	else
		echo -e "${D_RED}not installed${NC}"
	fi
}

# Check if package is installed via pkg
_check_pkg() {
	local pkg="$1"
	if dpkg -s "$pkg" 2>/dev/null | grep -q "Status: install ok installed"; then
		echo -e "${D_GREEN}installed${NC}"
	else
		echo -e "${D_RED}not installed${NC}"
	fi
}

# Check if directory exists
_check_dir() {
	local dir="$1"
	if [[ -d "$dir" ]]; then
		echo -e "${D_GREEN}installed${NC}"
	else
		echo -e "${D_RED}not installed${NC}"
	fi
}

# Check if file exists
_check_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		echo -e "${D_GREEN}installed${NC}"
	else
		echo -e "${D_RED}not installed${NC}"
	fi
}

# Check if ZSH plugin exists
_check_plugin() {
	local plugin="$1"
	if [[ -d "$HOME/.zsh-plugins/$plugin" ]]; then
		echo -e "${D_GREEN}installed${NC}"
	else
		echo -e "${D_RED}not installed${NC}"
	fi
}
