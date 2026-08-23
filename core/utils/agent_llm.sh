#!/usr/bin/env bash

# ============================================================
# agent_llm.sh — config + OpenAI-compatible chat calls for
# `core agent`. Pure bash; curl + jq.
# ============================================================

import "@/utils/log"
import "@/utils/colors"

AGENT_CONF_DIR="$CORE_CONFIG/agent"
AGENT_CONF_FILE="$AGENT_CONF_DIR/agent.conf"

# ---- defaults ----
AGENT_MODEL="${AGENT_MODEL:-gemma-4-e2b-it-cq4}"
AGENT_ENDPOINT="${AGENT_ENDPOINT:-http://127.0.0.1:8000/v1}"
AGENT_TEMPERATURE="${AGENT_TEMPERATURE:-0.3}"
AGENT_MAX_TOKENS="${AGENT_MAX_TOKENS:-2048}"
AGENT_MAX_ITERATIONS="${AGENT_MAX_ITERATIONS:-12}"
AGENT_WORKSPACE="${AGENT_WORKSPACE:-$PWD}"
AGENT_CONFIRM_COMMANDS="${AGENT_CONFIRM_COMMANDS:-1}"
AGENT_CONTEXT_WINDOW="${AGENT_CONTEXT_WINDOW:-8192}"
AGENT_SERVER_CMD="${AGENT_SERVER_CMD:-cactus serve Cactus-Compute/gemma-4-E2B-it --host 127.0.0.1 --port 8000 --no-cloud-handoff}"

# ------------------------------------------------------------
# agent_config_load — read persisted config
# ------------------------------------------------------------
agent_config_load() {
	mkdir -p "$AGENT_CONF_DIR"
	if [[ -f "$AGENT_CONF_FILE" ]]; then
		# shellcheck disable=SC1090
		source "$AGENT_CONF_FILE"
	fi
	AGENT_MODEL="${AGENT_MODEL:-gemma-4-e2b-it-cq4}"
	AGENT_ENDPOINT="${AGENT_ENDPOINT:-http://127.0.0.1:8000/v1}"
	AGENT_TEMPERATURE="${AGENT_TEMPERATURE:-0.3}"
	AGENT_MAX_TOKENS="${AGENT_MAX_TOKENS:-2048}"
	AGENT_MAX_ITERATIONS="${AGENT_MAX_ITERATIONS:-12}"
	# the agent ALWAYS starts in the directory you run it from — the
	# workspace is never loaded from the persisted config (a stale
	# saved path used to pin the agent to $HOME/.core). Override
	# it per session with `-w/--workspace` or `/workspace`.
	AGENT_WORKSPACE="$PWD"
	AGENT_CONFIRM_COMMANDS="${AGENT_CONFIRM_COMMANDS:-1}"
	AGENT_CONTEXT_WINDOW="${AGENT_CONTEXT_WINDOW:-8192}"
AGENT_SERVER_CMD="${AGENT_SERVER_CMD:-cactus serve Cactus-Compute/gemma-4-E2B-it --host 127.0.0.1 --port 8000 --no-cloud-handoff}"
}

# ------------------------------------------------------------
# agent_config_save — persist current settings
# ------------------------------------------------------------
agent_config_save() {
	mkdir -p "$AGENT_CONF_DIR"
	cat >"$AGENT_CONF_FILE" <<EOF
# core agent — persisted settings
AGENT_MODEL="$AGENT_MODEL"
AGENT_ENDPOINT="$AGENT_ENDPOINT"
AGENT_TEMPERATURE=$AGENT_TEMPERATURE
AGENT_MAX_TOKENS=$AGENT_MAX_TOKENS
AGENT_MAX_ITERATIONS=$AGENT_MAX_ITERATIONS
AGENT_CONFIRM_COMMANDS=$AGENT_CONFIRM_COMMANDS
AGENT_CONTEXT_WINDOW=$AGENT_CONTEXT_WINDOW
AGENT_SERVER_CMD="$AGENT_SERVER_CMD"
EOF
}

