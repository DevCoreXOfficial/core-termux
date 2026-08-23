#!/usr/bin/env bash

# ============================================================
# core agent — AI assistant (ask) & bash-backed task agent (run)
#
#   core agent ask "prompt"     assistant, streamed (markdown TUI)
#   core agent run "prompt"     task agent: the LLM answers in
#                               markdown; bash parses the answer
#                               into files & commands and does the
#                               work (commands need y/N approval)
#
# Everything in this command is plain bash; the "AI" only DECIDES
# and DESCRIBES. bash EXECUTES. In the REPLs (and -p prompts on a
# TTY) typing `@query` opens an fzf picker to attach a file's
# contents to your message.
# ============================================================

import "@/utils/log"
import "@/utils/colors"
import "@/utils/agent_llm"
import "@/utils/agent_actions"
import "@/utils/agent_markdown"

# ------------------------------------------------------------
# agent_help
# ------------------------------------------------------------
agent_help() {
	echo
	box_large "Core Agent — Local AI Assistant & Task Agent"
	echo
	log_info "Usage: core agent <ask|run|config> [options]"
	echo
	separator_section "Subcommands"
	echo
	printf "    ${D_CYAN}%-11s${D_NC} %s\n" "ask" "Assistant (prompt → LLM → colored markdown answer)"
	printf "    ${D_CYAN}%-11s${D_NC} %s\n" "run" "Agent (prompt → LLM markdown → bash creates files / runs commands)"
	printf "    ${D_CYAN}%-11s${D_NC} %s\n" "config" "Show or edit saved settings"
	printf "    ${D_CYAN}%-11s${D_NC} %s\n" "status" "Show endpoint/model status"
	echo
	separator_section "Options (ask & run)"
	echo
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-p, --prompt <text>" "Task/question (omit for interactive shell)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-m, --model <name>" "Model id (default: $AGENT_MODEL)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-u, --endpoint <url>" "OpenAI-compatible endpoint (default: $AGENT_ENDPOINT)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-t, --temperature <n>" "Sampling temperature (default: $AGENT_TEMPERATURE)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "--max-tokens <n>" "Max output tokens (default: $AGENT_MAX_TOKENS)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-w, --workspace <dir>" "Agent working dir (run mode, default: \$PWD)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-n, --max-iterations <n>" "Agent loop limit (default: $AGENT_MAX_ITERATIONS)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "-y, --yes" "Auto-approve commands (skip y/N prompt)"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "--plan" "Plan mode (read-only): no file writes, write commands blocked"
	printf "    ${D_CYAN}%-22s${D_NC} %s\n" "--build" "Build mode (default): files and commands applied"
	echo
	separator_section "Files & commands"
	echo
	list_item "Type ${D_CYAN}@name${D_NC} in a message to attach a file's contents (live fzf picker while typing)"
	list_item "Start a message with ${D_CYAN}!${D_NC} for shell mode (e.g. ${D_CYAN}!git status${D_NC}) — the prompt turns green ${D_CYAN}Shell${D_NC} and the output is added to the agent's context"
	list_item "Commands from the model run only after your ${D_CYAN}y/N${D_NC} confirmation (${D_CYAN}-y${D_NC} auto-approves)"
	list_item "Press ${D_CYAN}ESC ESC${D_NC} at any prompt to cancel the agent"
	list_item "The interactive REPL remembers the conversation and shows ${D_CYAN}[context % · elapsed]${D_NC} after each answer/task"
	list_item "Dictate your prompt with ${D_CYAN}/voice${D_NC} (Termux:API)"
	list_item "If the model server is down, the agent starts ${D_CYAN}cactus${D_NC} in the background (logs → ${D_CYAN}~/.cache/core/core-agent.log${D_NC}) and stops it when you leave (${D_CYAN}/exit${D_NC} or ${D_CYAN}Ctrl+C${D_NC})"
	echo
	separator_section "Interactive slash commands"
	echo
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/help" "Show this help"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/model <name>" "Switch model"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/endpoint <url>" "Switch endpoint"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/temp <n>" "Set temperature"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/max <n>" "Set max tokens"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/workspace <dir>" "Set agent workspace (run)"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/voice" "Dictate with Termux:API"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/clear" "Reset conversation"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/history" "Show conversation history"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/status" "Show current settings"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/plan" "Plan mode (read-only) — next task only inspects and proposes"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/build" "Build mode — next task applies files and commands"
	printf "    ${D_CYAN}%-16s${D_NC} %s\n" "/exit" "Leave the interactive shell"
	echo
	separator_section "Examples"
	echo
	printf "    ${D_CYAN}core agent ask -p \"Explain rsync\"${D_NC}\n"
	printf "    ${D_CYAN}core agent run -p \"create a backup script\"${D_NC}\n"
	printf "    ${D_CYAN}core agent run -p \"...\" -m gemma-4-e2b-it-cq4 -u http://127.0.0.1:8000/v1${D_NC}\n"
	printf "    ${D_CYAN}core agent ask${D_NC}                    # interactive chat\n"
	echo
}

