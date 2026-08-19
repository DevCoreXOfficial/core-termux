#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# agent_actions.sh — markdown-driven actions for `core agent run`.
#
# The model NEVER creates files or runs commands itself. It only
# answers in markdown. bash reads that markdown and finds:
#
#   • a heading `## File: <path>` (or `### <path>`) followed
#     by a fenced code block  →  a file to write
#   • a fenced ```bash/sh/shell block or a `$ cmd` line
#                              →  a command to run (with the
#                                 user's y/N confirmation)
#
# Everything else (titles, prose, plain code) is only rendered.
# No plugin, no function-calling: plain bash + sed/awk/grep.
# ============================================================

import "@/utils/log"
import "@/utils/colors"

AGENT_CONFIRM_COMMANDS="${AGENT_CONFIRM_COMMANDS:-1}"
AGENT_YES=0
# smart file attachment: files up to AGENT_ATTACH_SMALL lines are attached
# fully; larger files only their first AGENT_ATTACH_HEAD lines plus the total
# line count, so the model reads the rest in parts (sed/grep command blocks).
AGENT_ATTACH_SMALL="${AGENT_ATTACH_SMALL:-100}"
AGENT_ATTACH_HEAD="${AGENT_ATTACH_HEAD:-60}"

# ------------------------------------------------------------
# agent_tools_available — comma list of tools actually installed,
# so the system prompt only mentions what really exists.
# ------------------------------------------------------------
agent_tools_available() {
	local names=(curl wget jq rg git sed awk cat ls find stat wc head tail grep sort uniq cut tr xargs mkdir rm mv cp touch tar gzip python3 node npm bun cargo go ffmpeg sqlite3 psql redis-cli fzf)
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
# agent_system_prompt <workspace> — run-mode instructions.
# The model only writes markdown; bash executes. Uses a quoted
# heredoc so backticks are safe, then swaps {PLACEHOLDERS}.
# ------------------------------------------------------------
agent_system_prompt() {
	local workspace="$1"
	local tools
	tools=$(agent_tools_available)

	sed -e "s|{WORKSPACE}|$workspace|g" \
		-e "s|{HOME}|$HOME|g" \
		-e "s|{PWD}|$PWD|g" \
		-e "s|{ATTACH_SMALL}|$AGENT_ATTACH_SMALL|g" \
		-e "s|{ATTACH_HEAD}|$AGENT_ATTACH_HEAD|g" \
		-e "s|{TOOLS}|$tools|g" <<'AGENT_SYSTEM_PROMPT'
You are an autonomous CLI agent. Your job is to complete the user's task on this real machine. You NEVER execute anything yourself: you only write markdown, and the host (bash) parses that markdown and performs the file writes and shell commands you describe.

## LANGUAGE (important)
- Reply in the SAME LANGUAGE the user used in their latest message (Spanish in -> Spanish out, English in -> English out, etc.).
- Code, commands, file names, paths and technical identifiers always stay in English.

## ENVIRONMENT FACTS (trust these, never invent paths)
- OS: Termux (Android), Linux-like environment, bash shell.
- Real home directory: {HOME}
- Current working directory: {PWD}
- Your workspace (create everything here unless told otherwise): {WORKSPACE}
- Installed tools you can use: {TOOLS}
- Use ONLY real absolute paths, or paths RELATIVE to the workspace. Never guess a path exists; inspect first with a command block when unsure.

## HOW TO CREATE OR EDIT FILES (bash writes them for you)
For every file you want, write a heading `## File: <path>` (or `### <path>`) IMMEDIATELY followed by ONE fenced code block containing the ENTIRE final content. bash creates parent directories and writes the block verbatim. Rules:
- Put ALL the files you want in a single response, one heading+block pair per file. The host creates every one of them.
- Never use "..." or "// rest of the code" placeholders — the content must be complete and final.
- If a file already exists and you must change it, either include the full new content (overwrites) or read it first with a command block and describe exactly what changes.
- Never re-emit a file just to "show" it (e.g. a file the user attached with @ or one that already exists unchanged). `## File:` blocks are ONLY for files you are actually creating or modifying; a block that would write identical content over an existing file is skipped silently by the host.
- NEVER write a `## File:` block for a file the user attached with `action="no-read"` (or any file whose content you have not actually been shown). The host IGNORES such blocks — the file is never created or overwritten — and you waste an iteration.

Example:
## File: index.html
```html
<!doctype html>
<html lang="en">
...
```

## HOW TO RUN SHELL COMMANDS (bash asks the user first)
To run commands, put them in a fenced block tagged ```bash, ```sh or ```shell, or on a line starting with `$ `. The host shows the user the command and asks for permission (y/N) before running it — so explain what each command does and why it is needed. Rules:
- RUN COMMANDS DIRECTLY. For simple operations — deleting a file or directory, git status, listing files, reading a file, checking versions — just emit the command (e.g. `$ rm -rf isolated`, `$ git status`). Do NOT create a .sh script file for anything that fits in a single command.
- To delete, move, rename, copy or run a file, ALWAYS use a command block (```bash or `$ `). NEVER put the command inside a `## File:` block — a `## File:` block only creates/edits file content, it never runs anything.
- Only write a script file when the task genuinely needs one: a reusable script, loops/conditionals/variables, or several commands the user will want to re-run later. Then run it with a command block (e.g. `$ bash my_script.sh`).
- Batch related commands into a single block (one confirmation per block).
- Commands run with bash -c inside the workspace, 60s timeout. stdout/stderr are returned to you inside <command_result> blocks.
- Prefer installed tools (jq, rg, sed/awk, git...). Never invent flags; check with --help first if unsure.
- Do NOT use sudo (Termux has no sudo). Do not install packages unless the user explicitly asked.
- Keep commands deterministic and idempotent where possible. Each <command_result> comes back as a fresh message; state does not persist between blocks — persist data in files.

## WORKFLOW
1. Plan briefly in prose (headings/lists are fine).
2. Emit the file blocks and command blocks the task needs — prefer DIRECT command blocks over script files unless the task really needs a reusable script.
3. After your commands run, the host sends you their <command_result> output. Verify, fix mistakes, then continue or finish.
4. When the task is complete, write a final summary WITHOUT any file or command blocks: what you created/changed, which commands should run next, and how to use the result.

## ATTACHED FILES
If the user's message contains <attached_file path="...">...</attached_file> blocks, those hold the real contents of files the user wants you to work with. Read them carefully before acting.
- The `lines` attribute is the file's total line count. Files up to {ATTACH_SMALL} lines are attached fully; larger files only their first {ATTACH_HEAD} lines (see `partial="first-..."`). If you need the rest, read it in parts with command blocks, e.g. `$ sed -n '120,240p' <path>` or `$ grep -n 'pattern' <path>`. Never assume you have seen a file you only read partially.
- A block with `action="no-read"` carries no content — the task did not require reading the file. Only read it (via a command block) if you actually need it. Such files are WRITE-PROTECTED: a `## File:` block you emit for one of them is ignored by the host.

## SHELL COMMAND CONTEXT
The conversation may contain <shell_command> blocks: shell commands the user ran directly from the REPL (e.g. `!git status`) together with their real output. Treat them as current, accurate context about the state of the machine.

## COMPACTED SUMMARY
If the conversation contains <compacted_summary>...</compacted_summary> blocks, they are condensed summaries of earlier turns (the host compacts when the context is near full). Treat them as ground truth for everything that happened before them — follow the thread they preserve: the original goal, files created/edited, commands run and the current state. Do not ask the user to repeat information that is in the summary.
AGENT_SYSTEM_PROMPT
}

