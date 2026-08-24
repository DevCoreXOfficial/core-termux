#!/usr/bin/env bash

BANNER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BANNER_FILE="$(cd "$BANNER_SCRIPT_DIR/../.." && pwd)/assets/banner/devcorex.txt"
BANNER_VERSION="$(grep "^CORE_VERSION=" "$BANNER_SCRIPT_DIR/env.sh" 2>/dev/null | cut -d'"' -f2)"

# ── Colors (self-contained for shell startup sourcing) ─────
DGREEN="\033[0;32m"
NC="\033[0m"
GRAY="\033[0;90m"
D_CYAN="\033[0;36m"

# ── Reusable tip function (matches log.sh style) ───────────
log_tip() {
	echo -e " ${D_CYAN}● Tip${NC} $*"
}

if [[ -f "$BANNER_FILE" ]]; then
	cat "$BANNER_FILE"
fi

if [[ -n "$BANNER_VERSION" ]]; then
	printf "\n"
	printf " ${GRAY}DevCoreX ${NC}Software Development Community${NC}\n"
	printf "     ${NC}Welcome to${GRAY} Core ${DGREEN}v%s${NC}\n" "$BANNER_VERSION"
	printf "  ${D_CYAN}One CLI — Your environment. Everywhere.${NC}\n"
	printf "        ${NC}Run ${DGREEN}core${NC} to get started${NC}\n"
fi

# ── Random Tip ──────────────────────────────────────────────