# ------------------------------------------------------------
# agent_config_set <key> <value>
# ------------------------------------------------------------
agent_config_set() {
	local key="$1" value="$2"
	agent_config_load
	case "$key" in
	model | --model | -m) AGENT_MODEL="$value" ;;
	endpoint | --endpoint | -u) AGENT_ENDPOINT="$value" ;;
	temp | temperature) AGENT_TEMPERATURE="$value" ;;
	max_tokens | maxtokens) AGENT_MAX_TOKENS="$value" ;;
	iterations | max_iterations) AGENT_MAX_ITERATIONS="$value" ;;
	confirm_commands | confirm) AGENT_CONFIRM_COMMANDS="$value" ;;
	context_window | context) AGENT_CONTEXT_WINDOW="$value" ;;
	server_command | server) AGENT_SERVER_CMD="$value" ;;
	workspace) AGENT_WORKSPACE="$value" ;;
	*)
		log_error "Unknown setting: $key"
		echo
		agent_config_help
		return 1
		;;
	esac
	agent_config_save
}

# ------------------------------------------------------------
# agent_chat_url — full /chat/completions URL from endpoint
# ------------------------------------------------------------
agent_chat_url() {
	local e="${AGENT_ENDPOINT%/}"
	case "$e" in
	*/chat/completions) echo "$e" ;;
	*/v1) echo "$e/chat/completions" ;;
	*) echo "$e/v1/chat/completions" ;;
	esac
}

# ------------------------------------------------------------
# agent_models_url — /v1/models URL
# ------------------------------------------------------------
agent_models_url() {
	local e="${AGENT_ENDPOINT%/}"
	case "$e" in
	*/v1) echo "$e/models" ;;
	*/models) echo "$e" ;;
	*/chat/completions) echo "${e%/chat/completions}/models" ;;
	*) echo "$e/v1/models" ;;
	esac
}

# ------------------------------------------------------------
# agent_check_server — 0 if endpoint reachable; echoes status
# ------------------------------------------------------------
agent_check_server() {
	local models
	models=$(curl -fsS -m 6 "$(agent_models_url)" 2>/dev/null) || {
		log_warn "Cannot reach endpoint: ${D_CYAN}$AGENT_ENDPOINT${D_NC}"
		list_item "Start your server, e.g.: ${D_CYAN}cactus serve Cactus-Compute/gemma-4-E2B-it --host 127.0.0.1 --port 8000 --no-cloud-handoff${D_NC}"
		return 1
	}
	if command -v jq &>/dev/null && echo "$models" | jq -e '.data' &>/dev/null; then
		local ids
		ids=$(echo "$models" | jq -r '.data[].id')
		if ! echo "$ids" | grep -q "^${AGENT_MODEL}$"; then
			log_warn "Model ${D_CYAN}$AGENT_MODEL${D_NC} not found in endpoint. Available:"
			echo "$ids" | sed 's/^/    /'
		fi
			fi
	}
# ------------------------------------------------------------
# agent_models_list — echo available model ids (one per line)
# ------------------------------------------------------------
agent_models_list() {
	local models
	models=$(curl -fsS -m 6 "$(agent_models_url)" 2>/dev/null) || return 1
	echo "$models" | jq -r '.data[].id // empty' 2>/dev/null
	}

# ------------------------------------------------------------
# agent_build_payload <messages_json> [extra] — build request
# ------------------------------------------------------------
agent_build_payload() {
	local messages="$1"
	local extra="${2:-}"
	local payload
	payload=$(jq -nc \
		--arg model "$AGENT_MODEL" \
		--argjson msgs "$messages" \
		--argjson temp "$AGENT_TEMPERATURE" \
		--argjson mt "$AGENT_MAX_TOKENS" \
		'{model:$model, messages:$msgs, temperature:$temp, max_tokens:$mt}')
	if [[ -n "$extra" ]]; then
		payload=$(echo "$payload" | jq -c "$extra")
	fi
	echo "$payload"
}

# ------------------------------------------------------------
# agent_chat_completion <messages_json> — non-streaming POST.
# Echoes the full response JSON. Returns 0 on HTTP ok.
# ------------------------------------------------------------
agent_chat_completion() {
	local messages="$1"
	local payload
	payload=$(agent_build_payload "$messages")

	local resp http
	resp=$(curl -sS -m 600 -w '\n%{http_code}' \
		"$(agent_chat_url)" \
		-H 'Content-Type: application/json' \
		-d "$payload" 2>&1)
	http=$(printf '%s\n' "$resp" | tail -1)
	resp=$(printf '%s\n' "$resp" | sed '$d')

	if [[ "$http" != "200" ]]; then
		log_error "LLM request failed (HTTP $http)"
		echo "$resp" | head -c 800
		echo
		return 1
	fi
	echo "$resp"
}