# ------------------------------------------------------------
# agent_heading_path <heading> — decide whether a markdown heading
# names a file to write; echoes the path ("" if it is not one).
# Accepts `## File: path`, `### path`, quoted paths, strips
# markdown emphasis/backticks and a leading ./.
# ------------------------------------------------------------
agent_heading_path() {
	local h="$1"
	h="${h//\*\*/}"
	h="${h//\`/}"
	h=$(printf '%s\n' "$h" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
	[[ -z "$h" ]] && return 1
	# defensive: strip leading markdown hashes if given a full heading
	h=$(printf '%s\n' "$h" | sed -E 's/^#{1,6}[[:space:]]+//')
	# optional "File:" / "file:" prefix
	if [[ "$h" =~ ^[Ff]ile[[:space:]]*[:：][[:space:]]*(.*)$ ]]; then
		h="${BASH_REMATCH[1]}"
		h=$(printf '%s\n' "$h" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
	fi
	# quoted path ("my file.html") — quotes mark an explicit path
	local quoted=0
	if [[ "$h" =~ ^\"(.*)\"$ ]]; then
		h="${BASH_REMATCH[1]}"
		quoted=1
	fi
	[[ -z "$h" ]] && return 1
	h="${h#./}"
	if [[ "$quoted" == "1" ]]; then
		echo "$h"
		return 0
	fi
	# must look like a path: no whitespace, and it contains a slash
	# or ends in a dotted extension
	if [[ "$h" != *[[:space:]]* && ( "$h" == */* || "$h" =~ \.[A-Za-z0-9]{1,10}$ ) ]]; then
		echo "$h"
		return 0
	fi
	return 1
}

# ------------------------------------------------------------
# _agent_strip_shell_prompt <text> — remove a leading `$ ` shell
# prompt marker from each line. Models often write commands as
# ```bash\n$ git status\n``` (with the prompt); running that
# verbatim would try to execute `$`. Only the `$ <space>` form is
# stripped (real bash code like `$((...))` / `$var` is untouched).
# ------------------------------------------------------------
_agent_strip_shell_prompt() {
	local text="$1" out="" l
	while IFS= read -r l || [[ -n "$l" ]]; do
		if [[ "$l" =~ ^[[:space:]]*\$[[:space:]]+(.*)$ ]]; then
			out+="${BASH_REMATCH[1]}"$'\n'
		else
			out+="$l"$'\n'
		fi
	done <<<"$text"
	printf '%s' "$out"
}

# ------------------------------------------------------------
# _agent_is_no_read <path> — return 0 when <path> (resolved against
# the workspace) is in the task's write-protected no-read set, i.e.
# the user attached it with @ but the task only needs the path
# (delete / move / run...). Used to stop the model's File: blocks
# from touching those files and to reinterpret command-in-File slips.
# ------------------------------------------------------------
_agent_is_no_read() {
	local tgt="$1" d tgtabs _nr
	d=$(agent_md_dir)
	[[ ! -f "$d/no_read_paths.txt" ]] && return 1
	if [[ "$tgt" != /* ]]; then
		tgt="${AGENT_ACTIONS_WORKSPACE:-$PWD}/$tgt"
	fi
	tgtabs=$(realpath -m "$tgt" 2>/dev/null)
	[[ -z "$tgtabs" ]] && return 1
	while IFS= read -r _nr; do
		[[ "$tgtabs" == "$_nr" ]] && return 0
	done <"$d/no_read_paths.txt"
	return 1
}

# ------------------------------------------------------------
# agent_parse_response <text> — walk the model's markdown and
# split it into files and commands. Writes:
#   files_manifest.txt : n<TAB>path<TAB>lang      (+ action_file_n)
#   cmds_manifest.txt  : n<TAB>lang               (+ action_cmd_n)
# Echoes "<nfiles> <ncmds>". tool_call blocks are skipped.
# ------------------------------------------------------------
agent_parse_response() {
	local text="$1"
	local d fm cm
	d=$(agent_md_dir)
	fm="$d/actions_files_manifest.txt"
	cm="$d/actions_cmds_manifest.txt"
	rm -f "$fm" "$cm" "$d"/action_file_* "$d"/action_cmd_*
	: >"$fm"
	: >"$cm"

	local -a lines=()
	while IFS= read -r l || [[ -n "$l" ]]; do
		lines+=("$l")
	done <<<"$text"
	[[ ${#lines[@]} -eq 0 ]] && { echo "0 0"; return 0; }

	local nf=0 nc=0 i pending=""
	for ((i = 0; i < ${#lines[@]}; i++)); do
		local line="${lines[$i]}"
		line="${line%$'\r'}"

		# --- fenced code block ---
		if [[ "$line" =~ ^[[:space:]]*\`\`\` ]]; then
			local lang="${line#\`\`\`}"
			lang="${lang%% *}"
			if [[ "$lang" == "tool_call" ]]; then
				# legacy: skip the whole hidden block
				while ((i + 1 < ${#lines[@]})) && [[ "${lines[$((i + 1))]}" != *'```'* ]]; do
					((i++))
				done
				pending=""
				continue
			fi
			local buf="" cl
			while ((i + 1 < ${#lines[@]})); do
				((i++))
				cl="${lines[$i]}"
				[[ "$cl" =~ ^[[:space:]]*\`\`\` ]] && break
				buf+="$cl"$'\n'
			done
			if [[ -n "$pending" ]]; then
				# The model sometimes (wrongly) puts a shell COMMAND in a
				# `## File:` block for a write-protected no-read file
				# (e.g. `File: index.js` + bash block with `rm index.js`).
				# Writing it is forbidden anyway, so reinterpret it as a
				# command block instead of silently dropping the action.
				if [[ "$lang" =~ ^(bash|sh|shell|zsh|console)$ ]] && _agent_is_no_read "$pending"; then
					local stripped
					stripped=$(_agent_strip_shell_prompt "$buf")
					if [[ "$stripped" != \#!* ]]; then
						nc=$((nc + 1))
						printf '%s\t%s\n' "$nc" "$lang" >>"$cm"
						printf '%s' "$stripped" >"$d/action_cmd_$nc"
						pending=""
						continue
					fi
				fi
				nf=$((nf + 1))
				printf '%s\t%s\t%s\n' "$nf" "$pending" "$lang" >>"$fm"
				printf '%s' "$buf" >"$d/action_file_$nf"
				pending=""
			elif [[ "$lang" =~ ^(bash|sh|shell|zsh|console)$ ]]; then
				nc=$((nc + 1))
				printf '%s\t%s\n' "$nc" "$lang" >>"$cm"
				_agent_strip_shell_prompt "$buf" >"$d/action_cmd_$nc"
			fi
			continue
		fi

		# --- heading -> pending file path ---
		if [[ "$line" =~ ^#{1,6}[[:space:]](.*)$ ]]; then
			pending=$(agent_heading_path "${BASH_REMATCH[1]}")
			continue
		fi

		# --- "$ command" line in prose (optional indentation) ---
		if [[ "$line" =~ ^[[:space:]]*\$[[:space:]](.+)$ ]]; then
			nc=$((nc + 1))
			printf '%s\t%s\n' "$nc" "inline" >>"$cm"
			printf '%s\n' "${BASH_REMATCH[1]}" >"$d/action_cmd_$nc"
			continue
		fi
	done

	echo "$nf $nc"
}

# ------------------------------------------------------------
# agent_apply_files — create every file from the last parse.
# Pure bash: mkdir -p + cat, with one success line per file.
# ------------------------------------------------------------
agent_apply_files() {
	local d fm n path lang nlines ws target shown
	d=$(agent_md_dir)
	fm="$d/actions_files_manifest.txt"
	ws="${AGENT_ACTIONS_WORKSPACE:-$PWD}"
	AGENT_FILES_WRITTEN=0
	shown=0
	# paths attached as action="no-read" are write-protected for this task
	local noread_file="$d/no_read_paths.txt"
	local -a noread=()
	if [[ -f "$noread_file" ]]; then
		while IFS= read -r _nr; do
			[[ -n "$_nr" ]] && noread+=("$_nr")
		done <"$noread_file"
	fi
	while IFS=$'\t' read -r n path lang; do
		[[ -z "$n" ]] && continue
		# resolve relative paths against the workspace (absolute paths are used as-is)
		if [[ "$path" != /* ]]; then
			target="$ws/$path"
		else
			target="$path"
		fi
		# write-protected: the model must not create/edit a file the task
		# only references (delete/move/run...). Skip it silently.
		if (( ${#noread[@]} > 0 )); then
			local tgtabs _nr skip=0
			tgtabs=$(realpath -m "$target" 2>/dev/null)
			for _nr in "${noread[@]}"; do
				if [[ "$tgtabs" == "$_nr" ]]; then
					skip=1
					break
				fi
			done
			if (( skip )); then
				continue
			fi
		fi
		if ! mkdir -p "$(dirname "$target")" 2>/dev/null; then
			log_error "Cannot write $target"
			continue
		fi
		local existed=0
		[[ -f "$target" ]] && existed=1
		if (( existed )) && cmp -s "$d/action_file_$n" "$target"; then
			# the model merely reflected a file that is already on disk
			# with identical content (e.g. re-emitting an attached file
			# during a read/explain task) — nothing to create or edit
			continue
		fi
		if cat "$d/action_file_$n" >"$target" 2>/dev/null; then
			if (( shown == 0 )); then
				shown=1
				echo
				separator_section "Creating files"
			fi
			nlines=$(wc -l <"$target" 2>/dev/null | tr -d ' ')
			AGENT_FILES_WRITTEN=$((AGENT_FILES_WRITTEN + 1))
			if (( existed )); then
				log_success "Updated ${D_CYAN}$target${D_NC} ${D_DIM}($nlines lines)${D_NC}"
			else
				log_success "Created ${D_CYAN}$target${D_NC} ${D_DIM}($nlines lines)${D_NC}"
			fi
		else
			log_error "Cannot write $target"
		fi
	done <"$fm"
}

# ------------------------------------------------------------
# _agent_exec_to_file <cmd> <outfile> — run one agent command in
# the workspace (60s timeout) writing combined output to <outfile>
# so agent_exec_loading can spin while it runs. Echoes nothing.
# ------------------------------------------------------------
_agent_exec_to_file() {
	local cmd="$1" ofile="$2"
	( cd "${AGENT_ACTIONS_WORKSPACE:-$PWD}" 2>/dev/null && timeout 60 bash -c "$cmd" 2>&1 ) >"$ofile"
}

# ------------------------------------------------------------
# agent_execute_commands — run every command block from the last
# parse, asking for y/N confirmation first (unless -y or
# confirm_commands off). Writes <command_result> blocks into
# command_results.txt for the follow-up LLM round.
# Answering 'n' (or pressing ESC ESC) sets AGENT_ABORT=1 and stops
# the agent, so control returns to the `you ▸` prompt.
# ------------------------------------------------------------
agent_execute_commands() {
	local d cm n lang cmd out code
	d=$(agent_md_dir)
	cm="$d/actions_cmds_manifest.txt"
	local results_file="$d/command_results.txt"
	: >"$results_file"

	while IFS=$'\t' read -r n lang <&3; do
		[[ -z "$n" ]] && continue
		cmd=$(cat "$d/action_cmd_$n")
		echo
		printf '    %s$%s %s\n' "$D_GREEN" "$NC" "$cmd"

		local run=0
		if [[ "$AGENT_CONFIRM_COMMANDS" == "1" && "$AGENT_YES" != "1" ]]; then
			if [[ -t 0 ]]; then
				local _ans
				if agent_confirm "Run this command?" _ans; then
					run=1
				else
					# 'n' cancels the whole agent task
					AGENT_ABORT=1
					printf '    %s↳ canceled — back to the prompt%s\n' "$D_GRAY" "$NC"
					return 1
				fi
			else
				log_warn "No terminal — skipping command (use -y to auto-approve)"
			fi
		else
			run=1
		fi

		if (( run == 0 )); then
			printf '    %s↳ skipped by user%s\n' "$D_GRAY" "$NC"
			{
				printf '<command_result tool="run_command" ok="false">\n'
				printf '<command>%s</command>\n' "$cmd"
				printf '<status>skipped by user</status>\n'
				printf '</command_result>\n'
			} >>"$results_file"
			continue
		fi

		local ofile
		ofile="$(agent_md_dir)/cmd_out_$n.txt"
		agent_exec_loading "  executing command…" _agent_exec_to_file "$cmd" "$ofile"
		code=$?
		if (( AGENT_ABORT )); then
			printf '    %s↳ canceled — back to the prompt%s\n' "$D_GRAY" "$NC"
			rm -f "$ofile"
			return 1
		fi
		out=$(cat "$ofile" 2>/dev/null)
		rm -f "$ofile"
		if [[ -n "$out" ]]; then
			printf '%s\n' "$out" | sed 's/^/    /'
		fi
		if (( code == 0 )); then
			printf '    %s↳ exit %s%s\n' "$D_GREEN" "0" "$NC"
		else
			printf '    %s↳ exit %s%s\n' "$D_RED" "$code" "$NC"
		fi
		{
			printf '<command_result tool="run_command" ok="%s">\n' "$([[ $code == 0 ]] && echo true || echo false)"
			printf '<command>%s</command>\n' "$cmd"
			printf '<exit_code>%s</exit_code>\n' "$code"
			printf '<output>\n%s\n</output>\n' "$out"
			printf '</command_result>\n'
		} >>"$results_file"
	done 3<"$cm"
}

# ------------------------------------------------------------
# agent_at_pick <query> — pick a file from the current directory
# with fzf (or a numbered fallback). Echoes the chosen relative
# path, or nothing if cancelled.
# ------------------------------------------------------------
agent_at_pick() {
	local query="$1"
	local files pick sel m i
	[[ -n "$query" && -f "$query" ]] && { echo "$query"; return 0; }

	files=$(find . -type f \
		-not -path './.git/*' -not -path '*/node_modules/*' \
		-not -path './.cache/*' -not -path '*/target/*' \
		2>/dev/null | sed 's|^\./||' | sort)
	[[ -z "$files" ]] && return 1

	if command -v fzf &>/dev/null && [[ -t 0 ]]; then
		pick=$(printf '%s\n' "$files" | fzf --query "$query" --height 40% --layout=reverse \
			--border --prompt='@file > ' --preview "$(agent_at_preview_cmd)" 2>/dev/null)
		[[ -n "$pick" ]] && { echo "$pick"; return 0; }
		return 1
	fi

	# numbered fallback
	local matches
	matches=$(printf '%s\n' "$files" | grep -Fi -- "${query:-}" | sed -n '1,30p')
	[[ -z "$matches" ]] && matches=$(printf '%s\n' "$files" | sed -n '1,30p')
	i=0
	while IFS= read -r m; do
		i=$((i + 1))
		printf '    %2d) %s\n' "$i" "$m" >&2
	done <<<"$matches"
	read -r -p "    Pick file number (0 = cancel): " sel </dev/tty
	[[ "$sel" =~ ^[0-9]+$ ]] || return 1
	(( sel > 0 )) || return 1
	echo "$matches" | sed -n "${sel}p"
}

# ------------------------------------------------------------
# agent_banner — your personal banner, printed at the top of the
# interactive REPLs (ask & run).
#
# ═══════════════════════════════════════════════════════════
#   EDIT ME — replace the printf lines below with your banner.
#   Tips:
#   • Color variables available (see core/utils/colors.sh):
#     D_CYAN, D_GREEN, D_YELLOW, D_PURPLE, D_RED, D_BLUE,
#     GRAY, NC.
#   • If figlet/toilet is installed you can generate one, e.g.:
#       figlet -w 60 "MY NAME" | sed 's/^/    /'
#   • Keep the leading 4 spaces so it lines up with the REPL.
# ═══════════════════════════════════════════════════════════
agent_banner() {
	# ── EDIT ME: your banner goes here ──────────────────────────
	echo -e "${D_CYAN}
     ███   ███  ████  █████   
    █ ░░░ █ ░░█ █░░░█ █░░░░░  
    █░ ░░░█░ ░█░████░░████░░░ 
    █░░   █░░ █░█░░█░ █░░░░   
     ███   ███ ░█░░░█░█████░  
      ░░░   ░░░ ░░░  ░ ░░░░░  
       ░░░   ░░░  ░   ░ ░░░░░

     ███   ███  █████ █   █ █████   
    █ ░░█ █ ░░░ █░░░░░██  █░ ░█░░░  
    █████░█░ ██░████░░█░█ █░░ █░░░░ 
    █░░░█░█░░ █░█░░░░ █░░██░░ █░░   
    █░░░█░░███ ░█████░█░░ █░░ █░░   
     ░░  ░░ ░░░ ░░░░░░ ░░  ░░  ░░   
      ░   ░  ░░░  ░░░░░ ░   ░   ░"
	echo
}

# ------------------------------------------------------------
# REPL line editing. ESC ESC aborts the whole agent session: a
# readline macro inserts an invisible marker (0x01 0x02) and
# accepts the line, so the read returns right away and the REPL
# detects the marker -> AGENT_CANCEL=1. Pure readline, no
# signals — reliable on every terminal.
#
# readline bindings are inert in non-interactive shells, so
# agent_repl_bind runs `set -o emacs` first.
# ------------------------------------------------------------
AGENT_CANCEL=0
AGENT_ABORT=0
AGENT_ESC_MARKER=$'\x01\x02'

# ------------------------------------------------------------
# agent_at_preview_cmd — fzf --preview command that renders a file
# (or directory) inside a box: a ┌─ header with the path, the
# contents indented with a │ border, and a └─ footer with the line
# count. Self-contained (runs under sh inside fzf), no core fns.
# ------------------------------------------------------------
agent_at_preview_cmd() {
	cat <<'FZF_PREVIEW'
ESC="$(printf '\033')"
C="${ESC}[36m"
O="${ESC}[0m"
f={}
if [ -d "$f" ]; then
  printf "  %s┌─ %s/%s\n" "$C" "$f" "$O"
  ls -1 "$f" | sed "s/^/  ${C}│${O} /" | head -n 40
  printf "  %s└─ %s entries%s\n" "$C" "$(ls -1 "$f" 2>/dev/null | wc -l | tr -d ' ')" "$O"
else
  printf "  %s┌─ %s%s\n" "$C" "$f" "$O"
  printf "  %s│%s\n" "$C" "$O"
  head -n 60 "$f" 2>/dev/null | sed "s/^/  ${C}│${O} /"
  printf "  %s└─ %s line(s)%s\n" "$C" "$(wc -l < "$f" 2>/dev/null | tr -d ' ')" "$O"
fi
FZF_PREVIEW
}

# ------------------------------------------------------------
# _agent_at_key — live `@` suggestion: bound to the `@` key in the
# REPL, it opens fzf right at the cursor with the files of the
# current directory. Picking one inserts `@<path>` (the Enter-time
# expansion then attaches its contents). Mid-word `@` (emails,
# etc.) is inserted literally. Falls back to inserting a bare `@`
# when fzf is missing. No `--select-1`: the picker ALWAYS stays
# open so you can arrow through files — it never auto-completes.
# ------------------------------------------------------------
_agent_at_key() {
	local before="${READLINE_LINE:0:READLINE_POINT}"
	if [[ -n "$before" && "$before" != *' ' ]]; then
		# mid-word @ (e.g. an email) — insert it literally
		READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}@${READLINE_LINE:READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + 1))
		return 0
	fi
	local path=""
	if command -v fzf &>/dev/null; then
		local files
		files=$(find . -type f \
			-not -path './.git/*' -not -path '*/node_modules/*' \
			-not -path './.cache/*' -not -path '*/target/*' \
			2>/dev/null | sed 's|^\./||' | sort)
		if [[ -n "$files" ]]; then
			path=$(printf '%s\n' "$files" | fzf --query '' --height 40% --layout=reverse \
				--border --prompt='@file > ' --preview "$(agent_at_preview_cmd)" 2>/dev/null)
		fi
	fi
	if [[ -n "$path" ]]; then
		READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}@${path}${READLINE_LINE:READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + 1 + ${#path}))
	else
		READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}@${READLINE_LINE:READLINE_POINT}"
		READLINE_POINT=$((READLINE_POINT + 1))
	fi
	return 0
}

# ------------------------------------------------------------
# agent_repl_prompt — "you ▸" prompt. Vivid hot-pink label with a
# lighter pink for the text you type, so the last prompt is easy to
# spot on a black terminal and clearly different from the colors the
# markdown renderer uses for responses (cyan/green/yellow/magenta).
# The color code is left open (no reset) so the typed text stays
# pink; the reset happens in agent_repl_read once the line is done.
# ------------------------------------------------------------
agent_repl_prompt() {
	printf '    \001\e[1;38;5;207m\002you\001\e[38;5;213m\002 ▸ '
}

# ------------------------------------------------------------
# agent_repl_read — one input line. Returns 0 with the line in
# AGENT_REPL_LINE, or 1 on EOF / ESC ESC (AGENT_CANCEL=1).
# If AGENT_REPL_PREFILL is set (e.g. by /voice), it is offered
# as the initial text so the user can edit it before sending.
# ------------------------------------------------------------
agent_repl_read() {
	local line prefill=""
	[[ -n "${AGENT_REPL_PREFILL:-}" ]] && prefill="$AGENT_REPL_PREFILL"
	if IFS= read -e -r -p "$(agent_repl_prompt)" -i "$prefill" line; then
		printf '\e[0m' >&2
		AGENT_REPL_PREFILL=""
		if [[ "$line" == *"$AGENT_ESC_MARKER"* ]]; then
			AGENT_CANCEL=1
			return 1
		fi
		AGENT_REPL_LINE="$line"
		# push the prompt into the session history so ↑/↓ can
		# navigate the prompts typed during this session
		[[ -n "$line" ]] && history -s "$line" 2>/dev/null
		return 0
	fi
	printf '\e[0m' >&2
	AGENT_REPL_PREFILL=""
	return 1
}

# ------------------------------------------------------------
# agent_repl_bind / agent_repl_unbind — activate the readline
# keybindings around the REPL read loop (only on a TTY).
# ------------------------------------------------------------
agent_repl_bind() {
	[[ -t 0 ]] || return 0
	set -o emacs 2>/dev/null
	AGENT_CANCEL=0
	# ESC ESC -> insert the invisible marker bytes literally
	# (quoted-insert \C-v) and accept the line
	bind '"\e\e": "\C-v\C-a\C-v\C-b\C-m"' 2>/dev/null
	# @ -> live fzf file picker at the cursor
	bind -x '"@": _agent_at_key' 2>/dev/null
}

agent_repl_unbind() {
	bind -r '"\e\e"' 2>/dev/null
	bind -r '"@"' 2>/dev/null
}

# ------------------------------------------------------------
# _agent_esc_esc — non-blocking check for ESC ESC on stdin (only
# meaningful on a TTY). Returns 0 when both bytes were read. The
# spinner loop of agent_exec_loading calls this every frame so the
# user can cancel a running agent even while it is working.
# ------------------------------------------------------------
_agent_esc_esc() {
	local k1 k2
	IFS= read -r -t 0.02 -s -n1 k1 2>/dev/null || return 1
	[[ "$k1" == $'\x1b' ]] || return 1
	IFS= read -r -t 0.02 -s -n1 k2 2>/dev/null || return 1
	[[ "$k2" == $'\x1b' ]]
}

# ------------------------------------------------------------
# _agent_kill_tree <pid> — kill a process and all its descendants
# (the spinner child is a bash subshell that may have spawned
# curl / timeout / bash -c underneath).
# ------------------------------------------------------------
_agent_kill_tree() {
	local p="$1" c
	for c in $(pgrep -P "$p" 2>/dev/null); do
		_agent_kill_tree "$c"
	done
	kill "$p" 2>/dev/null
}

# ------------------------------------------------------------
# agent_exec_loading <message> <cmd> [args...] — like loading()
# but polls stdin for ESC ESC while the command runs; when pressed
# it kills the command, sets AGENT_ABORT=1 and returns 130. Used
# around model calls and command execution so ESC ESC cancels a
# busy agent.
# ------------------------------------------------------------
agent_exec_loading() {
	local message="$1"
	shift
	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local delay=0.08
	local tmpfile
	tmpfile="$(mktemp)"

	local stty_saved=""
	if [[ -t 0 ]]; then
		stty_saved=$(stty -g 2>/dev/null)
		stty -echo 2>/dev/null
	fi

	printf "    ${CYAN}%s${D_CYAN} %s${NC}" "${frames[0]}" "$message"

	"$@" >"$tmpfile" 2>&1 &
	local pid=$!

	local i=0
	while kill -0 "$pid" 2>/dev/null; do
		if [[ -t 0 ]] && _agent_esc_esc; then
			_agent_kill_tree "$pid"
			wait "$pid" 2>/dev/null
			printf "\r    ${RED}✖${D_RED} %s${NC} ${D_GRAY}(canceled)${NC}\n" "$message"
			[[ -n "$stty_saved" ]] && stty "$stty_saved" 2>/dev/null
			rm -f "$tmpfile"
			AGENT_ABORT=1
			return 130
		fi
		printf "\r    ${CYAN}%s${D_CYAN} %s${NC}" "${frames[i]}" "$message"
		((i = (i + 1) % ${#frames[@]}))
		sleep "$delay"
	done

	wait "$pid"
	local exit_code=$?
	[[ -n "$stty_saved" ]] && stty "$stty_saved" 2>/dev/null
	if [[ $exit_code -eq 0 ]]; then
		printf "\r    ${GREEN}✔${D_GREEN} %s${NC}\n" "$message"
		[[ -s "$tmpfile" ]] && cat "$tmpfile"
	elif [[ $exit_code -eq 2 ]]; then
		printf "\r    ${CYAN}➜${D_CYAN} %s${NC}\n" "$message"
		[[ -s "$tmpfile" ]] && cat "$tmpfile"
	else
		printf "\r    ${RED}✖${D_RED} %s${NC}\n" "$message"
		cat "$tmpfile"
	fi
	rm -f "$tmpfile"
	return $exit_code
}

# ------------------------------------------------------------
# agent_shell_context <cmd> <code> <output> — wrap a shell command
# the USER ran from the REPL (!cmd) so the model can use it.
# ------------------------------------------------------------
agent_shell_context() {
	local cmd="$1" code="$2" out="$3"
	printf '<shell_command>\n<command>%s</command>\n<exit_code>%s</exit_code>\n<output>\n%s\n</output>\n</shell_command>\n' "$cmd" "$code" "$out"
}

# ------------------------------------------------------------
# agent_shell_cmd <line> — REPL shell mode: a message starting
# with `!` runs the rest as a shell command in the workspace,
# prints its output, and feeds the command+output to the agent
# as conversation context (a <shell_command> block).
# ------------------------------------------------------------
agent_shell_cmd() {
	local line="$1" cmd
	cmd="${line#!}"
	cmd=$(printf '%s\n' "$cmd" | sed 's/^[[:space:]]*//')
	if [[ -z "$cmd" ]]; then
		log_warn "Empty command — usage: ${D_CYAN}!<shell command>${D_NC}"
		echo
		return 0
	fi

	local out code ws
	ws="${AGENT_ACTIONS_WORKSPACE:-$PWD}"
	echo
	printf '    %sShell%s %s▸%s %s\n' "$D_GREEN" "$NC" "$D_GREEN" "$NC" "$cmd"
	out=$(cd "$ws" 2>/dev/null && timeout 60 bash -c "$cmd" 2>&1)
	code=$?
	if [[ -n "$out" ]]; then
		printf '%s\n' "$out" | sed 's/^/    /'
	fi
	if (( code == 0 )); then
		printf '    %s↳ exit %s%s\n' "$D_GREEN" "0" "$NC"
	else
		printf '    %s↳ exit %s%s\n' "$D_RED" "$code" "$NC"
	fi

	# add to the agent's context
	AGENT_REPL_HISTORY=$(agent_history_add "$AGENT_REPL_HISTORY" user "$(agent_shell_context "$cmd" "$code" "$out")")
	AGENT_REPL_HISTORY=$(agent_history_manage "$AGENT_REPL_HISTORY" "$AGENT_CONTEXT_WINDOW")
	echo
}

# ------------------------------------------------------------
# agent_line_no_read <line> — return 0 when the prompt points at
# file(s) but clearly does not need their content (delete / move /
# rename / copy / execute / list / chmod / chown...). Used so the
# model does not get a file's whole content when it only needs the
# path (e.g. `elimina el archivo @x.py`).
# ------------------------------------------------------------
agent_line_no_read() {
	local line="$1"
	grep -qiE '\b(eliminar|elimina|borrar|borra|delete|deleting|remove|removing|rm|mover|mueve|move|moving|renombrar|renombra|rename|renaming|copiar|copia|copy|copying|cp|ejecutar|ejecuta|execute|executing|correr|corre|run|running|listar|lista|list|listing|chmod|chown|compilar|compile)\b' <<<"$line"
}

# ------------------------------------------------------------
# agent_attach_file <path> <attf> <want_read> — decide how much of
# a file to attach to the agent's context:
#   want_read=0 → reference only (action="no-read", no content)
#   small file  → full content
#   large file  → first AGENT_ATTACH_HEAD lines + total line count;
#                 the model reads the rest in parts with sed/grep
# ------------------------------------------------------------
agent_attach_file() {
	local path="$1" attf="$2" want_read="$3" lines
	lines=$(wc -l <"$path" | tr -d '[:space:]')
	if (( ! want_read )); then
		printf '<attached_file path="%s" lines="%s" action="no-read">\n</attached_file>\n' "$path" "$lines" >>"$attf"
		# remember the absolute path so agent_apply_files can protect it
		realpath -m "$path" >>"$(agent_md_dir)/no_read_paths.txt" 2>/dev/null
		return 0
	fi
	if (( lines <= AGENT_ATTACH_SMALL )); then
		{
			printf '<attached_file path="%s" lines="%s">\n' "$path" "$lines"
			cat "$path"
			printf '\n</attached_file>\n'
		} >>"$attf"
	else
		local from to
		from=$((AGENT_ATTACH_HEAD + 1))
		to=$((AGENT_ATTACH_HEAD * 2))
		{
			printf '<attached_file path="%s" lines="%s" partial="first-%s">\n' "$path" "$lines" "$AGENT_ATTACH_HEAD"
			head -n "$AGENT_ATTACH_HEAD" "$path"
			printf '\n</attached_file>\n'
			printf '<attach_note path="%s">Only the first %s of %s lines are attached. Read the rest in parts with command blocks, e.g. `$ sed -n "%s,%sp" %s` or `$ grep -n "pattern" %s`.\n</attach_note>\n' "$path" "$AGENT_ATTACH_HEAD" "$lines" "$from" "$to" "$path" "$path"
		} >>"$attf"
	fi
}

# ------------------------------------------------------------
# agent_expand_at <line> — replace every `@query` in the line with
# a file picked from the current directory (exact paths are used
# without asking). The picked file contents are appended to
# attachments.txt as <attached_file> blocks. Echoes the new line.
# Only active on a TTY (interactive); otherwise the line is
# returned unchanged.
# ------------------------------------------------------------
agent_expand_at() {
	local line="$1"
	local attf
	attf="$(agent_md_dir)/attachments.txt"
	: >"$attf"
	: >"$(agent_md_dir)/no_read_paths.txt"
	if [[ ! -t 0 || "$line" != *@* ]]; then
		echo "$line"
		return 0
	fi
	# only word-starting @ tokens (a@b / emails are left alone)
	if [[ ! "$line" =~ (^|[[:space:]])@ ]]; then
		echo "$line"
		return 0
	fi

	local rest="$line" out="" token path=""
	# decide once whether the prompt actually needs file contents
	# (edit/read tasks) or just the path (delete/move/run tasks)
	local want_read=1
	agent_line_no_read "$line" && want_read=0
	while [[ "$rest" == *@* ]]; do
		out+="${rest%%@*}"
		rest="${rest#*@}"
		token=""
		# quoted token: @"my file.txt"
		if [[ "$rest" == '"'* ]]; then
			local tmp="${rest#\"}"
			token="${tmp%%\"*}"
			rest="${tmp#*\"}"
		else
			# scan the token until whitespace/punctuation
			local ch
			while [[ -n "$rest" ]]; do
				ch="${rest:0:1}"
				case "$ch" in
				" " | $'\t' | "," | ";" | ":" | "!" | "?" | "(" | ")" | "'" | '"') break ;;
				*) token+="$ch"; rest="${rest:1}" ;;
				esac
			done
		fi

		if [[ -n "$token" && -f "$token" ]]; then
			out+="$token"
			path="$token"
		else
			path=$(agent_at_pick "$token")
			if [[ -n "$path" ]]; then
				out+="$path"
			else
				out+="@${token}"
				path=""
			fi
		fi

		if [[ -n "$path" && -f "$path" ]]; then
			agent_attach_file "$path" "$attf" "$want_read"
			path=""
		fi
	done
	out+="$rest"
	echo "$out"
}

# ------------------------------------------------------------
# agent_prepare_prompt <line> — expand @file references and append
# the attached file contents to the message. Echoes the final
# prompt (feedback goes to stderr so stdout stays clean).
# ------------------------------------------------------------
agent_prepare_prompt() {
	local line="$1" attf att
	line=$(agent_expand_at "$line")
	attf="$(agent_md_dir)/attachments.txt"
	if [[ -s "$attf" ]]; then
		att=$(cat "$attf")
		rm -f "$attf"
		local n
		n=$(grep -c '<attached_file ' <<<"$att")
		printf '    %s•%s attached %s file(s) to the message\n' "$GRAY" "$NC" "$n" >&2
		line+=$'\n\n'"$att"
	fi
	printf '%s' "$line"
}

# ------------------------------------------------------------
# agent_voice_capture — record the microphone via the Termux:API
# app (termux-api-start ensures the main activity is running,
# then termux-dialog speech records until the user stops). The
# transcript is stored in AGENT_VOICE_TEXT. Returns 0 on success.
# ------------------------------------------------------------
agent_voice_capture() {
	AGENT_VOICE_TEXT=""
	if ! command -v termux-dialog &>/dev/null; then
		log_warn "Termux:API is not installed"
		list_item "Install the package: ${D_CYAN}pkg install termux-api${NC}"
		list_item "Install the app from: https://devcorex-web.vercel.app/termux/api"
		return 1
	fi
	# bring the Termux:API main activity to the front
	command -v termux-api-start &>/dev/null && termux-api-start &>/dev/null
	sleep 1
	local raw
	raw=$(termux-dialog speech 2>/dev/null | grep -i "text" | cut -d '"' -f 4)
	if [[ -z "$raw" ]]; then
		log_warn "No speech detected or dialog cancelled"
		return 1
	fi
	AGENT_VOICE_TEXT="$raw"
	return 0
}

# ------------------------------------------------------------
# Model server lifecycle — when the REPL starts and the endpoint
# is unreachable, start `cactus serve` in the background with its
# logs redirected to ~/.cache/core-termux/core-agent.log, and stop
# it automatically when the REPL ends (/exit, ESC ESC, Ctrl+C).
# Only a server WE started is stopped — a manually-started one is
# left alone.
# ------------------------------------------------------------
AGENT_SERVER_LOG="$CORE_CACHE/core-agent.log"
AGENT_SERVER_PID_FILE="$CORE_CACHE/agent/server.pid"

agent_server_running() {
	[[ -f "$AGENT_SERVER_PID_FILE" ]] || return 1
	local pid
	pid=$(cat "$AGENT_SERVER_PID_FILE" 2>/dev/null)
	[[ -n "$pid" ]] || return 1
	kill -0 "$pid" 2>/dev/null
}

agent_server_wait() {
	local i
	# ── WAIT TIMEOUT IN SECONDS — change 10 to whatever you need ──
	for ((i = 0; i < 10; i++)); do
		if curl -fsS -m 3 "$(agent_models_url)" &>/dev/null; then
			log_success "Model server is up: ${D_CYAN}$AGENT_ENDPOINT${D_NC}"
			return 0
		fi
		sleep 1
	done
	log_warn "Server is still starting — you can keep going, requests will wait for it"
	return 1
}

agent_server_ensure() {
	# already reachable → do nothing, start directly
	if curl -fsS -m 3 "$(agent_models_url)" &>/dev/null; then
		return 0
	fi
	# our own background server is already starting → keep waiting
	if agent_server_running; then
		loading "Waiting for the model server…" agent_server_wait
		return 0
	fi
	if ! command -v cactus &>/dev/null; then
		log_warn "cactus not installed — start the server manually:"
		list_item "${D_CYAN}$AGENT_SERVER_CMD${D_NC}"
		return 1
	fi
	echo
	log_info "Starting the Cactus model server in the background…"
	list_item "Logs: ${D_CYAN}$AGENT_SERVER_LOG${D_NC}"
	mkdir -p "$(dirname "$AGENT_SERVER_PID_FILE")"
	rm -f "$AGENT_SERVER_PID_FILE"
	# stdin from /dev/null so proot-distro (used by the cactus wrapper)
	# never blocks waiting for the terminal. The background wrapper writes
	# its OWN real PID (setsid may fork, so $! can point at a dead
	# intermediate); `exec` keeps that PID for the actual server.
	setsid bash -c 'echo $$ > "$1"; shift; exec "$@"' _ "$AGENT_SERVER_PID_FILE" $AGENT_SERVER_CMD </dev/null >"$AGENT_SERVER_LOG" 2>&1 &
	# wait for the wrapper to write its PID before we can track/stop it
	local i
	for ((i = 0; i < 5; i++)); do
		[[ -s "$AGENT_SERVER_PID_FILE" ]] && break
		sleep 1
	done
	# wait a few seconds for it to boot — the loading spinner from
	# @core/utils/log.sh runs while it starts, and the terminal is
	# NOT cleared afterwards
	loading "Waiting for the model server…" agent_server_wait
	return 0
}

agent_server_stop() {
	[[ -f "$AGENT_SERVER_PID_FILE" ]] || return 0
	local pid
	pid=$(cat "$AGENT_SERVER_PID_FILE" 2>/dev/null)
	rm -f "$AGENT_SERVER_PID_FILE"
	if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
		# kill the whole process group (setsid): wrapper + proot + server
		kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null
		log_info "Stopped the model server (PID $pid)"
	fi
}

# ------------------------------------------------------------
# agent_confirm — plain-ASCII y/N confirmation (mobile-friendly
# replacement for read_confirm, whose ┌─/└─▶ box art renders
# badly on some Termux fonts).
# ------------------------------------------------------------
agent_confirm() {
	local prompt="$1" var="$2" _val
	while true; do
		printf '    %s%s [%s]%s\n' "$D_YELLOW" "$prompt" "${D_GREEN}y${GRAY}/${D_RED}n${NC}" "$NC" >&2
		printf '    > ' >&2
		read -rn1 _val
		echo >&2
		case "${_val,,}" in
		y)
			read -r "$var" <<<"y"
			return 0
			;;
		n)
			read -r "$var" <<<"n"
			return 1
			;;
		*) printf '    %s✖%s Reply y or n\n' "$RED" "$NC" >&2 ;;
		esac
	done
}

# ------------------------------------------------------------
# agent_read_input — plain-ASCII single-line input prompt for
# the REPL slash commands (replaces read_input's box art).
# ------------------------------------------------------------
agent_read_input() {
	local prompt="$1" var="$2" _val
	printf '    %s%s%s > ' "$D_CYAN" "$prompt" "$NC" >&2
	read -r _val
	read -r "$var" <<<"$_val"
}

# ------------------------------------------------------------
# Context usage — rough token estimate (chars/4) vs the model's
# context window, so the user can watch the context fill up.
# ------------------------------------------------------------
agent_context_tokens() {
	local text="$1"
	echo $(( $(printf '%s' "$text" | wc -c) / 4 ))
}

agent_context_pct() {
	local history="$1"
	local win toks pct
	win="${AGENT_CONTEXT_WINDOW:-8192}"
	toks=$(agent_context_tokens "$history")
	pct=$(( toks * 100 / win ))
	(( pct > 100 )) && pct=100
	printf '%s%% (%sk/%sk tok)' "$pct" "$((toks / 1000))" "$((win / 1000))"
}

# ------------------------------------------------------------
# Elapsed-time helpers — wall clock for the context footer
# ------------------------------------------------------------
agent_timer_start() {
	AGENT_T0=$(date +%s%N 2>/dev/null || echo 0)
}

agent_timer_ms() {
	local t0="${AGENT_T0:-0}" t1
	t1=$(date +%s%N 2>/dev/null || echo 0)
	if (( t0 > 0 && t1 >= t0 )); then
		echo $(((t1 - t0) / 1000000))
	else
		echo 0
	fi
}

agent_fmt_dur() {
	local ms=$1
	(( ms < 0 )) && ms=0
	if (( ms >= 60000 )); then
		printf '%dm %02ds' $((ms / 60000)) $(((ms % 60000) / 1000))
	elif (( ms >= 10000 )); then
		printf '%ds' $((ms / 1000))
	else
		awk -v m="$ms" 'BEGIN { printf "%.1fs", m / 1000 }'
	fi
}

# ------------------------------------------------------------
# agent_context_footer <history> [elapsed_ms] — "16% (1k/8k tok)"
# plus the elapsed time when available
# ------------------------------------------------------------
agent_context_footer() {
	local history="$1" ms="$2"
	local base
	base=$(agent_context_pct "$history")
	if (( ms > 0 )); then
		printf '%s · %s' "$base" "$(agent_fmt_dur "$ms")"
	else
		printf '%s' "$base"
	fi
}

# ------------------------------------------------------------
# agent_history_trim_tokens <history> <budget> — drop the oldest
# non-system messages until the estimated token count fits the
# budget (keeps the system prompt).
# ------------------------------------------------------------
agent_history_trim_tokens() {
	local history="$1" budget="${2:-0}"
	(( budget <= 0 )) && { echo "$history"; return; }
	local toks n
	while :; do
		toks=$(agent_context_tokens "$history")
		(( toks <= budget )) && break
		n=$(printf '%s' "$history" | jq 'length')
		(( n <= 4 )) && break
		history=$(printf '%s' "$history" | jq -c 'if .[0].role == "system" then .[0:1] + .[2:] else .[1:] end')
	done
	echo "$history"
}

# ------------------------------------------------------------
# agent_maybe_compact <history> <window> — when the context is
# getting full, summarize the OLDEST messages (keeping the system
# prompt and the most recent turns intact) into a single compact
# summary via the model, so the conversation thread survives long
# sessions. Echoes the new history. All visual feedback goes to
# STDERR so the function is safe inside $(...) substitutions.
# Falls back to a plain drop when the model is unavailable, the
# user cancels (ESC ESC), or the excerpt is too small to summarize.
# ------------------------------------------------------------
agent_maybe_compact() {
	local history="$1" window="${2:-$AGENT_CONTEXT_WINDOW}"
	window="${window:-8192}"
	local n toks thr
	n=$(printf '%s' "$history" | jq 'length')
	toks=$(agent_context_tokens "$history")
	# compact early, before the 60% hard trim would kick in
	thr=$(( window * 55 / 100 ))
	if (( toks <= thr || n <= 8 )); then
		printf '%s' "$history"
		return 0
	fi

	# keep the system prompt + the last `keep` messages verbatim
	local keep=6 drop_end
	drop_end=$((n - keep))
	if (( drop_end <= 1 )); then
		printf '%s' "$history"
		return 0
	fi

	local sys excerpt recent excerpt_text
	sys=$(printf '%s' "$history" | jq -c '.[0:1]')
	excerpt=$(printf '%s' "$history" | jq -c --argjson de "$drop_end" '.[1:$de]')
	recent=$(printf '%s' "$history" | jq -c --argjson de "$drop_end" '.[$de:]')
	excerpt_text=$(printf '%s' "$excerpt" | jq -r '.[] | "## " + (.role // "?") + "\n" + (.content // "")')

	local nprompt phist pfile outfile
	nprompt='You are compacting an agent conversation so a later turn can continue without losing the thread. Summarize ONLY the messages below into a concise summary that preserves: the user'\''s original goal and follow-ups, files created or edited (paths), shell commands run and their key results, decisions, constraints, and the current state of the work. Use the same language as the excerpt. Reply with the summary text only — no preamble, no code fences.'
	pfile=$(agent_md_dir)/compact_payload.json
	outfile=$(agent_md_dir)/compact_result.txt
	phist=$(jq -nc --arg s "$nprompt" --arg u "$excerpt_text" \
		'[{role:"system",content:$s},{role:"user",content:$u}]')
	printf '%s' "$phist" >"$pfile"

	# --- spinner feedback on stderr (stdout must stay clean) ---
	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local delay=0.08 pct_msg
	pct_msg=$(printf '%s%%' "$(( toks * 100 / window ))")
	printf '\r    %s%s%s %s%s' "$D_CYAN" "${frames[0]}" "context $pct_msg — compacting older messages…" "$D_GRAY" "$NC" >&2

	local pid stty_saved="" i=0 rc=0
	if [[ -t 0 ]]; then
		stty_saved=$(stty -g 2>/dev/null)
		stty -echo 2>/dev/null
	fi

	agent_chat_text_to "$phist" "$outfile" >/dev/null 2>&1 &
	pid=$!
	while kill -0 "$pid" 2>/dev/null; do
		if [[ -t 0 ]] && _agent_esc_esc; then
			_agent_kill_tree "$pid"
			wait "$pid" 2>/dev/null
			rc=130
			break
		fi
		printf '\r    %s%s%s %s%s' "$D_CYAN" "${frames[i]}" "context $pct_msg — compacting older messages…" "$D_GRAY" "$NC" >&2
		((i = (i + 1) % ${#frames[@]}))
		sleep "$delay"
	done
	wait "$pid" 2>/dev/null
	local rc2=$?
	[[ -n "$stty_saved" ]] && stty "$stty_saved" 2>/dev/null

	local summary
	summary=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$outfile" 2>/dev/null | tr -d '\r')

	if (( rc == 0 && rc2 == 0 )) && [[ -n "$summary" ]]; then
		local compact_msg new_history toks_after pct_after msgs saved_k saved_txt
		msgs=$((drop_end - 1))
		compact_msg=$(printf '<compacted_summary>\n%s\n</compacted_summary>' "$summary")
		new_history=$(printf '%s' "$sys" | jq -c --arg c "$compact_msg" '. + [{role:"user", content:$c}]')
		new_history=$(printf '%s' "$new_history" | jq -c --argjson r "$recent" '. + $r')
		toks_after=$(agent_context_tokens "$new_history")
		pct_after=$(( toks_after * 100 / window ))
		saved_k=$(( (toks - toks_after) / 1000 ))
		if (( saved_k >= 1 )); then
			saved_txt="${saved_k}k tok saved"
		else
			saved_txt="$((toks - toks_after)) tok saved"
		fi
		printf '\r    %s✔%s %s%s\n' "$GREEN" "$D_GREEN" "compacted $msgs older messages → summary ($saved_txt, context now $pct_after%)" "$NC" >&2
		printf '%s' "$new_history"
	else
		# fallback: plain drop of the oldest non-system message
		local newh
		newh=$(printf '%s' "$history" | jq -c 'if .[0].role == "system" then .[0:1] + .[2:] else .[1:] end')
		if (( rc == 130 )); then
			printf '\r    %s✖%s %s%s\n' "$D_RED" "$D_GRAY" "compaction canceled — dropping oldest messages instead" "$NC" >&2
			AGENT_ABORT=1
		else
			printf '\r    %s⚠%s %s%s\n' "$D_YELLOW" "$D_GRAY" "compaction unavailable — dropping oldest messages" "$NC" >&2
		fi
		printf '%s' "$newh"
	fi
	rm -f "$pfile" "$outfile"
}

# ------------------------------------------------------------
# agent_history_manage <history> <window> — one entry point used
# before every model call: compact (summarize) when the context is
# near full, then hard-trim as a final safety net under the budget.
# ------------------------------------------------------------
agent_history_manage() {
	local history="$1" window="${2:-$AGENT_CONTEXT_WINDOW}"
	history=$(agent_maybe_compact "$history" "$window")
	history=$(agent_history_trim_tokens "$history" "$((window * 60 / 100))")
	printf '%s' "$history"
}