CORE_TIPS=(
	# ── Framework ─────────────────────────────────────────────
	"Keep Core updated: ${D_CYAN}core update core${NC}"
	"Check your version: ${D_CYAN}core --version${NC}"
	"Enable debug logs: ${D_CYAN}export CORE_DEBUG=1${NC}"
	"Open framework docs: ${D_CYAN}core open${NC}"

	# ── Search & Install ────────────────────────────────────
	"List every tool with status: ${D_CYAN}core s --all${NC}"
	"Find tools by keyword: ${D_CYAN}core search tunnel${NC} or ${D_CYAN}core search js${NC}"
	"Install a tool by name: ${D_CYAN}core i opencode${NC}"
	"Install several at once: ${D_CYAN}core i gh jq fzf${NC}"
	"Update a tool: ${D_CYAN}core up opencode${NC}"
	"Remove a tool: ${D_CYAN}core un opencode${NC}"
	"Reinstall from scratch: ${D_CYAN}core ri opencode${NC}"
	"Read tool docs: ${D_CYAN}core show opencode${NC}"
	"Spanish docs: ${D_CYAN}core show opencode:es${NC}"

	# ── Languages ──────────────────────────────────────────
	"Node.js LTS: ${D_CYAN}core i nodejs${NC}"
	"Python: ${D_CYAN}core i python${NC}"
	"Rust via rustup: ${D_CYAN}core i rust${NC}"
	"Go: ${D_CYAN}core i golang${NC}"
	"Bun runtime: ${D_CYAN}core i bun${NC}"
	"C/C++ compiler: ${D_CYAN}core i clang${NC}"
	"TypeScript compiler: ${D_CYAN}core i typescript${NC}"

	# ── Databases ──────────────────────────────────────────
	"Initialize PostgreSQL: ${D_CYAN}core pg init${NC}"
	"Start PostgreSQL: ${D_CYAN}core pg start${NC}"
	"Open psql shell: ${D_CYAN}core pg shell${NC}"
	"Create a database: ${D_CYAN}core pg create mydb${NC}"
	"Check PG status: ${D_CYAN}core pg status${NC}"
	"SQLite in one command: ${D_CYAN}core i sqlite${NC}"

	# ── AI Agents ──────────────────────────────────────────
	"OpenCode agent: ${D_CYAN}core i opencode${NC}"
	"Claude Code: ${D_CYAN}core i claude-code${NC}"
	"Gemini CLI: ${D_CYAN}core i gemini-cli${NC}"
	"Qwen Code: ${D_CYAN}core i qwen-code${NC}"
	"Ollama locally: ${D_CYAN}core i ollama${NC}"
	"Persistent memory for agents: ${D_CYAN}core i engram${NC}"
	"Codebase graph for agents: ${D_CYAN}core i codegraph${NC}"
	"P2P chat between agents: ${D_CYAN}core i walkie${NC}"
	"Hugging Face CLI (no venv): ${D_CYAN}core i hugging-face${NC}"

	# ── Style ──────────────────────────────────────────────
	"Tune your terminal look: ${D_CYAN}core style${NC}"
	"Meslo Nerd Font: ${D_CYAN}core style font${NC}"
	"ASCII banner on new sessions: ${D_CYAN}core style banner${NC}"
	"Green cursor: ${D_CYAN}core style cursor-color${NC}"
	"Remove a style anytime: ${D_CYAN}core style -r font${NC}"

	# ── Editor & Shell bundles ─────────────────────────────
	"NvChad on Neovim, one shot: ${D_CYAN}core i nvchad${NC}"
	"Oh My Zsh + p10k + plugins: ${D_CYAN}core i oh-my-zsh${NC}"

	# ── Cloud / tunnels ────────────────────────────────────
	"Expose localhost: ${D_CYAN}core i ngrok${NC} or ${D_CYAN}core i localtunnel${NC}"
	"Cloudflare Tunnel: ${D_CYAN}core i cloudflared${NC}"
	"Deploy to Vercel: ${D_CYAN}core i vercel${NC}"
	"Automation workflows: ${D_CYAN}core i n8n${NC}"

	# ── Agent ──────────────────────────────────────────────
	"Ask your local AI: ${D_CYAN}core agent ask -p \"Explain rsync\"${NC}"
	"One-shot task agent: ${D_CYAN}core agent run -p \"create a backup script\"${NC}"
	"Attach a file to the prompt: type ${D_CYAN}@name${NC} in a message"
	"Run shell from the REPL: start with ${D_CYAN}!${NC} e.g. ${D_CYAN}!git status${NC}"
	"Plan before touching files: ${D_CYAN}core agent run --plan${NC}"
	"Check agent status: ${D_CYAN}core agent status${NC}"

	# ── Environment ────────────────────────────────────────
	"Set API keys safely: ${D_CYAN}core env set${NC} — input is hidden with ●●●"
	"List your env vars: ${D_CYAN}core env ls${NC}"
	"Remove an env var: ${D_CYAN}core env unset${NC}"

	# ── Brain ──────────────────────────────────────────────
	"Set up your second brain: ${D_CYAN}core brain init${NC}"
	"Save memories: ${D_CYAN}core brain save${NC}"
	"Search your brain: ${D_CYAN}core brain search react${NC}"
	"Sync brain to GitHub: ${D_CYAN}core brain sync${NC}"
	"Create AI skill from memories: ${D_CYAN}core brain skill${NC}"

	# ── Voice (Termux) ─────────────────────────────────────
	"Voice-to-AI: ${D_CYAN}core voice opencode${NC} — speak, edit, launch agent"
	"Quick voice output: ${D_CYAN}core voice text${NC}"

	# ── Project Init ───────────────────────────────────────
	"Init a Next.js project: ${D_CYAN}cd my-app && core init next${NC}"
	"Init a React+Vite project: ${D_CYAN}cd my-app && core init react${NC}"
	"Init an Express API: ${D_CYAN}cd api && core init express${NC}"
	"Init a NestJS project: ${D_CYAN}cd backend && core init nest${NC}"


)

_tip_index_file="${XDG_CACHE_HOME:-$HOME/.cache}/core/.last_tip_index"

if [[ ${#CORE_TIPS[@]} -gt 0 ]]; then
	last_index=-1
	if [[ -f "$_tip_index_file" ]]; then
		last_index=$(cat "$_tip_index_file" 2>/dev/null || echo "-1")
	fi

	new_index=$last_index
	while [[ "$new_index" == "$last_index" ]]; do
		new_index=$(( RANDOM % ${#CORE_TIPS[@]} ))
	done

	echo "$new_index" >"$_tip_index_file"

	_tip="${CORE_TIPS[$new_index]:-}"
	if [[ -n "$_tip" ]]; then
		echo
		log_tip "$_tip"
	fi
fi