# ------------------------------------------------------------
# agent_main — dispatcher
# ------------------------------------------------------------
agent_main() {
	local cmd="$1"
	shift || true

	agent_config_load

	case "$cmd" in
	ask | chat)
		agent_ask "$@"
		;;
	run | exec)
		agent_run "$@"
		;;
	config | settings)
		agent_config_cmd "$@"
		;;
	status | info)
		agent_status
		;;
	"" | --help | -h | help)
		agent_help
		;;
	*)
		log_error "Unknown subcommand: ${D_CYAN}$cmd${D_NC}"
		echo
		agent_help
		exit 1
		;;
	esac
}

# ------------------------------------------------------------
# agent_status_line — compact one-liner of current settings
# ------------------------------------------------------------
agent_status_line() {
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Model" "$NC" "$AGENT_MODEL"
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Endpoint" "$NC" "$AGENT_ENDPOINT"
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Temp" "$NC" "$AGENT_TEMPERATURE"
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Max tokens" "$NC" "$AGENT_MAX_TOKENS"
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Context" "$NC" "$AGENT_CONTEXT_WINDOW tokens"
	# PLAN/BUILD modes are a run-mode concept; hide them in ask
	[[ "$AGENT_REPL_MODE" != "ask" ]] && printf '    %b%-10s%b : %s\n' "$D_CYAN" "Mode" "$NC" "$([[ $AGENT_PLAN_MODE == 1 ]] && echo 'PLAN (read-only)' || echo 'BUILD (full access)')"
	printf '    %b%-10s%b : %s\n' "$D_CYAN" "Workspace" "$NC" "$AGENT_WORKSPACE"
}

# ------------------------------------------------------------
# agent_status — full status with server check
# ------------------------------------------------------------
agent_status() {
	separator_section "Core Agent — Status"
	echo
	agent_status_line
	echo
	separator_section "Server"
	echo
	if agent_check_server; then
		log_success "Endpoint reachable: ${D_CYAN}$AGENT_ENDPOINT${D_NC}"
		local ms
		ms=$(agent_models_list 2>/dev/null)
		echo
		log_info "Available models:"
		echo "$ms" | while IFS= read -r mid; do
			list_item "$mid"
		done
	else
		log_error "Endpoint unreachable"
	fi
	echo
	separator_section "Config file"
	echo
	list_item "$AGENT_CONF_FILE"
	echo
}

# ------------------------------------------------------------
# agent_config_help
# ------------------------------------------------------------
agent_config_help() {
	log_info "Usage: core agent config [key] [value]"
	echo
	separator_section "Settings"
	echo
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "model" "Model id (default: gemma-4-e2b-it-cq4)"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "endpoint" "OpenAI-compatible URL"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "temperature" "Sampling temperature"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "max_tokens" "Max output tokens"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "max_iterations" "Agent loop limit"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "confirm_commands" "Ask y/N before running commands (1/0)"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "context_window" "Model context window in tokens (default: 8192)"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "server_command" "Command that starts the model server in the background"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "workspace" "Default agent working dir"
	echo
	log_tip "Run ${D_CYAN}core agent config${D_NC} with no arguments to show current settings."
}

