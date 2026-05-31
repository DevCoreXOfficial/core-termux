#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

AI_TOOLS=(
	"qwen-code"
	"gemini-cli"
	"claude-code"
	"mistral-vibe"
	"openclaude"
	"openclaw"
	"ollama"
	"codex"
	"opencode"
	"engram"
	"codegraph"
	"pi"
	"antigravity-cli"
	"gentle-ai"
	"minimax-cli"
)

source "$(dirname "$BASH_SOURCE")/qwen-code/install.sh"
source "$(dirname "$BASH_SOURCE")/gemini-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/claude-code/install.sh"
source "$(dirname "$BASH_SOURCE")/mistral-vibe/install.sh"
source "$(dirname "$BASH_SOURCE")/openclaude/install.sh"
source "$(dirname "$BASH_SOURCE")/openclaw/install.sh"
source "$(dirname "$BASH_SOURCE")/ollama/install.sh"
source "$(dirname "$BASH_SOURCE")/codex/install.sh"
source "$(dirname "$BASH_SOURCE")/opencode/install.sh"
source "$(dirname "$BASH_SOURCE")/engram/install.sh"
source "$(dirname "$BASH_SOURCE")/codegraph/install.sh"
source "$(dirname "$BASH_SOURCE")/pi/install.sh"
source "$(dirname "$BASH_SOURCE")/antigravity-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/gentle-ai/install.sh"
source "$(dirname "$BASH_SOURCE")/minimax-cli/install.sh"

install_all_ai_tools() {
	local installed_count=0
	local failed_count=0

	for tool in "${AI_TOOLS[@]}"; do
		case "$tool" in
		qwen-code)
			if install_qwen_code; then ((installed_count++)); else ((failed_count++)); fi
			;;
		gemini-cli)
			if install_gemini_cli; then ((installed_count++)); else ((failed_count++)); fi
			;;
		claude-code)
			if install_claude_code; then ((installed_count++)); else ((failed_count++)); fi
			;;
		mistral-vibe)
			if install_mistral_vibe; then ((installed_count++)); else ((failed_count++)); fi
			;;
		openclaude)
			if install_openclaude; then ((installed_count++)); else ((failed_count++)); fi
			;;
		openclaw)
			if install_openclaw; then ((installed_count++)); else ((failed_count++)); fi
			;;
		ollama)
			if install_ollama; then ((installed_count++)); else ((failed_count++)); fi
			;;
		codex)
			if install_codex; then ((installed_count++)); else ((failed_count++)); fi
			;;
		opencode)
			if install_opencode; then ((installed_count++)); else ((failed_count++)); fi
			;;
		engram)
			if install_engram; then ((installed_count++)); else ((failed_count++)); fi
			;;
		codegraph)
			if install_codegraph; then ((installed_count++)); else ((failed_count++)); fi
			;;
		pi)
			if install_pi; then ((installed_count++)); else ((failed_count++)); fi
			;;
		antigravity-cli)
			if install_antigravity_cli; then ((installed_count++)); else ((failed_count++)); fi
			;;
		gentle-ai)
			if install_gentle_ai; then ((installed_count++)); else ((failed_count++)); fi
			;;
		minimax-cli)
			if install_minimax_cli; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_ai_tools() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${AI_TOOLS[@]}"; do
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
		codex)
			if uninstall_codex; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		opencode)
			if uninstall_opencode; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		engram)
			if uninstall_engram; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		codegraph)
			if uninstall_codegraph; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		pi)
			if uninstall_pi; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		antigravity-cli)
			if uninstall_antigravity_cli; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		gentle-ai)
			if uninstall_gentle_ai; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		minimax-cli)
			if uninstall_minimax_cli; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_ai_tools() {
	local updated_count=0
	local failed_count=0

	for tool in "${AI_TOOLS[@]}"; do
		case "$tool" in
		qwen-code)
			if update_qwen_code; then ((updated_count++)); else ((failed_count++)); fi
			;;
		gemini-cli)
			if update_gemini_cli; then ((updated_count++)); else ((failed_count++)); fi
			;;
		claude-code)
			if update_claude_code; then ((updated_count++)); else ((failed_count++)); fi
			;;
		mistral-vibe)
			if update_mistral_vibe; then ((updated_count++)); else ((failed_count++)); fi
			;;
		openclaude)
			if update_openclaude; then ((updated_count++)); else ((failed_count++)); fi
			;;
		openclaw)
			if update_openclaw; then ((updated_count++)); else ((failed_count++)); fi
			;;
		ollama)
			if update_ollama; then ((updated_count++)); else ((failed_count++)); fi
			;;
		codex)
			if update_codex; then ((updated_count++)); else ((failed_count++)); fi
			;;
		opencode)
			if update_opencode; then ((updated_count++)); else ((failed_count++)); fi
			;;
		engram)
			if update_engram; then ((updated_count++)); else ((failed_count++)); fi
			;;
		codegraph)
			if update_codegraph; then ((updated_count++)); else ((failed_count++)); fi
			;;
		pi)
			if update_pi; then ((updated_count++)); else ((failed_count++)); fi
			;;
		antigravity-cli)
			if update_antigravity_cli; then ((updated_count++)); else ((failed_count++)); fi
			;;
		gentle-ai)
			if update_gentle_ai; then ((updated_count++)); else ((failed_count++)); fi
			;;
		minimax-cli)
			if update_minimax_cli; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}
