#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

voice_help() {
	echo
	box "CORE VOICE — Speech-to-Agent"
	echo
	log_info "Capture voice from the microphone, review it in nvim, copy to clipboard, and launch an AI agent."
	echo
	log_info "Usage: core voice [agent]"
	echo
	separator_section "Agents"
	echo
	printf "    ${D_CYAN}%-16s${NC} %s\n" "opencode" "opencode run \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "claude-code" "claude -p \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "codex" "codex \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "gemini-cli" "gemini -p \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "hermes-agent" "hermes chat -q \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "kimi-code" "kimi -p \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "mimocode" "mimo run \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "mistral-vibe" "vibe --prompt \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "openclaude" "openclaude --bg \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "pi" "pi -p \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "qwen-code" "qwen -p \"prompt\""
	printf "    ${D_CYAN}%-16s${NC} %s\n" "text" "Print prompt to stdout"
	echo
	separator_section "Examples"
	echo
	printf "    ${D_CYAN}core voice${NC}                   # Show this help\n"
	printf "    ${D_CYAN}core voice opencode${NC}          # Capture → nvim → opencode\n"
	printf "    ${D_CYAN}core voice claude-code${NC}        # Capture → nvim → claude -p\n"
	printf "    ${D_CYAN}core voice text${NC}               # Capture → nvim → print to stdout\n"
	printf "    ${D_CYAN}core voice !${NC}                  # Alias for 'text'\n"
	echo
	separator_section "Requirements"
	echo
	list_item "Termux:API package: ${D_CYAN}pkg install termux-api${NC}"
	list_item "Neovim for editing: ${D_CYAN}core install editor${NC}"
	list_item "Termux:API app: ${D_CYAN}https://devcorex-web.vercel.app/termux/api${NC}"
	echo
}

voice_main() {
	local agent="$1"

	if [[ -z "$agent" ]] || [[ "$agent" == "--help" ]] || [[ "$agent" == "-h" ]]; then
		voice_help
		return
	fi

	# ── dependency checks ──
	if ! command -v termux-dialog &>/dev/null; then
		log_error "Termux:API is not installed"
		list_item "Install the package: ${D_CYAN}pkg install termux-api${NC}"
		list_item "Install the app from: https://devcorex-web.vercel.app/termux/api"
		separator
		exit 1
	fi

	if ! command -v nvim &>/dev/null; then
		log_error "Neovim (nvim) is not installed"
		list_item "Install the editor: ${D_CYAN}core install editor${NC}"
		separator
		exit 1
	fi

	# ── start Termux API activity ──
	termux-api-start &>/dev/null

	local is_text=false
	[[ "$agent" == "text" || "$agent" == "!" ]] && is_text=true

	# ── capture voice ──
	$is_text || log_info "Listening through the microphone..."
	local raw
	raw="$(termux-dialog speech 2>/dev/null | grep -i "text" | cut -d '"' -f 4)"

	if [[ -z "$raw" ]]; then
		log_error "No speech detected or dialog cancelled"
		separator
		exit 1
	fi

	# ── edit prompt in nvim (skip if no TTY) ──
	local tmpfile prompt
	tmpfile="$(mktemp)"
	echo "$raw" >"$tmpfile"

	if [[ -t 0 ]] && [[ -t 1 ]]; then
		$is_text || log_info "Review the prompt in nvim, fix mistakes, then save and quit"
		nvim "$tmpfile" </dev/tty >/dev/tty || true
	else
		$is_text || log_warn "No TTY available, skipping editor — using raw capture"
	fi

	prompt="$(cat "$tmpfile" | xargs)"
	rm -f "$tmpfile"

	if [[ -z "$prompt" ]]; then
		log_error "Prompt is empty after editing"
		separator
		exit 1
	fi

	# ── copy to clipboard ──
	if command -v termux-clipboard-set &>/dev/null; then
		echo "$prompt" | termux-clipboard-set
		if [[ "$agent" != "text" && "$agent" != "!" ]]; then
			log_info "Prompt copied to clipboard"
		fi
	fi

	# ── "text" or "!" → just print ──
	if [[ "$agent" == "text" ]] || [[ "$agent" == "!" ]]; then
		echo "$prompt"
		return
	fi

	# ── dispatch to agent ──
	log_info "Launching ${D_CYAN}$agent${NC} with prompt…"
	echo

	case "$agent" in
	opencode)
		opencode run "$prompt"
		;;
	claude-code)
		claude -p "$prompt"
		;;
	codex)
		codex "$prompt"
		;;
	gemini-cli)
		gemini -p "$prompt"
		;;
	hermes-agent)
		hermes chat -q "$prompt"
		;;
	kimi-code)
		kimi -p "$prompt"
		;;
	mimocode)
		mimo run "$prompt"
		;;
	mistral-vibe)
		vibe --prompt "$prompt"
		;;
	openclaude)
		openclaude --bg "$prompt"
		;;
	pi)
		pi -p "$prompt"
		;;
	qwen-code)
		qwen -p "$prompt"
		;;
	*)
		log_error "Unknown agent: $agent"
		echo
		log_info "Supported agents:"
		echo "  opencode, claude-code, codex, gemini-cli, hermes-agent,"
		echo "  kimi-code, mimocode, mistral-vibe, openclaude, pi, qwen-code"
		separator
		exit 1
		;;
	esac
}