# ------------------------------------------------------------
# agent_config_cmd
# ------------------------------------------------------------
agent_config_cmd() {
	local key="$1"
	shift || true

	if [[ -z "$key" || "$key" == "--help" || "$key" == "-h" ]]; then
		echo
		separator_section "Current Config"
		echo
				agent_status_line
		echo
		separator_section "Config file"
		echo
		list_item "Saved at: ${D_CYAN}$AGENT_CONF_FILE${D_NC}"
		echo
		agent_config_help
		echo
		return 0
	fi

	local value="$*"
	if [[ -z "$value" ]]; then
		log_error "Missing value for: $key"
		echo
		agent_config_help
		return 1
	fi
	agent_config_set "$key" "$value"
	log_success "Saved $key = ${D_CYAN}$value${D_NC}"
}
# ------------------------------------------------------------
# Slash-command help
# ------------------------------------------------------------
agent_repl_help() {
	local mode="${1:-$AGENT_REPL_MODE}"
	separator_section "Slash commands"
	echo
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/model <name>" "Switch model"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/endpoint <url>" "Switch endpoint"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/temp <n>" "Set temperature"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/max <n>" "Set max tokens"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/workspace <dir>" "Set agent workspace (run)"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/voice" "Dictate with Termux:API (editable prompt)"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/clear" "Reset conversation"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/history" "Show conversation history"
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/status" "Show current settings"
	if [[ "$mode" != "ask" ]]; then
		printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/plan" "Plan mode (read-only) — next task only inspects and proposes"
		printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/build" "Build mode — next task applies files and commands"
	fi
	printf "    ${D_CYAN}%-14s${D_NC} %s\n" "/exit" "Leave the interactive shell"
	echo
}

# ------------------------------------------------------------
# agent_parse_args — unified flag parser for ask/run
#   -p|--prompt <text>  -m|--model <id>  -u|--endpoint <url>
#   -t|--temperature <n>  --max-tokens <n>
#   -w|--workspace <dir>  -n|--max-iterations <n>
# Any positional argument is treated as the prompt.
# ------------------------------------------------------------
agent_parse_args() {
	AGENT_PROMPT=""
	AGENT_SHOW_HELP=0
	AGENT_YES=0
	local prev=""
	for arg in "$@"; do
		case "$prev" in
		-p | --prompt) AGENT_PROMPT="$arg"; prev=""; continue ;;
		-m | --model) AGENT_MODEL="$arg"; prev=""; continue ;;
		-u | --endpoint) AGENT_ENDPOINT="$arg"; prev=""; continue ;;
		-t | --temperature) AGENT_TEMPERATURE="$arg"; prev=""; continue ;;
		-w | --workspace) AGENT_WORKSPACE="$arg"; prev=""; continue ;;
		-n | --max-iterations) AGENT_MAX_ITERATIONS="$arg"; prev=""; continue ;;
		--max-tokens) AGENT_MAX_TOKENS="$arg"; prev=""; continue ;;
		esac
		case "$arg" in
		-p=* | --prompt=*) AGENT_PROMPT="${arg#*=}" ;;
		-m=* | --model=*) AGENT_MODEL="${arg#*=}" ;;
		-u=* | --endpoint=*) AGENT_ENDPOINT="${arg#*=}" ;;
		-t=* | --temperature=*) AGENT_TEMPERATURE="${arg#*=}" ;;
		-w=* | --workspace=*) AGENT_WORKSPACE="${arg#*=}" ;;
		-n=* | --max-iterations=*) AGENT_MAX_ITERATIONS="${arg#*=}" ;;
		--max-tokens=*) AGENT_MAX_TOKENS="${arg#*=}" ;;
		-p | --prompt | -m | --model | -u | --endpoint | -t | --temperature | -w | --workspace | -n | --max-iterations | --max-tokens) prev="$arg" ;;
		--plan) AGENT_PLAN_MODE=1 ;;
		--build) AGENT_PLAN_MODE=0 ;;
		-y | --yes) AGENT_YES=1 ;;
		-h | --help) AGENT_SHOW_HELP=1 ;;
		-*) log_warn "Unknown option: $arg" ;;
		*) [[ -z "$AGENT_PROMPT" ]] && AGENT_PROMPT="$arg" ;;
		esac
	done
}
readonly AGENT_ASK_SYSTEM="You are a concise chat assistant. Reply in the SAME LANGUAGE the user writes in. Be direct and practical; use markdown, and put code in fenced blocks. <attached_file path=\"...\">...</attached_file> blocks hold real file contents (action=\"no-read\" = path only). <compacted_summary>...</compacted_summary> blocks are condensed summaries of earlier turns — treat them as ground truth."

