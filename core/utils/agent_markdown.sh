#!/usr/bin/env bash

# ============================================================
# agent_markdown.sh — Markdown renderer for the agent TUI.
# Pure bash + sed + awk. The model speaks markdown; this file
# turns **bold**, `code`, ```fences``` and headings into a
# colored terminal output and lets the shell identify code so
# it can be saved into files.
# ============================================================

import "@/utils/log"
import "@/utils/colors"

# Highlight colors used ONLY by the agent UI
AG_H1=$'\033[1;36m'
AG_H2=$'\033[0;36m'
AG_H3=$'\033[1;35m'
AG_BOLD=$'\033[0;36m'
AG_INLINE_CODE=$'\033[0;32m'
AG_CODE=$'\033[0;33m'
AG_QUOTE=$'\033[0;90m'
AG_LINK=$'\033[0;34m'

# Real-escape aliases (colors.sh vars are literal `\e` strings that
# need `echo -e`; our renderer prints with printf %s so we need the
# actual ESC byte here).
AG_GRAY=$'\033[0;90m'
AG_CYAN=$'\033[0;36m'
AG_GREEN=$'\033[0;32m'
AG_PURPLE=$'\033[0;35m'
AG_NC=$'\033[0;37m'

# Placeholder tokens used while formatting inline text
AG_PB=$'\x01B\x01'   # bold open
AG_PE=$'\x01E\x01'   # bold close
AG_PC=$'\x01C\x01'   # code open
AG_PCE=$'\x01D\x01'  # code close
AG_PL=$'\x01L\x01'   # link open
AG_PLE=$'\x01F\x01'  # link close

# ------------------------------------------------------------
# agent_md_dir : guarantee the agent tmp dir exists
# ------------------------------------------------------------
agent_md_dir() {
	local d="${AGENT_MD_TMP:-$CORE_CACHE/agent}"
	mkdir -p "$d"
	echo "$d"
}

