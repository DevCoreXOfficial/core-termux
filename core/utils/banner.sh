#!/usr/bin/env bash

BANNER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BANNER_VERSION="$(grep "^CORE_VERSION=" "$BANNER_SCRIPT_DIR/env.sh" 2>/dev/null | cut -d'"' -f2)"

# ── Grayscale ramp (ANSI 256, self-contained for shell startup) ──
GRAY_0="\033[38;5;232m"
GRAY_1="\033[38;5;233m"
GRAY_2="\033[38;5;234m"
GRAY_3="\033[38;5;235m"
GRAY_4="\033[38;5;236m"
GRAY_5="\033[38;5;237m"
GRAY_6="\033[38;5;238m"
GRAY_7="\033[38;5;239m"
GRAY_8="\033[38;5;240m"
GRAY_9="\033[38;5;241m"
GRAY_10="\033[38;5;242m"
GRAY_11="\033[38;5;243m"
GRAY_12="\033[38;5;244m"
GRAY_13="\033[38;5;245m"
GRAY_14="\033[38;5;246m"
GRAY_15="\033[38;5;247m"
GRAY_16="\033[38;5;248m"
GRAY_17="\033[38;5;249m"
GRAY_18="\033[38;5;250m"
GRAY_19="\033[38;5;251m"
GRAY_20="\033[38;5;252m"
GRAY_21="\033[38;5;253m"
GRAY_22="\033[38;5;254m"
GRAY_23="\033[38;5;255m"
RESET="\033[0m"
BOLD_GREEN="\e[1;32m"
GREEN="\e[0;32m"
WHITE="\e[1;38;2;255;255;255m"
DIM="\e[38;2;90;90;90m"
DGREEN="\033[0;32m"
NC="\033[0m"
GRAY="\033[0;90m"
D_CYAN="\033[38;5;251m"

# ── Reusable tip function (matches log.sh style) ───────────
log_tip() {
	echo -e " ${GRAY_12}● Tip${NC} $*"
}

# ============================================================
#  Diamond banner — solid with hollow center, gray gradient
# ============================================================
W=34
H=19
cx=$((W / 2))
cy=$((H / 2))
ASPECT=2
R_OUT=16
R_IN=6
TOP=235
BOTTOM=40
BLOCK="█"