# ------------------------------------------------------------
# agent_show_answer <response> — render markdown
# ------------------------------------------------------------
agent_show_answer() {
	local resp="$1"
	md_render "$resp"
}

# ------------------------------------------------------------
# agent_strip_meta_blocks <text> — remove <compacted_summary>
# blocks that the model sometimes echoes back into its answer.
# ------------------------------------------------------------
agent_strip_meta_blocks() {
	local text="$1"
	printf '%s' "$text" | sed -e 's/<compacted_summary>.*<\/compacted_summary>//g' \
		-e '/<compacted_summary>/,/<\/compacted_summary>/d'
}

# ------------------------------------------------------------
# agent_clean_output <text> — post-process a model answer with
# pure bash so the system prompts stay short: drop echoed
# <compacted_summary> blocks and translate the LaTeX math the
# model loves to emit ($\rightarrow$, \Rightarrow, ...) into
# unicode arrows so they render instead of showing as raw text.
# ------------------------------------------------------------
agent_clean_output() {
	local text="$1"
	text=$(agent_strip_meta_blocks "$text")
	text=$(printf '%s' "$text" | sed \
		-e 's/\$\\rightarrow\$/→/g' \
		-e 's/\$\\Rightarrow\$/⇒/g' \
		-e 's/\$\\leftarrow\$/←/g' \
		-e 's/\$\\Leftarrow\$/⇐/g' \
		-e 's/\$\\to\$/→/g' \
		-e 's/\$\\leftarrow\$/←/g' \
		-e 's/\\rightarrow/→/g' \
		-e 's/\\Rightarrow/⇒/g' \
		-e 's/\\leftarrow/←/g' \
		-e 's/\\Leftarrow/⇐/g' \
		-e 's/\\to\b/→/g')
	printf '%s' "$text"
}