# ------------------------------------------------------------
# md_inline <line> : color **bold**, `code`, [text](url)
# (prints a line)
# ------------------------------------------------------------
md_inline() {
	local line="$1"
	local d
	d=$(agent_md_dir)

	# bold **...**
	line=$(printf '%s\n' "$line" | sed 's/\*\*\([^*]*\)\*\*/'"${AG_PB}"'\1'"${AG_PE}"'/g')
	# inline code `...`
	line=$(printf '%s\n' "$line" | sed 's/`\([^`]*\)`/'"${AG_PC}"'\1'"${AG_PCE}"'/g')
	# links [text](url)
	line=$(printf '%s\n' "$line" | sed 's/\[\([^]]*\)\]([^)]*)/'"${AG_PL}"'\1'"${AG_PLE}"'/g')

	line=${line//$AG_PB/$AG_BOLD}
	line=${line//$AG_PE/$AG_NC}
	line=${line//$AG_PC/$AG_INLINE_CODE}
	line=${line//$AG_PCE/$AG_NC}
	line=${line//$AG_PL/$AG_LINK}
	line=${line//$AG_PLE/$AG_NC}

	printf '    %s\n' "$line"
}

# ------------------------------------------------------------
# md_heading <line> : render a # heading (prints a line)
# ------------------------------------------------------------
md_heading() {
	local line="$1"
	local hashes="${line%%[^#]*}"
	local level=${#hashes}
	local content="${line#"$hashes"}"
	content="${content# }"

	case "$level" in
	1) printf '%s' "$AG_H1" ; md_inline "$content" ;;
	2) printf '%s' "$AG_H2" ; md_inline "$content" ;;
	*) printf '%s' "$AG_H3" ; md_inline "$content" ;;
	esac
}

# ------------------------------------------------------------
# md_render_table <block> : aligned pipe-table renderer
# ------------------------------------------------------------
md_render_table() {
	local block="$1"

	local spec
	spec=$(printf '%s\n' "$block" | grep -v -- '-' | awk -F'|' '
		{
			for (c=1; c<=NF-2; c++) {
				v=$(c+1); gsub(/^ +| +$/,"",v)
				if (length(v) > w[c]) w[c]=length(v)
				if (NF-2 > cols) cols=NF-2
			}
		}
		END { for (c=1; c<=cols; c++) printf "%d ", (w[c] ? w[c] : 10) }
	')

	local -a w=()
	read -r -a w <<<"$spec"
	local cols=${#w[@]}
	(( cols < 1 )) && cols=1

	local line cell cv
	local -a cells=()
	while IFS= read -r line || [[ -n "$line" ]]; do
		if printf '%s\n' "$line" | grep -q -- '-'; then
			continue  # skip separator rows
		fi
		cells=()
		while IFS= read -r cell; do
			cells+=("$cell")
		done <<<"$(printf '%s\n' "$line" | awk -F'|' '{for(i=2;i<NF;i++) printf "%s\n", $i}')"
		printf '    '
		for ((i = 0; i < cols; i++)); do
			cv="${cells[$i]:-}"
			cv=$(echo "$cv" | xargs)
			printf '%s%-*s%s  ' "$AG_CYAN" "${w[$i]}" "$cv" "$AG_NC"
		done
		printf '\n'
	done <<<"$block"
}

# ------------------------------------------------------------
# md_render <text> : pretty print a markdown message
# ------------------------------------------------------------
md_render() {
	local text="$1"

	local in_code=0
	local code_lang=""
	local block_no=0
	local line=""
	local -a pending_table=()

	flush_table() {
		if [[ ${#pending_table[@]} -gt 0 ]]; then
			md_render_table "$(printf '%s\n' "${pending_table[@]}")"
			pending_table=()
		fi
	}

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line%$'\r'}"

		if (( in_code == 1 )); then
			if [[ "$line" =~ ^\`\`\` ]]; then
				separator
				in_code=0
			else
				printf '%s%s%s\n' "$AG_CODE" "$line" "$AG_NC"
			fi
			continue
		fi

		# open a fenced code block
		if [[ "$line" =~ ^\`\`\` ]]; then
			flush_table
			code_lang="${line#\`\`\`}"
			code_lang="${code_lang%% *}"
			if [[ "$code_lang" == "tool_call" ]]; then
				in_code=2 # hidden internal block
				continue
			fi
			((block_no++))
			separator_section "[ ${code_lang:-code} ] #$block_no"
			in_code=1
			continue
		fi

		if (( in_code == 2 )); then
			[[ "$line" =~ ^\`\`\` ]] && in_code=0
			continue
		fi

		if [[ -z "$line" ]]; then
			flush_table
			echo
			continue
		fi

		# horizontal rule
		if [[ "$line" =~ ^(-{3,}|\*{3,}|_{3,})[[:space:]]*$ ]]; then
			flush_table
			separator
			continue
		fi

		# headings
		if [[ "$line" =~ ^#{1,6}[[:space:]] ]]; then
			flush_table
			md_heading "$line"
			continue
		fi

		# blockquote
		if [[ "$line" =~ ^\> ]]; then
			flush_table
			printf '%s│ %s%s\n' "$AG_QUOTE" "${line#> }" "$AG_NC"
			continue
		fi

		# buffer pipe-table rows
		if [[ "$line" =~ ^\| ]]; then
			pending_table+=("$line")
			continue
		fi

		flush_table

		# unordered list
		if [[ "$line" =~ ^[-*+][[:space:]] ]]; then
			printf '    %s•%s ' "$AG_GRAY" "$AG_NC"
			md_inline "$(printf '%s\n' "$line" | sed -E 's/^[-*+][[:space:]]+//')"
			continue
		fi

		# ordered list
		if [[ "$line" =~ ^[0-9]+\.[[:space:]] ]]; then
			printf '    %s%s.%s ' "$AG_GREEN" "${line%%[^0-9]*}" "$AG_NC"
			md_inline "$(printf '%s\n' "$line" | sed -E 's/^[0-9]+\.[[:space:]]+//')"
			continue
		fi

		md_inline "$line"
	done <<<"$text"

	flush_table
}
# ------------------------------------------------------------
# ------------------------------------------------------------
# md_has_tool_call <text> : echo 1 when response contains a
# hidden tool_call block, else 0
# ------------------------------------------------------------
md_has_tool_call() {
	local text="$1"
	if printf '%s\n' "$text" | grep -q '^```tool_call'; then
		echo 1
	else
		echo 0
	fi
}