# ------------------------------------------------------------
# _agent_unescape_unicode <text> — turn literal \uXXXX escape
# sequences (which this quantized model sometimes writes instead
# of accented characters, e.g. "c\u00f3mo") back into the real
# characters. Real UTF-8 text passes through untouched.
# ------------------------------------------------------------
_agent_unescape_unicode() {
	perl -CS -pe 's/\\u([0-9a-fA-F]{4})/chr(hex($1))/ge' 2>/dev/null
}

# ------------------------------------------------------------
# agent_chat_text <messages_json> — like above but echoes only
# the assistant message.content (empty string if tool_calls).
# ------------------------------------------------------------
agent_chat_text() {
	local messages="$1"
	local resp
	resp=$(agent_chat_completion "$messages") || return 1
	printf '%s' "$resp" | jq -r '.choices[0].message.content // ""' 2>/dev/null | _agent_unescape_unicode
}

# ------------------------------------------------------------
# agent_chat_text_to <messages> <outfile>
# Like agent_chat_text but writes the message to <outfile> (stdout
# stays empty) so it can be wrapped by loading()/spinner helpers
# and retrieved afterwards. Non-streaming -> clean markdown.
# ------------------------------------------------------------
agent_chat_text_to() {
	local messages="$1" outfile="$2"
	agent_chat_text "$messages" >"$outfile" 2>/dev/null
}

# ------------------------------------------------------------
# agent_chat_stream <messages_json> <outfile>
# Streams SSE tokens to the terminal and saves the full message
# (markdown kept intact) into <outfile>. Prints nothing else.
# Returns 0 on success (finish_reason stop) else 1.
# ------------------------------------------------------------
agent_chat_stream() {
	local messages="$1" outfile="$2"
	local payload
	payload=$(agent_build_payload "$messages" '. + {stream:true}')
	: >"$outfile"
	local finish_file="$outfile.finish"
	: >"$finish_file"

	curl -sS -N -m 900 \
		"$(agent_chat_url)" \
		-H 'Content-Type: application/json' \
		-d "$payload" 2>/dev/null | while IFS= read -r line; do
		[[ "$line" == data:* ]] || continue
		line="${line#data: }"
		[[ "$line" == "[DONE]" ]] && break
		delta=$(printf '%s' "$line" | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
		if [[ -n "$delta" ]]; then
			delta=$(printf '%s' "$delta" | _agent_unescape_unicode)
			printf '%s' "$delta"
			printf '%s' "$delta" >>"$outfile"
		fi
		fin=$(printf '%s' "$line" | jq -r '.choices[0].finish_reason // empty' 2>/dev/null)
		if [[ -n "$fin" ]]; then
			printf '%s' "$fin" >"$finish_file"
		fi
	done
	echo
	[[ "$(cat "$finish_file" 2>/dev/null)" == "stop" ]] && return 0 || return 1
}

# ------------------------------------------------------------
# History helpers (messages are a JSON array)
# ------------------------------------------------------------
agent_history_new() {
	echo '[]'
}

agent_history_add() {
	local history="$1" role="$2" content="$3"
	jq -c --arg role "$role" --arg content "$content" \
		'. + [{role:$role, content:$content}]' <<<"$history"
}

# Keep the last N messages (protect the context window)
agent_history_trim() {
	local history="$1" max="${2:-60}"
	local n
	n=$(echo "$history" | jq 'length')
	if (( n > max )); then
		echo "$history" | jq -c ".[$((n - max)):]"
	else
		echo "$history"
	fi
}

agent_history_system() {
	local history="$1" content="$2"
	jq -c --arg content "$content" '[{role:"system", content:$content}] + .' <<<"$history"
}

# Replace (or prepend) the system prompt with the given content, so
# a mode switch doesn't leak one task's system prompt into later
# ask/run messages (and vice versa).
agent_history_ensure_system() {
	local history="$1" content="$2"
	if printf '%s' "$history" | jq -e 'length > 0 and .[0].role == "system"' &>/dev/null; then
		printf '%s' "$history" | jq -c --arg s "$content" '.[0] = {role:"system", content:$s}'
	else
		agent_history_system "$history" "$content"
	fi
}

agent_history_drop_system() {
	local history="$1"
	echo "$history" | jq -c '[.[] | select(.role != "system")]'
}