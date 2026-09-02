#!/usr/bin/env bash

import "@/utils/log"
import "@/utils/colors"

voice_help() {
	echo
	box_large "CORE VOICE — Speech-to-Agent"
	echo
	log_info "Capture voice from the microphone, review it in nvim, copy to clipboard, and launch an AI agent."
	echo
	log_info "Usage: core voice [agent]"
	echo
	separator_section "Agents"
	echo
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "opencode" "opencode run \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "claude-code" "claude -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "codex" "codex \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "gemini-cli" "gemini -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "hermes-agent" "hermes chat -q \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "kilocode" "kilo run \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "kimi-code" "kimi -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "mimocode" "mimo run \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "mistral-vibe" "vibe --prompt \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "openclaude" "openclaude --bg \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "pi" "pi -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "qoder" "qodercli -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "qwen-code" "qwen -p \"prompt\""
	printf "    ${GRAY_19}%-16s${D_NC} %s\n" "text" "Print prompt to stdout"
	echo
	separator_section "Examples"
	echo
	printf "    ${GRAY_19}core voice${D_NC}                   # Show this help\n"
	printf "    ${GRAY_19}core voice opencode${D_NC}          # Capture → nvim → opencode\n"
	printf "    ${GRAY_19}core voice qoder${D_NC}             # Capture → nvim → qoder\n"
	printf "    ${GRAY_19}core voice claude-code${D_NC}       # Capture → nvim → claude -p\n"
	printf "    ${GRAY_19}core voice text${D_NC}              # Capture → nvim → print to stdout\n"
	printf "    ${GRAY_19}core voice !${D_NC}                 # Alias for 'text'\n"
	echo
	separator_section "Requirements"
	echo
	list_item "Termux:API package: ${GRAY_19}pkg install termux-api${D_NC}"
	list_item "Neovim for editing: ${GRAY_19}core install nvchad${D_NC}"
	list_item "Termux:API app: ${GRAY_12}devcorex-web.vercel.app/termux/api${D_NC}"
	echo
}

voice_main() {
	import "@/lib/platform"
	core_detect_platform
	if [[ "$CORE_ENV" != "termux" ]]; then
		log_warn "core voice requires the Termux:API app (Termux/Android only)"
		list_item "On Ubuntu/WSL, dictate into ${GRAY_19}core agent${D_NC} directly or type your prompt."
		return 1
	fi

	local agent="$1"

	if [[ -z "$agent" ]] || [[ "$agent" == "--help" ]] || [[ "$agent" == "-h" ]]; then
		voice_help
		return
	fi

	# ── dependency checks ──
	if ! command -v termux-dialog &>/dev/null; then
		log_error "Termux:API is not installed"
		list_item "Install the package: ${GRAY_19}pkg install termux-api${NC}"
		list_item "Install the app from: https://devcorex-web.vercel.app/termux/api"
		separator
		exit 1
	fi

	if ! command -v nvim &>/dev/null; then
		log_error "Neovim (nvim) is not installed"
		list_item "Install the editor: ${GRAY_19}core install nvchad${NC}"
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
	log_info "Launching ${GRAY_19}$agent${NC} with prompt…"
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
	kilocode)
		kilo run "$prompt"
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
	qoder)
		qodercli -p "$prompt"
		;;
	qwen-code)
		qwen -p "$prompt"
		;;
	*)
		log_error "Unknown agent: $agent"
		echo
		log_info "Supported agents:"
		echo "  opencode, qoder, claude-code, codex, gemini-cli, hermes-agent,"
		echo "  kilocode, kimi-code, mimocode, mistral-vibe, openclaude, pi, qwen-code"
		separator
		exit 1
		;;
	esac
}