for ((row = 0; row < H; row++)); do
	gray=$((TOP - (row * (TOP - BOTTOM)) / (H - 1)))
	line=""
	for ((col = 0; col < W; col++)); do
		X=$((col - cx))
		Y=$((row - cy))
		sy=$((Y * ASPECT))
		absX=${X#-}
		absSy=${sy#-}
		s=$((absX + absSy))
		if [ $row -eq $cy ] && [ $col -eq $cx ]; then
			line="${line}\e[1;38;2;255;255;255m◈\e[0m"
		elif [ $s -le $R_IN ]; then
			line="${line} "
		elif [ $s -le $R_OUT ]; then
			line="${line}\e[38;2;${gray};${gray};${gray}m${BLOCK}\e[0m"
		else
			line="${line} "
		fi
	done
	printf "  ${line}\n"
done

# ── Text banner: CORE ──
echo -e "${GRAY_14}            █▀▀ █▀█ █▀█ █▀▀"
echo -e "            █▄▄ █▄█ █▀▄ ██▄${RESET}"
echo ""

# ── Version separator ──
if [[ -n "$BANNER_VERSION" ]]; then
	printf " ${DIM}───────────────${RESET}  ${GREEN}v%s${RESET}  ${DIM}───────────────${RESET}\n" "$BANNER_VERSION"
else
	printf " ${DIM}────────────────────────────────${RESET}\n"
fi
echo ""
# ── DevCoreX + suggestion ──
printf " ${GRAY_14}DevCoreX ${NC}Software Development Community${NC}\n"
echo ""

# ── Tagline ──
printf " ${GREEN}◈${RESET} ${WHITE}CORE —${RESET} ${GRAY_14}Your Environment. Everywhere.${RESET} ${GREEN}◈${RESET}\n"

# ── Random Tip ──────────────────────────────────────────────

CORE_TIPS=(
	# ── Framework ─────────────────────────────────────────────
	"Keep Core updated: ${GRAY_19}core update core${NC}"
	"Check your version: ${GRAY_19}core --version${NC}"
	"Enable debug logs: ${GRAY_19}export CORE_DEBUG=1${NC}"
	"Open framework docs: ${GRAY_19}core open${NC}"

	# ── Search & Install ────────────────────────────────────
	"List every tool with status: ${GRAY_19}core s --all${NC}"
	"Find tools by keyword: ${GRAY_19}core search tunnel${NC} or ${GRAY_19}core search js${NC}"
	"Install a tool by name: ${GRAY_19}core i opencode${NC}"
	"Install several at once: ${GRAY_19}core i gh jq fzf${NC}"
	"Update a tool: ${GRAY_19}core up opencode${NC}"
	"Remove a tool: ${GRAY_19}core un opencode${NC}"
	"Reinstall from scratch: ${GRAY_19}core ri opencode${NC}"
	"Read tool docs: ${GRAY_19}core show opencode${NC}"
	"Spanish docs: ${GRAY_19}core show opencode:es${NC}"

	# ── Languages ──────────────────────────────────────────
	"Node.js LTS: ${GRAY_19}core i nodejs${NC}"
	"Python: ${GRAY_19}core i python${NC}"
	"Rust via rustup: ${GRAY_19}core i rust${NC}"
	"Go: ${GRAY_19}core i golang${NC}"
	"Bun runtime: ${GRAY_19}core i bun${NC}"
	"C/C++ compiler: ${GRAY_19}core i clang${NC}"
	"TypeScript compiler: ${GRAY_19}core i typescript${NC}"

	# ── Databases ──────────────────────────────────────────
	"Initialize PostgreSQL: ${GRAY_19}core pg init${NC}"
	"Start PostgreSQL: ${GRAY_19}core pg start${NC}"
	"Open psql shell: ${GRAY_19}core pg shell${NC}"
	"Create a database: ${GRAY_19}core pg create mydb${NC}"
	"Check PG status: ${GRAY_19}core pg status${NC}"
	"SQLite in one command: ${GRAY_19}core i sqlite${NC}"

	# ── AI Agents ──────────────────────────────────────────
	"OpenCode agent: ${GRAY_19}core i opencode${NC}"
	"Claude Code: ${GRAY_19}core i claude-code${NC}"
	"Gemini CLI: ${GRAY_19}core i gemini-cli${NC}"
	"Qwen Code: ${GRAY_19}core i qwen-code${NC}"
	"Ollama locally: ${GRAY_19}core i ollama${NC}"
	"Persistent memory for agents: ${GRAY_19}core i engram${NC}"
	"Codebase graph for agents: ${GRAY_19}core i codegraph${NC}"
	"P2P chat between agents: ${GRAY_19}core i walkie${NC}"
	"Hugging Face CLI (no venv): ${GRAY_19}core i hugging-face${NC}"

	# ── Style ──────────────────────────────────────────────
	"Tune your terminal look: ${GRAY_19}core style${NC}"
	"Meslo Nerd Font: ${GRAY_19}core style font${NC}"
	"ASCII banner on new sessions: ${GRAY_19}core style banner${NC}"
	"Green cursor: ${GRAY_19}core style cursor-color${NC}"
	"Remove a style anytime: ${GRAY_19}core style -r font${NC}"

	# ── Editor & Shell bundles ─────────────────────────────
	"NvChad on Neovim, one shot: ${GRAY_19}core i nvchad${NC}"
	"Oh My Zsh + p10k + plugins: ${GRAY_19}core i oh-my-zsh${NC}"

	# ── Cloud / tunnels ────────────────────────────────────
	"Expose localhost: ${GRAY_19}core i ngrok${NC} or ${GRAY_19}core i localtunnel${NC}"
	"Cloudflare Tunnel: ${GRAY_19}core i cloudflared${NC}"
	"Deploy to Vercel: ${GRAY_19}core i vercel${NC}"
	"Automation workflows: ${GRAY_19}core i n8n${NC}"

	# ── Agent ──────────────────────────────────────────────
	"Ask your local AI: ${GRAY_19}core agent ask -p \"Explain rsync\"${NC}"
	"One-shot task agent: ${GRAY_19}core agent run -p \"create a backup script\"${NC}"
	"Attach a file to the prompt: type ${GRAY_19}@name${NC} in a message"
	"Run shell from the REPL: start with ${GRAY_19}!${NC} e.g. ${GRAY_19}!git status${NC}"
	"Plan before touching files: ${GRAY_19}core agent run --plan${NC}"
	"Check agent status: ${GRAY_19}core agent status${NC}"

	# ── Environment ────────────────────────────────────────
	"Set API keys safely: ${GRAY_19}core env set${NC} — input is hidden with ●●●"
	"List your env vars: ${GRAY_19}core env ls${NC}"
	"Remove an env var: ${GRAY_19}core env unset${NC}"

	# ── Brain ──────────────────────────────────────────────
	"Set up your second brain: ${GRAY_19}core brain init${NC}"
	"Save memories: ${GRAY_19}core brain save${NC}"
	"Search your brain: ${GRAY_19}core brain search react${NC}"
	"Sync brain to GitHub: ${GRAY_19}core brain sync${NC}"
	"Create AI skill from memories: ${GRAY_19}core brain skill${NC}"

	# ── Voice (Termux) ─────────────────────────────────────
	"Voice-to-AI: ${GRAY_19}core voice opencode${NC} — speak, edit, launch agent"
	"Quick voice output: ${GRAY_19}core voice text${NC}"

	# ── Project Init ───────────────────────────────────────
	"Init a Next.js project: ${GRAY_19}cd my-app && core init next${NC}"
	"Init a React+Vite project: ${GRAY_19}cd my-app && core init react${NC}"
	"Init an Express API: ${GRAY_19}cd api && core init express${NC}"
	"Init a NestJS project: ${GRAY_19}cd backend && core init nest${NC}"


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

echo ""
