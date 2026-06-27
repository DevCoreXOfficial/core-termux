#!/data/data/com.termux/files/usr/bin/bash

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
	printf "     ${NC}Welcome to${GRAY} Core-Termux ${DGREEN}v%s${NC}\n" "$BANNER_VERSION"
	printf "        ${NC}Run ${DGREEN}core${NC} to get started${NC}\n"
fi

# ── Random Tip ──────────────────────────────────────────────

CORE_TIPS=(
	# ── Framework ─────────────────────────────────────────────
	"Keep Core-Termux updated: ${D_CYAN}core update core${NC}"
	"Check your version: ${D_CYAN}core --version${NC}"
	"Enable debug logs: ${D_CYAN}export CORE_DEBUG=1${NC}"
	"Shell remembers your last directory — open Termux where you left off"
	"Open framework docs: ${D_CYAN}core open core${NC}"
	"Visit DevCoreX website: ${D_CYAN}core open devcorex${NC}"

	# ── Install / Update / Uninstall ─────────────────────────
	"Install everything at once: ${D_CYAN}core install lang db dev npm${NC}"
	"Install only what you need: ${D_CYAN}core install ai --opencode --ollama${NC}"
	"See what's installed: ${D_CYAN}core list ai${NC} or ${D_CYAN}core list dev${NC}"
	"Read tool docs: ${D_CYAN}core show ai --opencode${NC}"
	"Update a specific tool: ${D_CYAN}core update ai --opencode${NC}"
	"Update all AI tools: ${D_CYAN}core update ai${NC}"
	"Update all databases: ${D_CYAN}core update db${NC}"
	"Update ZSH plugins: ${D_CYAN}core update shell${NC}"
	"Reinstall from scratch: ${D_CYAN}core reinstall shell${NC}"
	"Reinstall specific tools: ${D_CYAN}core reinstall ai --opencode --ollama${NC}"
	"Remove a module: ${D_CYAN}core uninstall npm${NC}"
	"Remove specific tool: ${D_CYAN}core uninstall ai --ollama${NC}"
	"Open tool docs in browser: ${D_CYAN}core open ai${NC}"

	# ── Languages ────────────────────────────────────────────
	"Install all languages: ${D_CYAN}core install lang${NC}"
	"Install Python: ${D_CYAN}core install lang --python${NC}"
	"Install Rust: ${D_CYAN}core install lang --rust${NC}"
	"Install Go: ${D_CYAN}core install lang --golang${NC}"
	"Install PHP: ${D_CYAN}core install lang --php${NC}"
	"Install Perl: ${D_CYAN}core install lang --perl${NC}"
	"Install C/C++: ${D_CYAN}core install lang --clang${NC}"
	"Install Node.js LTS: ${D_CYAN}core install lang --nodejs${NC}"

	# ── Databases ────────────────────────────────────────────
	"Install all databases: ${D_CYAN}core install db${NC}"
	"Start PostgreSQL: ${D_CYAN}core pg init${NC} then ${D_CYAN}core pg start${NC}"
	"Open psql shell: ${D_CYAN}core pg shell${NC}"
	"Create a database: ${D_CYAN}core pg create mydb${NC}"
	"Check PG status: ${D_CYAN}core pg status${NC}"
	"List all databases: ${D_CYAN}core pg list${NC}"
	"Stop PostgreSQL: ${D_CYAN}core pg stop${NC}"
	"Restart PostgreSQL: ${D_CYAN}core pg restart${NC}"
	"Drop a database safely: ${D_CYAN}core pg drop mydb${NC} (with confirmation)"
	"Install MariaDB: ${D_CYAN}core install db --mariadb${NC}"
	"Install SQLite: ${D_CYAN}core install db --sqlite${NC}"
	"Install MongoDB: ${D_CYAN}core install db --mongodb${NC}"

	# ── AI Agents ────────────────────────────────────────────
	"Install all AI agents: ${D_CYAN}core install ai${NC}"
	"Run Ollama locally on your phone: ${D_CYAN}core install ai --ollama${NC}"
	"Install OpenCode: ${D_CYAN}core install ai --opencode${NC}"
	"Install Claude Code: ${D_CYAN}core install ai --claude-code${NC}"
	"Install Codex CLI: ${D_CYAN}core install ai --codex${NC}"
	"Install Gemini CLI: ${D_CYAN}core install ai --gemini-cli${NC}"
	"Install MiMo Code: ${D_CYAN}core install ai --mimocode${NC}"
	"Install Mistral Vibe: ${D_CYAN}core install ai --mistral-vibe${NC}"
	"Install OpenClaude: ${D_CYAN}core install ai --openclaude${NC}"
	"Install Pi agent: ${D_CYAN}core install ai --pi${NC}"
	"Install Qwen Code: ${D_CYAN}core install ai --qwen-code${NC}"
	"Install Hermes Agent: ${D_CYAN}core install ai --hermes-agent${NC}"
	"Install Kimi Code: ${D_CYAN}core install ai --kimi-code${NC}"
	"Install Gentle AI: ${D_CYAN}core install ai --gentle-ai${NC}"
	"Install Engram memory: ${D_CYAN}core install ai --engram${NC}"
	"Install CodeGraph: ${D_CYAN}core install ai --codegraph${NC}"
	"Install GGA code review: ${D_CYAN}core install ai --gga${NC}"
	"Install MiniMax CLI: ${D_CYAN}core install ai --minimax-cli${NC}"
	"Install Command Code: ${D_CYAN}core install ai --command-code${NC}"
	"Install Freebuff: ${D_CYAN}core install ai --freebuff${NC}"

	# ── Editor ───────────────────────────────────────────────
	"Install Neovim + NvChad: ${D_CYAN}core install editor${NC}"
	"Install just Neovim: ${D_CYAN}core install editor --neovim${NC}"
	"Install NvChad config: ${D_CYAN}core install editor --nvchad${NC}"

	# ── Dev Tools ────────────────────────────────────────────
	"Fuzzy search commands: ${D_CYAN}core install dev --fzf${NC}"
	"Modern ls with icons: ${D_CYAN}core install dev --lsd${NC}"
	"Syntax-highlighted cat: ${D_CYAN}core install dev --bat${NC}"
	"GitHub CLI for PRs and issues: ${D_CYAN}core install dev --gh${NC}"
	"Share your terminal instantly: ${D_CYAN}core install dev --tmate${NC}"
	"Run Docker without root: ${D_CYAN}core install dev --udocker${NC}"
	"Translate text from terminal: ${D_CYAN}core install dev --translate${NC}"
	"Convert HTML to text: ${D_CYAN}core install dev --html2text${NC}"
	"Format shell scripts: ${D_CYAN}core install dev --shfmt${NC}"
	"Process JSON from CLI: ${D_CYAN}core install dev --jq${NC}"
	"Image manipulation: ${D_CYAN}core install dev --imagemagick${NC}"
	"Arbitrary precision calculator: ${D_CYAN}core install dev --bc${NC}"
	"Recursive directory listing: ${D_CYAN}core install dev --tree${NC}"
	"Build automation: ${D_CYAN}core install dev --make${NC}"
	"Chroot alternative: ${D_CYAN}core install dev --proot${NC}"
	"Cloudflare Tunnel: ${D_CYAN}core install dev --cloudflared${NC}"

	# ── NPM Packages ─────────────────────────────────────────
	"Tunnel localhost to the web: ${D_CYAN}core install npm --ngrok${NC}"
	"Deploy to Vercel from terminal: ${D_CYAN}core install npm --vercel${NC}"
	"Format code with Prettier: ${D_CYAN}core install npm --prettier${NC}"
	"TypeScript compiler: ${D_CYAN}core install npm --typescript${NC}"
	"Live reload dev server: ${D_CYAN}core install npm --live-server${NC}"
	"Expose localhost via tunnel: ${D_CYAN}core install npm --localtunnel${NC}"
	"Markdown preview server: ${D_CYAN}core install npm --markserv${NC}"
	"PostgreSQL query formatter: ${D_CYAN}core install npm --psqlformat${NC}"
	"Find outdated npm packages: ${D_CYAN}core install npm --ncu${NC}"
	"NestJS CLI: ${D_CYAN}core install npm --nestjs${NC}"

	# ── Shell ────────────────────────────────────────────────
	"Install ZSH + plugins: ${D_CYAN}core install shell${NC}"
	"Install Powerlevel10k theme: ${D_CYAN}core install shell --powerlevel10k${NC}"
	"Get fuzzy tab completion: ${D_CYAN}core install shell --fzf-tab${NC}"
	"Smart command suggestions: ${D_CYAN}core install shell --you-should-use${NC}"
	"Auto-close brackets: ${D_CYAN}core install shell --zsh-autopair${NC}"
	"Deferred plugin loading: ${D_CYAN}core install shell --zsh-defer${NC}"
	"Smart autocompletion: ${D_CYAN}core install shell --zsh-autosuggestions${NC}"
	"Syntax highlighting: ${D_CYAN}core install shell --zsh-syntax-highlighting${NC}"
	"History substring search: ${D_CYAN}core install shell --history-substring${NC}"
	"Additional completions: ${D_CYAN}core install shell --zsh-completions${NC}"
	"Better npm completion: ${D_CYAN}core install shell --better-npm${NC}"

	# ── UI ───────────────────────────────────────────────────
	"Customize Termux UI: ${D_CYAN}core install ui${NC}"
	"Install Meslo Nerd Font: ${D_CYAN}core install ui --font${NC}"
	"Configure cursor color: ${D_CYAN}core install ui --cursor${NC}"
	"Setup extra keys bar: ${D_CYAN}core install ui --extra-keys${NC}"
	"Install Core banner: ${D_CYAN}core install ui --banner${NC}"

	# ── Automation ───────────────────────────────────────────
	"Run n8n automation: ${D_CYAN}core install auto --n8n${NC}"
	"Install automation tools: ${D_CYAN}core install auto${NC}"

	# ── Environment ──────────────────────────────────────────
	"Set API keys safely: ${D_CYAN}core env set${NC} — input is hidden with ●●●"
	"List your env vars: ${D_CYAN}core env ls${NC}"
	"Remove an env var: ${D_CYAN}core env unset${NC}"

	# ── Brain ────────────────────────────────────────────────
	"Set up your second brain: ${D_CYAN}core brain init${NC}"
	"Save memories: ${D_CYAN}core brain save${NC}"
	"Search your brain: ${D_CYAN}core brain search react${NC}"
	"List memories by category: ${D_CYAN}core brain ls frontend${NC}"
	"Edit a memory directly: ${D_CYAN}core brain edit slug-name${NC}"
	"Delete a memory: ${D_CYAN}core brain delete${NC}"
	"View a memory: ${D_CYAN}core brain show slug-name${NC}"
	"Visualize connections: ${D_CYAN}core brain graph${NC}"
	"Create AI skill from memories: ${D_CYAN}core brain skill${NC}"
	"Link memories together: ${D_CYAN}core brain relate${NC}"
	"Sync brain to GitHub: ${D_CYAN}core brain sync${NC}"
	"Reset your brain entirely: ${D_CYAN}core brain reset${NC}"

	# ── Voice ────────────────────────────────────────────────
	"Voice-to-AI: ${D_CYAN}core voice opencode${NC} — speak, edit, launch agent"
	"Quick voice output: ${D_CYAN}core voice text${NC} — capture speech to stdout"
	"Use ${D_CYAN}core voice !${NC} as a shortcut for ${D_CYAN}core voice text${NC}"

	# ── Project Init ─────────────────────────────────────────
	"Init a Next.js project: ${D_CYAN}cd my-app && core init next${NC}"
	"Init a React+Vite project: ${D_CYAN}cd my-app && core init react${NC}"
	"Init an Express API: ${D_CYAN}cd api && core init express${NC}"
	"Init a NestJS project: ${D_CYAN}cd backend && core init nest${NC}"
)

_tip_index_file="${XDG_CACHE_HOME:-$HOME/.cache}/core-termux/.last_tip_index"

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

echo