# ------------------------------------------------------------
# agent_response_has_summary <text> — true if the model's answer
# already ends with a substantial prose summary AFTER its last
# action (file/command) block. Lets the run loop finish in one
# iteration when the model did the work AND wrote the summary,
# instead of forcing a redundant "final summary" iteration.
# ------------------------------------------------------------
agent_response_has_summary() {
	local text="$1"
	local trail prose
	trail=$(printf '%s\n' "$text" | awk '
		BEGIN { in_fence=0; last=0 }
		/^[[:space:]]*```/ { in_fence = !in_fence; last=NR; next }
		!in_fence && /^[[:space:]]*\$[[:space:]]/ { last=NR; next }
		{ a[NR]=$0 }
		END { for (i=last+1; i<=NR; i++) print a[i] }
	')
	prose=$(printf '%s\n' "$trail" | sed '/^[[:space:]]*#/d' | tr '\n' ' ')
	prose=$(printf '%s\n' "$prose" | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//')
	[[ "${#prose}" -ge 40 ]]
}

# ------------------------------------------------------------
# agent_ask_once <prompt> — single-shot assistant answer
# ------------------------------------------------------------
agent_ask_once() {
	local prompt="$1"
	prompt=$(agent_prepare_prompt "$prompt")
	if ! agent_check_server; then echo; return 1; fi

	local history outfile resp
	history=$(agent_history_new)
	history=$(agent_history_system "$history" "$AGENT_ASK_SYSTEM")
	history=$(agent_history_add "$history" user "$prompt")

	echo
	box_large "Ask"
	echo

	outfile=$(agent_md_dir)/ask_stream.txt
	AGENT_ABORT=0
	if agent_exec_loading "Asking ${D_CYAN}$AGENT_MODEL${D_NC}…" agent_chat_text_to "$history" "$outfile"; then
		resp=$(agent_clean_output "$(cat "$outfile")")
		echo
		if [[ -z "$resp" ]]; then
			log_warn "Empty response from the model"
		else
			agent_show_answer "$resp"
		fi
	elif (( AGENT_ABORT )); then
		echo
	else
		log_error "Request failed (is the server running?)"
	fi
	echo
}

# ------------------------------------------------------------
# agent_repl_handle <line> — common slash-command handler.
# Returns 0 (continue), 1 (exit). Uses global AGENT_REPL_HISTORY.
# ------------------------------------------------------------
agent_repl_handle() {
	local line="$1"
	local mode="${2:-$AGENT_REPL_MODE}"
	case "$line" in
	/help | help)
		agent_repl_help "$mode"
		return 0
		;;
	/exit | /quit | /q | exit | quit)
		return 1
		;;
	/clear)
		AGENT_REPL_HISTORY=$(agent_history_new)
		AGENT_REPL_STEPS=0
		log_success "Conversation cleared"
		echo
		return 0
		;;
	/status)
		echo
		agent_status_line
		echo
		return 0
		;;
	/plan | /build)
		if [[ "$mode" == "ask" ]]; then
			echo
			log_warn "Plan/Build modes only exist in ${D_CYAN}core agent run${D_NC} — ask is a plain chat"
			echo
			return 0
		fi
		if [[ "$line" == "/plan" ]]; then
			AGENT_PLAN_MODE=1
			echo
			log_success "Mode → ${D_CYAN}PLAN (read-only)${D_NC} — file blocks and write commands will be ignored"
			list_item "Next task will only run read-only commands and produce a plan"
		else
			AGENT_PLAN_MODE=0
			echo
			log_success "Mode → ${D_CYAN}BUILD (full access)${D_NC} — files and commands will be applied"
		fi
		echo
		return 0
		;;
	/voice)
		echo
		printf '    %sListening… speak now, then stop the dialog when done%s\n' "$D_CYAN" "$NC"
		echo
		if agent_voice_capture; then
			AGENT_REPL_PREFILL="$AGENT_VOICE_TEXT"
			log_success "Transcribed — edit it below, then press Enter to send:"
			printf '    %s%s%s\n' "$D_GREEN" "$AGENT_VOICE_TEXT" "$NC"
		fi
		echo
		return 0
		;;
	/model*)
		local m="${line#/model }"
		m="${m#/model}"
		m=$(echo "$m" | xargs)
		if [[ -z "$m" ]]; then
			log_info "Available models:"
			agent_models_list 2>/dev/null | sed 's/^/    /' || log_warn "Cannot list models (check endpoint)"
			agent_read_input "Model name" m
		fi
		if [[ -z "$m" ]]; then return 0; fi
		AGENT_MODEL="$m"
		log_success "Model → ${D_CYAN}$AGENT_MODEL${D_NC}"
		return 0
		;;
	/endpoint*)
		local e="${line#/endpoint }"
		e="${e#/endpoint}"
		e=$(echo "$e" | xargs)
		if [[ -z "$e" ]]; then agent_read_input "Endpoint URL (e.g. http://127.0.0.1:8000/v1)" e; fi
		if [[ -z "$e" ]]; then return 0; fi
		AGENT_ENDPOINT="$e"
		log_success "Endpoint → ${D_CYAN}$AGENT_ENDPOINT${D_NC}"
		return 0
		;;
	/temp*)
		local t="${line#/temp }"
		t="${t#/temp}"
		t=$(echo "$t" | xargs)
		if [[ -z "$t" ]]; then agent_read_input "Temperature (0-2)" t; fi
		if [[ -n "$t" ]]; then AGENT_TEMPERATURE="$t"; log_success "Temperature → ${D_CYAN}$AGENT_TEMPERATURE${D_NC}"; fi
		return 0
		;;
	/max*)
		local mx="${line#/max }"
		mx="${mx#/max}"
		mx=$(echo "$mx" | xargs)
		if [[ -z "$mx" ]]; then agent_read_input "Max tokens" mx; fi
		if [[ -n "$mx" ]]; then AGENT_MAX_TOKENS="$mx"; log_success "Max tokens → ${D_CYAN}$AGENT_MAX_TOKENS${D_NC}"; fi
		return 0
		;;
	/workspace*)
		local ws="${line#/workspace }"
		ws="${ws#/workspace}"
		ws=$(echo "$ws" | xargs)
		if [[ -z "$ws" ]]; then agent_read_input "Workspace directory (absolute path)" ws; fi
		if [[ -n "$ws" ]]; then
			mkdir -p "$ws"
			AGENT_WORKSPACE="$ws"
			log_success "Workspace → ${D_CYAN}$AGENT_WORKSPACE${D_NC}"
		fi
		return 0
		;;
	/history)
		echo
		if [[ "$(echo "$AGENT_REPL_HISTORY" | jq 'length')" == "0" ]]; then
			log_warn "No history yet"
		else
			echo "$AGENT_REPL_HISTORY" | jq -r '.[] | "  [" + .role + "] " + (.content | .[0:120] | gsub("[\r\n]"; " "))' | sed 's/^/    /'
		fi
		echo
		return 0
		;;
	*)
		return 2
		;;
	esac
}
# ------------------------------------------------------------
# agent_ask — entry point
# ------------------------------------------------------------
agent_ask() {
	agent_parse_args "$@"
	if (( AGENT_SHOW_HELP )); then
		agent_help
		return 0
	fi
	if [[ -n "$AGENT_PROMPT" ]]; then
		# traps before ensure: Ctrl+C during the startup wait also stops it
		trap 'agent_server_stop; exit 130' INT
		trap 'agent_server_stop' EXIT
		agent_server_ensure
		agent_ask_once "$AGENT_PROMPT"
		agent_server_stop
		trap - INT EXIT
	else
		agent_ask_repl
	fi
}

# ------------------------------------------------------------
# agent_ask_repl — interactive chat with streaming
# ------------------------------------------------------------
agent_ask_repl() {
	AGENT_REPL_HISTORY=$(agent_history_new)
	AGENT_REPL_STEPS=0
	AGENT_REPL_MODE=ask

	# traps must exist before the server starts, so Ctrl+C during the
	# startup wait also stops a server we just launched
	trap 'agent_server_stop; exit 130' INT
	trap 'agent_server_stop' EXIT

	# start the model server first (if down): shows the starting message
	# and waits for it with a loading spinner, then clear the screen so
	# the welcome banner starts clean.
	agent_server_ensure
	clear

	agent_banner
	separator_section "Core Agent — Ask"
	echo
	agent_status_line
	echo
	list_item "Type ${D_CYAN}/help${D_NC} to see all commands"
	echo

	agent_repl_bind

	local line outfile resp _ems
	while true; do
		if ! agent_repl_read; then
			break
		fi
		line="$AGENT_REPL_LINE"
		[[ -z "$line" ]] && continue

		agent_repl_handle "$line" "$AGENT_REPL_MODE"
		local hc=$?
		if (( hc == 1 )); then
			break
		elif (( hc == 0 )); then
			continue
		fi

		# shell mode: !command runs it and feeds the output to the agent
		if [[ "$line" == '!'* ]]; then
			agent_shell_cmd "$line"
			continue
		fi

		# actual message — expand @file references
		line=$(agent_prepare_prompt "$line")
		if ! agent_check_server; then echo; continue; fi
		AGENT_REPL_HISTORY=$(agent_history_add "$AGENT_REPL_HISTORY" user "$line")
		AGENT_REPL_HISTORY=$(agent_history_ensure_system "$AGENT_REPL_HISTORY" "$AGENT_ASK_SYSTEM")
		AGENT_REPL_HISTORY=$(agent_history_manage "$AGENT_REPL_HISTORY" "$AGENT_CONTEXT_WINDOW")

		echo
		outfile=$(agent_md_dir)/ask_stream.txt
		agent_timer_start
		AGENT_ABORT=0
		if agent_exec_loading "Asking ${D_CYAN}$AGENT_MODEL${D_NC}…" agent_chat_text_to "$AGENT_REPL_HISTORY" "$outfile"; then
			_ems=$(agent_timer_ms)
			resp=$(agent_clean_output "$(cat "$outfile")")
			echo
			if [[ -n "$resp" ]]; then
				agent_show_answer "$resp"
				AGENT_REPL_HISTORY=$(agent_history_add "$AGENT_REPL_HISTORY" assistant "$resp")
				printf '    %s[context %s]%s\n' "$D_GRAY" "$(agent_context_footer "$AGENT_REPL_HISTORY" "$_ems")" "$NC"
			fi
		elif (( AGENT_ABORT )); then
			echo
			continue
		else
			log_error "Request failed (is the server running?)"
			echo
		fi
	done
	agent_repl_unbind
	agent_server_stop
	trap - INT EXIT
	echo
	if (( AGENT_CANCEL )); then
		log_warn "Aborted — you pressed ESC ESC"
		echo
	fi
}

# ------------------------------------------------------------
# agent_run — entry point
# ------------------------------------------------------------
agent_run() {
	agent_parse_args "$@"
	if (( AGENT_SHOW_HELP )); then
		agent_help
		return 0
	fi
	AGENT_ACTIONS_WORKSPACE="$AGENT_WORKSPACE"
	mkdir -p "$AGENT_WORKSPACE" 2>/dev/null

	if [[ -n "$AGENT_PROMPT" ]]; then
		# traps before ensure: Ctrl+C during the startup wait also stops it
		trap 'agent_server_stop; exit 130' INT
		trap 'agent_server_stop' EXIT
		agent_server_ensure
		AGENT_PROMPT=$(agent_prepare_prompt "$AGENT_PROMPT")
		agent_run_loop "$AGENT_PROMPT"
		agent_server_stop
		trap - INT EXIT
	else
		agent_run_repl
	fi
}

# ------------------------------------------------------------
# agent_run_repl — interactive: every message is a new task
# ------------------------------------------------------------
agent_run_repl() {
	AGENT_REPL_HISTORY=$(agent_history_new)
	AGENT_REPL_STEPS=0
	AGENT_REPL_MODE=run

	# traps must exist before the server starts, so Ctrl+C during the
	# startup wait also stops a server we just launched
	trap 'agent_server_stop; exit 130' INT
	trap 'agent_server_stop' EXIT

	# start the model server first (if down): shows the starting message
	# and waits for it with a loading spinner, then clear the screen so
	# the welcome banner starts clean.
	agent_server_ensure
	clear

	agent_banner
	separator_section "Core Agent — Run ($([[ $AGENT_PLAN_MODE == 1 ]] && echo 'PLAN · read-only' || echo 'BUILD mode'))"
	echo
	agent_status_line
	echo
	list_item "Type ${D_CYAN}/help${D_NC} to see all commands"
	echo

	agent_repl_bind

	local line
	while true; do
		if ! agent_repl_read; then
			break
		fi
		line="$AGENT_REPL_LINE"
		[[ -z "$line" ]] && continue

		agent_repl_handle "$line" "$AGENT_REPL_MODE"
		local hc=$?
		if (( hc == 1 )); then
			break
		elif (( hc == 0 )); then
			continue
		fi

		# shell mode: !command runs it and feeds the output to the agent
		if [[ "$line" == '!'* ]]; then
			agent_shell_cmd "$line"
			continue
		fi

		# expand @file references
		line=$(agent_prepare_prompt "$line")
		if ! agent_check_server; then echo; continue; fi
		AGENT_ACTIONS_WORKSPACE="$AGENT_WORKSPACE"
		agent_run_loop "$line" "$AGENT_REPL_HISTORY"
	done
	agent_repl_unbind
	agent_server_stop
	trap - INT EXIT
	echo
	if (( AGENT_CANCEL )); then
		log_warn "Aborted — you pressed ESC ESC"
		echo
	fi
}

# ------------------------------------------------------------
# agent_run_loop <prompt> [history] — the core agent loop:
#   LLM answers in markdown → bash parses files & commands →
#   bash creates the files / runs the approved commands →
#   results go back to the LLM until it writes a final summary
# ------------------------------------------------------------
agent_run_loop() {
	local user_prompt="$1"
	local shared_history="${2:-}"
	local system history
	system=$(agent_system_prompt "$AGENT_WORKSPACE")
	if [[ -n "$shared_history" && "$shared_history" != "[]" ]]; then
		history="$shared_history"
	else
		history=$(agent_history_new)
	fi
	# always (re)set the front system prompt to the CURRENT mode's prompt
	history=$(agent_history_ensure_system "$history" "$system")
	history=$(agent_history_add "$history" user "$user_prompt")

	AGENT_ACTIONS_WORKSPACE="$AGENT_WORKSPACE"
	AGENT_ABORT=0
	agent_timer_start
	# fresh read-dedup registry per task
	: >"$(agent_md_dir)/ran_commands.txt"

	local iter=0 step=0 resp outfile parsed nfiles ncmds results rfile _ems
	while (( iter < AGENT_MAX_ITERATIONS )); do
		step=$((iter + 1))
		printf '    %s[%s/%s]%s %sthinking…%s\n' "$D_GRAY" "$step" "$AGENT_MAX_ITERATIONS" "$NC" "$D_PURPLE" "$NC"

		outfile=$(agent_md_dir)/run_stream.txt
		if agent_exec_loading "  model reasoning…" agent_chat_text_to "$history" "$outfile"; then
			resp=$(agent_clean_output "$(cat "$outfile")")
		elif (( AGENT_ABORT )); then
			break
		else
			log_error "Request failed (is the server running?)"
			break
		fi
		if [[ -z "$resp" ]]; then
			log_error "Empty response from the model (is the server running?)"
			break
		fi

		# visual feedback: render the full markdown answer on screen
		echo
		md_render "$resp"

		parsed=$(agent_parse_response "$resp")
		read -r nfiles ncmds <<<"$parsed"

		# no files and no commands → this is the final answer
		if (( nfiles == 0 && ncmds == 0 )); then
			history=$(agent_history_add "$history" assistant "$resp")
			break
		fi

		history=$(agent_history_add "$history" assistant "$resp")

		AGENT_FILES_WRITTEN=0
		if (( nfiles > 0 )); then
			if (( AGENT_PLAN_MODE )); then
				# PLAN mode: never write; just tell the model what was skipped
				echo
				separator_section "Plan mode — files skipped"
				printf '    %s↳ %s ## File: block(s) NOT written (read-only mode)%s\n' "$D_GRAY" "$nfiles" "$NC"
				AGENT_FILES_WRITTEN=0
			else
				agent_apply_files
				# file writes invalidate earlier reads: allow re-reading to verify
				(( AGENT_FILES_WRITTEN > 0 )) && : >"$(agent_md_dir)/ran_commands.txt"
			fi
		fi

		results=""
		if (( ncmds > 0 )); then
			echo
			separator_section "Running commands"
			agent_execute_commands
			if (( AGENT_ABORT )); then
				break
			fi
			rfile="$(agent_md_dir)/command_results.txt"
			[[ -s "$rfile" ]] && results=$(cat "$rfile")
		fi

		# The model already wrote its final summary in this response and
		# there is no command output left to fold in — the task is done.
		# Only files were written (or nothing at all), so forcing another
		# iteration just to repeat the summary would be wasteful.
		if (( ! AGENT_PLAN_MODE )) && [[ -z "$results" ]] && agent_response_has_summary "$resp"; then
			break
		fi

		if [[ -n "$results" ]]; then
			history=$(agent_history_add "$history" user "$results")
		fi

		if (( AGENT_PLAN_MODE )); then
			# plan mode: keep the model from trying to apply changes
			if (( nfiles > 0 )); then
				history=$(agent_history_add "$history" user "<system>PLAN mode is active (read-only): your ## File: blocks were NOT written and write commands were blocked. Only read-only commands ran. Now present your plan (files to create or edit with their proposed content, commands to run). Do NOT emit more file blocks or write commands until the user switches to BUILD mode (type /build).</system>")
			elif [[ -z "$results" ]]; then
				history=$(agent_history_add "$history" user "<system>PLAN mode is active (read-only). Keep inspecting with read-only command blocks if needed; when ready, write your analysis and plan as a final summary with NO file or command blocks.</system>")
			fi
		elif [[ -z "$results" ]]; then
			if (( AGENT_FILES_WRITTEN > 0 )); then
				history=$(agent_history_add "$history" user "<system>Files were created or updated. Verify them with a command block if needed, then write your final summary (markdown) with no file or command blocks.</system>")
			else
				history=$(agent_history_add "$history" user "<system>No files were written and no commands ran (any file blocks the response contained targeted write-protected no-read files, or were identical to files already on disk, and were skipped). If the task needs a shell action (delete/move/rename/run/...), you MUST emit it as a \`$ \` or \`\`\`bash command block — a \`## File:\` block never runs anything and is ignored for write-protected files. Then finish with a short summary.</system>")
			fi
		fi

		history=$(agent_history_manage "$history" "$AGENT_CONTEXT_WINDOW")
		((iter++))
	done

	if (( iter >= AGENT_MAX_ITERATIONS )); then
		echo
		log_warn "Stopped after $AGENT_MAX_ITERATIONS iterations (task too complex?)"
	fi
	AGENT_REPL_HISTORY="$history"
	_ems=$(agent_timer_ms)
	echo
	printf '    %s[context %s]%s\n' "$D_GRAY" "$(agent_context_footer "$AGENT_REPL_HISTORY" "$_ems")" "$NC"
}