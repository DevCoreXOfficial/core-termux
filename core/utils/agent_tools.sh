#!/usr/bin/env bash

# ============================================================
# agent_tools.sh — The tool system for `core agent run`.
#
# The model does NOT call any native plugin. Instead it emits a
# fenced JSON block (tool_call) describing which well-defined
# tool it wants; we PARSE it here and execute it with REAL bash
# (cat/sed/awk/rg/jq/mv/rm/...). The result is returned to the
# model inside a <tool_result> block. All heavy lifting is done
# by the shell, exactly as requested.
# ============================================================

import "@/utils/log"
import "@/utils/colors"

AGENT_TOOLS_WORKSPACE="${AGENT_TOOLS_WORKSPACE:-$PWD}"

# ------------------------------------------------------------
# agent_tools_available — list tools actually installed, so the
# system prompt only mentions what really exists.
# ------------------------------------------------------------
agent_tools_available() {
	local names=(curl wget jq rg git sed awk cat ls find stat wc head tail grep sort uniq cut tr xargs mkdir rm mv cp touch tar gzip python3 node npm bun cargo go ffmpeg sqlite3 psql redis-cli)
	local out=()
	local t
	for t in "${names[@]}"; do
		if command -v "$t" &>/dev/null; then
			out+=("$t")
		fi
	done
	local IFS=', '
	echo "${out[*]}"
}
# ------------------------------------------------------------
# agent_system_prompt <workspace> — builds the full system prompt
# taught to the model. Uses a quoted heredoc so backticks inside
# are safe, then swaps {PLACEHOLDERS}.
# ------------------------------------------------------------
agent_system_prompt() {
	local workspace="$1"
	local tools
	tools=$(agent_tools_available)

	sed -e "s|{WORKSPACE}|$workspace|g" \
		-e "s|{HOME}|$HOME|g" \
		-e "s|{PWD}|$PWD|g" \
		-e "s|{TOOLS}|$tools|g" <<'AGENT_SYSTEM_PROMPT'
You are "Core Agent", an autonomous CLI agent embedded in Core-Termux (a bash CLI toolkit) running inside Termux, an Android Linux terminal emulator. Your job is to complete the user's task on this real machine by issuing well-defined TOOL CALLS. You are very good at reasoning; the machine is very good at executing. Every tool call is implemented with plain bash by the host, so you must describe precisely what to do.

## ENVIRONMENT FACTS (trust these, never invent paths)
- OS: Termux (Android), Linux-ish environment, bash shell.
- Real home directory: {HOME}
- Current working directory: {PWD}
- Your workspace: {WORKSPACE}
- Installed tools you can use: {TOOLS}
- Use ONLY real absolute paths. NEVER guess a path exists; list/read first when unsure.

## TOOL CALL PROTOCOL (critical, follow exactly)
To use a tool, reply with EXACTLY ONE fenced code block whose info string is `tool_call` containing a single JSON object. Do NOT add prose before or after the block, do NOT put two tool calls in one message, do NOT use the native function-calling format. Example:

```tool_call
{"tool": "list_files", "path": "{WORKSPACE}", "recursive": false}
```

The host executes your JSON with bash and replies with a <tool_result> message containing <output> (or <error>). You then continue: either issue the next tool call, or — when the task is finished — write a short final answer in prose. Markdown is welcome in the final answer (headings, lists, code blocks), and any code you want the user to have can be shown in a normal ```code block.

## TOOL CATALOG (use ONLY these; every one runs as REAL bash)
1. write_file — create or overwrite a file.
   {"tool":"write_file","path":"/abs/path","content":"entire final content"}
   Runs: mkdir -p on parent dir + cat/printf > file. Give the FULL final content, no "..." placeholders.
2. read_file — read a file, max 1500 lines per call.
   {"tool":"read_file","path":"/abs/path"} (optional "start_line":10,"end_line":50)
   Runs: sed -n 'start,endp'. Useful before editing.
3. append_file — add content at the end of a file.
   {"tool":"append_file","path":"/abs/path","content":"text to add"}
4. edit_file — replace the FIRST occurrence of old_text with new_text (multiline OK).
   {"tool":"edit_file","path":"/abs/path","old_text":"exact existing text","new_text":"replacement"}
   Runs: bash parameter substitution on the file content, so old_text must match byte-for-byte (including newlines). Read the file first!
5. delete_file — remove a file. {"tool":"delete_file","path":"/abs/path"}
6. rename_file — move/rename a file. {"tool":"rename_file","path":"/abs/old","new_path":"/abs/new"}
7. copy_file — copy a file. {"tool":"copy_file","path":"/abs/src","dest":"/abs/dst"}
8. list_files — list a directory. {"tool":"list_files","path":"/abs/dir"} optional "recursive":true (uses find).
9. search_files — text search with ripgrep.
   {"tool":"search_files","pattern":"regex","path":"/abs/dir"} optional "file_glob":"*.sh"
10. file_info — size, line count, type of a file. {"tool":"file_info","path":"/abs/path"}
11. run_command — run an arbitrary bash command to inspect or modify the system.
    {"tool":"run_command","command":"ls -la && du -sh ."}
    The command is executed with `bash -c` inside your workspace directory with a 60s timeout. Its stdout/stderr are returned.

## BASH GUIDELINES (read carefully — the host executes exactly what you write)
- Use ONLY real bash syntax. Never invent flags or utilities. If unsure a flag exists, first run `command --help` or `man command` via run_command.
- Quote every path: ls -la "$HOME/my dir".
- Use $(...) for command substitution — never backticks.
- Chain commands with && or ;. Avoid set -e unless failure must abort the rest.
- Prefer installed tools: jq for JSON, rg for search, sed/awk for text transforms, git for repos.
- Do NOT use sudo (Termux has no sudo). Do NOT attempt package installs unless the user explicitly asks.
- Keep commands simple, deterministic, and idempotent where possible.
- Commands run in a fresh bash; state does not persist between run_command calls (environment variables do NOT carry over). Persist data in files instead.

## WORKFLOW RULES
- Never claim you performed an action unless a tool actually ran and returned success.
- When a tool returns <error>, read it and retry with a corrected call (fix paths, quote properly, check existence first).
- Plan multi-step tasks: inspect → act → verify (read the file back or run the command) → summarize.
- One tool call per message. When done, summarize: what you created/changed, which commands ran, and the results.
AGENT_SYSTEM_PROMPT
}
# ------------------------------------------------------------
# agent_tool_result_ok/err — wrap tool feedback for the model
# ------------------------------------------------------------
agent_tool_result_ok() {
	printf '<tool_result tool="%s" ok="true">\n<output>\n%s\n</output>\n</tool_result>\n' "$1" "$2"
}

agent_tool_result_err() {
	printf '<tool_result tool="%s" ok="false">\n<error>\n%s\n</error>\n</tool_result>\n' "$1" "$2"
}

# ------------------------------------------------------------
# agent_first_replace <text> <old> <new> — replace first
# occurrence (multiline safe, pure bash). Echoes result; returns
# 1 if old not found.
# ------------------------------------------------------------
agent_first_replace() {
	local text="$1" old="$2" new="$3"
	if [[ "$text" == *"$old"* ]]; then
		printf '%s' "${text%%"$old"*}${new}${text#*"$old"}"
		return 0
	fi
	printf '%s' "$text"
	return 1
}

# ------------------------------------------------------------
# agent_tool_run <json> — execute ONE tool_call. Prints the
# <tool_result> block for the model.
# ------------------------------------------------------------
agent_tool_run() {
	local json="$1"
	local tool
	tool=$(printf '%s' "$json" | jq -r '.tool // empty' 2>/dev/null)
	if [[ -z "$tool" ]]; then
		agent_tool_result_err "?" "Malformed tool_call JSON: $(printf '%s' "$json" | head -c 300)"
		return 1
	fi

	local path content start end
	path=$(printf '%s' "$json" | jq -r '.path // empty' 2>/dev/null)
	content=$(printf '%s' "$json" | jq -r '.content // ""' 2>/dev/null)
	start=$(printf '%s' "$json" | jq -r '.start_line // empty' 2>/dev/null)
	end=$(printf '%s' "$json" | jq -r '.end_line // empty' 2>/dev/null)

	local out
	out=""

	case "$tool" in
	write_file)
		if [[ -z "$path" ]]; then agent_tool_result_err "$tool" "missing 'path'"; return 1; fi
		mkdir -p "$(dirname "$path")" 2>/dev/null
		if printf '%s' "$content" >"$path" 2>/dev/null; then
			agent_tool_result_ok "$tool" "OK: wrote $(wc -c <"$path") bytes to $path"
		else
			agent_tool_result_err "$tool" "cannot write $path (permission or invalid path)"
		fi
		;;
	read_file)
		if [[ ! -f "$path" ]]; then agent_tool_result_err "$tool" "file not found: $path"; return 1; fi
		if [[ -n "$start" && -n "$end" ]]; then
			out=$(sed -n "${start},${end}p" "$path" 2>/dev/null)
		else
			out=$(sed -n '1,1500p' "$path" 2>/dev/null)
		fi
		agent_tool_result_ok "$tool" "$out"
		;;
	append_file)
		if [[ -z "$path" ]]; then agent_tool_result_err "$tool" "missing 'path'"; return 1; fi
		mkdir -p "$(dirname "$path")" 2>/dev/null
		if printf '%s' "$content" >>"$path" 2>/dev/null; then
			agent_tool_result_ok "$tool" "OK: appended $(printf '%s' "$content" | wc -c) bytes to $path"
		else
			agent_tool_result_err "$tool" "cannot append to $path"
		fi
		;;
	edit_file)
		if [[ ! -f "$path" ]]; then agent_tool_result_err "$tool" "file not found: $path"; return 1; fi
		local old new text res
		old=$(printf '%s' "$json" | jq -r '.old_text // empty' 2>/dev/null)
		new=$(printf '%s' "$json" | jq -r '.new_text // ""' 2>/dev/null)
		if [[ -z "$old" ]]; then agent_tool_result_err "$tool" "missing 'old_text'"; return 1; fi
		text=$(<"$path")
		if res=$(agent_first_replace "$text" "$old" "$new"); then
			printf '%s' "$res" >"$path"
			agent_tool_result_ok "$tool" "OK: replaced first occurrence in $path"
		else
			agent_tool_result_err "$tool" "old_text was NOT found in $path — read the file and retry with an exact match"
		fi
		;;
	delete_file)
		if [[ -z "$path" ]]; then agent_tool_result_err "$tool" "missing 'path'"; return 1; fi
		if rm -f "$path" 2>/dev/null; then
			agent_tool_result_ok "$tool" "OK: deleted $path"
		else
			agent_tool_result_err "$tool" "cannot delete $path"
		fi
		;;
rename_file)
		local new_path
		new_path=$(printf '%s' "$json" | jq -r '.new_path // empty' 2>/dev/null)
		if [[ -z "$new_path" ]]; then agent_tool_result_err "$tool" "missing 'new_path'"; return 1; fi
		mkdir -p "$(dirname "$new_path")" 2>/dev/null
		if mv "$path" "$new_path" 2>/dev/null; then
			agent_tool_result_ok "$tool" "OK: renamed $path -> $new_path"
		else
			agent_tool_result_err "$tool" "rename failed (check source exists and target dir writable)"
		fi
		;;
	copy_file)
		local dest
		dest=$(printf '%s' "$json" | jq -r '.dest // empty' 2>/dev/null)
		if [[ -z "$dest" ]]; then agent_tool_result_err "$tool" "missing 'dest'"; return 1; fi
		mkdir -p "$(dirname "$dest")" 2>/dev/null
		if cp "$path" "$dest" 2>/dev/null; then
			agent_tool_result_ok "$tool" "OK: copied $path -> $dest"
		else
			agent_tool_result_err "$tool" "copy failed (check source exists)"
		fi
		;;
	list_files)
		if [[ -z "$path" ]]; then path="$AGENT_TOOLS_WORKSPACE"; fi
		local recursive
		recursive=$(printf '%s' "$json" | jq -r '.recursive // false' 2>/dev/null)
		if [[ "$recursive" == "true" ]]; then
			out=$(find "$path" -maxdepth 4 2>/dev/null | sed -n '1,500p')
		else
			out=$(ls -la "$path" 2>/dev/null | sed -n '1,200p')
		fi
		agent_tool_result_ok "$tool" "$out"
		;;
	search_files)
		local pattern file_glob
		pattern=$(printf '%s' "$json" | jq -r '.pattern // empty' 2>/dev/null)
		file_glob=$(printf '%s' "$json" | jq -r '.file_glob // ""' 2>/dev/null)
		if [[ -z "$pattern" ]]; then agent_tool_result_err "$tool" "missing 'pattern'"; return 1; fi
		if [[ -z "$path" ]]; then path="$AGENT_TOOLS_WORKSPACE"; fi
		if [[ -n "$file_glob" ]]; then
			out=$(rg -n --glob "$file_glob" --no-heading "$pattern" "$path" 2>/dev/null | sed -n '1,300p')
		else
			out=$(rg -n --no-heading "$pattern" "$path" 2>/dev/null | sed -n '1,300p')
		fi
		agent_tool_result_ok "$tool" "$out"
		;;
	file_info)
		if [[ ! -e "$path" ]]; then agent_tool_result_err "$tool" "not found: $path"; return 1; fi
		out=$(stat -c '%A %s bytes  %y' "$path" 2>/dev/null || stat "$path" 2>/dev/null | head -3)
		if [[ -f "$path" ]]; then
			out+=$'\n'"lines: $(wc -l <"$path" 2>/dev/null)  words: $(wc -w <"$path" 2>/dev/null)"
		fi
		agent_tool_result_ok "$tool" "$out"
		;;
	run_command)
		local command
		command=$(printf '%s' "$json" | jq -r '.command // empty' 2>/dev/null)
		if [[ -z "$command" ]]; then agent_tool_result_err "$tool" "missing 'command'"; return 1; fi
		out=$(cd "$AGENT_TOOLS_WORKSPACE" 2>/dev/null; timeout 60 bash -c "$command" 2>&1 | sed -n '1,3000p')
		agent_tool_result_ok "$tool" "$out"
		;;
	*)
		agent_tool_result_err "$tool" "unknown tool. Available tools: write_file, read_file, append_file, edit_file, delete_file, rename_file, copy_file, list_files, search_files, file_info, run_command"
		;;
	esac
}
# ------------------------------------------------------------
# agent_extract_tool_calls <text> — find every ```tool_call
# fenced block, compact it to a single-line JSON (jq) and print
# each valid one on its own line. Malformed blocks are skipped.
# ------------------------------------------------------------
agent_extract_tool_calls() {
	local text="$1"
	local line in_block=0 buf=""

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line%$'\r'}"
		if (( in_block == 0 )) && [[ "$line" =~ ^[[:space:]]*\`\`\`tool_call[[:space:]]*$ ]]; then
			in_block=1
			buf=""
			continue
		fi
		if (( in_block == 1 )); then
			if [[ "$line" =~ ^[[:space:]]*\`\`\` ]]; then
				local json
				json=$(printf '%s' "$buf" | jq -c . 2>/dev/null)
				if [[ -n "$json" && "$json" != "null" ]]; then
					printf '%s\n' "$json"
				fi
				in_block=0
				continue
			fi
			buf+="$line"$'\n'
		fi
	done <<<"$text"
}