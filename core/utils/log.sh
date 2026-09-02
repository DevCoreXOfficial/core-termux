#!/usr/bin/env bash

import "@/utils/colors"

# ===== LOG FUNCTIONS =====

log_info() {
	echo -e "    ${GRAY_19}➜${GRAY_12} $*"${D_NC}
}

log_success() {
	echo -e "    ${GREEN}✔${D_GREEN} $*"${D_NC}
}

log_warn() {
	echo -e "    ${YELLOW}⚠${D_YELLOW} $*"${D_NC}
}

log_error() {
	echo -e "    ${RED}✖${D_RED} $*"${D_NC} >&2
}

log_debug() {
	if [[ "${CORE_DEBUG:-0}" == "1" ]]; then
		echo -e "    ${PURPLE}⚙${D_PURPLE} [DEBUG] $*${D_NC}"
	fi
}

list_item() {
	echo -e "    ${GRAY}•${D_NC} $*"
}

list_item_check() {
	local status="$1"
	local text="$2"

	case "$status" in
	"done" | "success")
		echo -e "    ${GREEN}✔${D_NC} $text"
		;;
	"pending")
		echo -e "    ${YELLOW}⏳${D_NC} $text"
		;;
	"error" | "fail")
		echo -e "    ${RED}✖${D_NC} $text"
		;;
	*)
		echo -e "    ${GRAY}•${D_NC} $text"
		;;
	esac
}

# ===== SEPARATOR FUNCTIONS =====

separator() {
	local cols=$(tput cols)
	local line=$(printf "%${cols}s")
	echo -e "${GRAY}${line// /─}${NC}"
}

separator_double() {
	local cols=$(tput cols)
	local line=$(printf "%${cols}s")
	echo -e "${GRAY}${line// /═}${NC}"
	echo -e "${GRAY}${line// /═}${NC}"
}

separator_section() {
	local title="$1"
	local cols=$(tput cols)
	local padding=$(( (cols - ${#title} - 2) / 2 ))
	local line=$(printf "%${padding}s")

	echo -e "${GRAY}${line// /─} ${GRAY_19}${title}${GRAY} ${line// /─}${NC}"
}

# ===== CENTER TEXT =====

center_text() {
	local cols=$(tput cols)
	local text="$1"
	local padding=$(( (cols - ${#text}) / 2 ))

	# Remove ANSI codes to calculate correct padding
	local clean_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
	local clean_len=${#clean_text}
	padding=$(( (cols - clean_len) / 2 ))

	printf "%${padding}s" ""
	echo -e "$text"
}

# ===== BOX FUNCTIONS =====

# Draw a box around the given text
box() {
	local text="$1"
	local len=${#text}
	local line=$(printf "%$((len + 2))s")

	echo -e "${GRAY}╭${line// /─}╮${NC}"
	echo -e "${GRAY}│${GRAY_19} $text ${GRAY}│${NC}"
	echo -e "${GRAY}╰${line// /─}╯${NC}"
}

box_large() {
	local text="$1"
	local len=${#text}
	local line=$(printf "%$((len + 4))s")

	echo -e "${GRAY}╔${line// /═}╗${NC}"
	echo -e "${GRAY}║${GRAY_19}  $text  ${GRAY}║${NC}"
	echo -e "${GRAY}╚${line// /═}╝${NC}"
}

box_with_subtitle() {
	local title="$1"
	local subtitle="$2"
	local max_len=$(( ${#title} > ${#subtitle} ? ${#title} : ${#subtitle} ))
	local line=$(printf "%$((max_len + 2))s")

	echo -e "${GRAY}╭${line// /─}╮${NC}"
	echo -e "${GRAY}│${GRAY_19} $title${GRAY}$(printf "%$((max_len - ${#title}))s") │${NC}"
	echo -e "${GRAY}│${D_PURPLE} $subtitle${GRAY}$(printf "%$((max_len - ${#subtitle}))s") │${NC}"
	echo -e "${GRAY}╰${line// /─}╯${NC}"
}

# ===== TABLE FUNCTIONS =====

# ===== INTERNAL TABLE STATE =====
TABLE_HEADERS=()
TABLE_ROWS=()
TABLE_WIDTHS=()

# ===== START TABLE =====
table_start() {
	TABLE_HEADERS=("$@")
	TABLE_ROWS=()
}

# ===== ADD ROW =====
# Simple usage: table_row "value1" "value2" "value3"
# By default: col 1 → D_GREEN, col 2 → GRAY_19, rest → no color
# Also accepts custom colors: table_row "${RED}value${NC}" ...
table_row() {
	local -a colored=()
	local i=0
	for field in "$@"; do
		# Only apply default color if the field does not already contain an ANSI escape
		if [[ "$field" != *$'\x1b['* ]]; then
			case $i in
			0) colored+=("${D_GREEN}${field}${NC}") ;;
			1) colored+=("${GRAY_19}${field}${NC}") ;;
			*) colored+=("${D_NC}${field}${NC}") ;;
			esac
		else
			colored+=("$field")
		fi
		((i++))
	done
	local IFS=$'\x1F'
	TABLE_ROWS+=("${colored[*]}")
}

# ===== STRIP ANSI =====
# Removes ANSI escape codes to measure the real visual length
strip_ansi() {
	echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# ===== CALCULATE COLUMN WIDTHS =====
table_calc_widths() {
	local cols=${#TABLE_HEADERS[@]}

	for ((i = 0; i < cols; i++)); do
		TABLE_WIDTHS[$i]=${#TABLE_HEADERS[$i]}
	done

	for row in "${TABLE_ROWS[@]}"; do
		IFS=$'\x1F' read -r -a fields <<<"$row"
		for ((i = 0; i < cols; i++)); do
			local visual
			visual=$(strip_ansi "${fields[$i]}")
			local len=${#visual}
			((len > TABLE_WIDTHS[$i])) && TABLE_WIDTHS[$i]=$len
		done
	done
}

# ===== BORDER HELPERS =====
# Generates a horizontal line with the correct characters according to position
# $1: left char, $2: fill char, $3: separator char, $4: right char
table_border() {
	local left="$1" fill="$2" sep="$3" right="$4"
	echo -ne "${GRAY}${left}"
	local last=$((${#TABLE_WIDTHS[@]} - 1))
	for i in "${!TABLE_WIDTHS[@]}"; do
		local w="${TABLE_WIDTHS[$i]}"
		local line=$(printf "%$((w + 2))s")
		echo -ne "${line// /${fill}}"
		if ((i < last)); then
			echo -ne "${sep}"
		fi
	done
	echo -e "${right}${NC}"
}

# ===== RENDER TABLE =====
table_end() {
	table_calc_widths

	local cols=${#TABLE_HEADERS[@]}

	# Top border:    ┌───┬───┐
	table_border "┌" "─" "┬" "┐"

	# Headers (D_RED by default)
	echo -ne "${GRAY}│${NC}"
	for ((i = 0; i < cols; i++)); do
		printf " ${D_RED}%-${TABLE_WIDTHS[$i]}s ${GRAY}│${NC}" "${TABLE_HEADERS[$i]}"
	done
	echo

	# Middle border: ├───┼───┤
	table_border "├" "─" "┼" "┤"

	# Rows
	for row in "${TABLE_ROWS[@]}"; do
		IFS=$'\x1F' read -r -a fields <<<"$row"

		echo -ne "${GRAY}│${NC}"
		for ((i = 0; i < cols; i++)); do
			local display="${fields[$i]}"
			local visual
			visual=$(strip_ansi "$display")

			local pad=$((TABLE_WIDTHS[$i] - ${#visual}))
			local spaces
			printf -v spaces "%${pad}s" ""

			printf " %b%s ${GRAY}│${NC}" "$display" "$spaces"
		done
		echo
	done

	# Bottom border: └───┴───┘
	table_border "└" "─" "┴" "┘"
}

# ===== READ FUNCTIONS =====
# The second argument is the name of the variable where the result is stored.

# --- Simple text ---
# Usage: read_input "Prompt" VAR_NAME
read_input() {
	local prompt="$1"
	local var="$2"
	local _val

	echo -e -n "    ${GRAY}┌─${GRAY_19} ${prompt} ${NC}\n" >&2
	echo -e -n "    ${GRAY}└─${GRAY_19}▶ ${D_NC}" >&2
	read -r _val
	read -r "$var" <<<"$_val"
}

# --- Masked input (passwords, tokens, API keys) ---
# Reads character by character and shows ● for each one.
# Usage: read_secret "Prompt" VAR_NAME
read_secret() {
	local prompt="$1"
	local var="$2"
	local _val=""
	local char

	echo -e -n "    ${GRAY}┌─${GRAY_19} ${prompt} ${NC}\n" >&2
	echo -e -n "    ${GRAY}│${D_DIM} (input will be hidden)${D_NC}\n" >&2
	echo -e -n "    ${GRAY}└─${GRAY_19}▶ ${D_NC}" >&2

	local old_stty
	old_stty=$(stty -g 2>/dev/null)
	stty -echo -icanon min 1 time 0 2>/dev/null

	while true; do
		char=$(dd bs=1 count=1 2>/dev/null)
		if [[ "$char" == $'\n' ]] || [[ "$char" == $'\r' ]] || [[ -z "$char" ]]; then
			break
		fi
		if [[ "$char" == $'\177' ]] || [[ "$char" == $'\b' ]] || [[ "$char" == $'\x7f' ]]; then
			if [[ -n "$_val" ]]; then
				_val="${_val%?}"
				echo -ne "\b \b" >&2
			fi
		else
			_val+="$char"
			echo -ne "●" >&2
		fi
	done

	stty "$old_stty" 2>/dev/null
	echo >&2
	read -r "$var" <<<"$_val"
}

# --- Confirmation y/n ---
# Usage: read_confirm "Continue?" VAR_NAME
# Returns 0 if yes, 1 if no. VAR_NAME receives "y" or "n"
read_confirm() {
	local prompt="$1"
	local var="$2"
	local _val

	while true; do
		echo -e -n "    ${GRAY}┌─${D_YELLOW} ${prompt} ${GRAY}[${D_GREEN}y${GRAY}/${D_RED}n${GRAY}]${D_NC}\n" >&2
		echo -e -n "    ${GRAY}└─${D_YELLOW}▶ ${D_NC}" >&2
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
		*) echo -e "    ${RED}✖${D_NC} Reply ${D_GREEN}y${D_NC} or ${D_RED}n${D_NC}" >&2 ;;
		esac
	done
}

# --- Confirmation with default ---
# default="y" → [Y/n]  |  default="n" → [y/N]
# Returns 0 if yes, 1 if no. VAR_NAME receives "y" or "n"
# Usage: read_confirm_default "Continue?" "y" VAR_NAME
read_confirm_default() {
	local prompt="$1"
	local default="$2"
	local var="$3"
	local _val

	local show_default
	if [[ "$default" == "y" ]]; then
		show_default="${D_GREEN}Y${GRAY}/${D_RED}n${GRAY}"
	else
		show_default="${D_GREEN}y${GRAY}/${D_RED}N${GRAY}"
	fi

	while true; do
		echo -e -n "    ${GRAY}┌─${D_YELLOW} ${prompt} ${GRAY}[${show_default}${GRAY}]${D_NC}\n" >&2
		echo -e -n "    ${GRAY}└─${D_YELLOW}▶ ${D_NC}" >&2
		read -rn1 _val
		echo >&2
		if [[ -z "$_val" ]]; then
			_val="$default"
		fi
		case "${_val,,}" in
		y)
			read -r "$var" <<<"y"
			return 0
			;;
		n)
			read -r "$var" <<<"n"
			return 1
			;;
		*) echo -e "    ${RED}✖${D_NC} Reply ${D_GREEN}y${D_NC} or ${D_RED}n${D_NC}" >&2 ;;
		esac
	done
}

# --- Option selection ---
# Usage: read_select "Prompt" VAR_NAME "Option1" "Option2" ...
# VAR_NAME receives the text of the selected option
read_select() {
	local prompt="$1"
	local var="$2"
	shift 2
	local -a options=("$@")
	local selected=0
	local total=${#options[@]}
	local cols
	cols=$(tput cols)
	local margin=6
	local max_width=$((cols - margin))

	_render_select() {
		echo -e "    ${GRAY}┌─${GRAY_19} ${prompt}${NC}" >&2
		for ((i = 0; i < total; i++)); do
			local text="${options[$i]}"
			if (( ${#text} > max_width )); then
				text="${text:0:$((max_width - 3))}..."
			fi
			if ((i == selected)); then
				echo -e "    ${GRAY}│  ${GRAY_19}▶ ${WHITE}${text}${D_NC}" >&2
			else
				echo -e "    ${GRAY}│    ${GRAY}${text}${D_NC}" >&2
			fi
		done
		echo -e -n "    ${GRAY}└─${D_NC} ${GRAY}↑↓ move  Enter confirm${D_NC}" >&2
	}

	local lines=$((total + 1))

	tput civis
	_render_select

	while true; do
		IFS= read -rsn1 key
		if [[ "$key" == $'\x1b' ]]; then
			read -rsn2 -t 0.1 rest
			key="${key}${rest}"
		fi

		case "$key" in
		$'\x1b[A' | k) ((selected > 0)) && ((selected--)) ;;
		$'\x1b[B' | j) ((selected < total - 1)) && ((selected++)) ;;
		'') break ;;
		esac

		echo -en "\r\033[${lines}A\033[J" >&2
		_render_select
	done

	echo >&2
	tput cnorm

	read -r "$var" <<<"${options[$selected]}"
	echo -e "    ${GRAY}└─${GRAY_19}▶ ${D_NC}${options[$selected]}${D_NC}" >&2
}

# --- Multi-line input (interactive shell, no external editor) ---
# Reads content line by line until Ctrl+D.
# Usage: local tmp; tmp=$(read_multiline "Initial header"); content=$(cat "$tmp"); rm -f "$tmp"
read_multiline() {
	local initial="$1"
	local tmpfile
	tmpfile=$(mktemp)

	echo "$initial" >"$tmpfile"
	echo >>"$tmpfile"

	local cols
	cols=$(tput cols 2>/dev/null || echo 80)
	local w=$((cols - 6))
	local bar
	printf -v bar '%*s' "$w" ''

	echo -e "    ${GRAY}╭${bar// /─}╮${NC}" >&2
	printf "    ${GRAY}│${NC}  ${GRAY_19}✎  Write your memory${D_NC}%*s ${GRAY}│${NC}\n" $((w - 24)) "" >&2
	printf "    ${GRAY}│${NC}  ${D_DIM}(Ctrl+D to finish, Ctrl+C to cancel)${D_NC}%*s ${GRAY}│${NC}\n" $((w - 40)) "" >&2
	echo -e "    ${GRAY}├${bar// /─}┤${NC}" >&2

	local line
	while IFS= read -r line; do
		echo "$line" >>"$tmpfile"
	done

	echo >&2
	echo -e "    ${GRAY}╰${bar// /─}╯${NC}" >&2
	echo -e "    ${GRAY}${D_GREEN}✔ Content captured${D_NC}" >&2

	echo "$tmpfile"
}

# ===== LOADING SPINNER =====

loading() {
	local message="$1"
	shift

	local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
	local delay=0.08
	local tmpfile
	tmpfile="$(mktemp)"

	printf "    ${GRAY_19}%s${GRAY_12} %s${NC}" "${frames[0]}" "$message"

	"$@" >"$tmpfile" 2>&1 &
	local pid=$!

	local i=0
	while kill -0 "$pid" 2>/dev/null; do
		printf "\r    ${GRAY_19}%s${GRAY_12} %s${NC}" "${frames[i]}" "$message"
		((i = (i + 1) % ${#frames[@]}))
		sleep $delay
	done

	wait "$pid"
	local exit_code=$?

	if [[ $exit_code -eq 0 ]]; then
		printf "\r    ${GREEN}✔${D_GREEN} %s${NC}\n" "$message"
		[[ -s "$tmpfile" ]] && cat "$tmpfile"
	elif [[ $exit_code -eq 2 ]]; then
		printf "\r    ${GRAY_19}➜${GRAY_12} %s${NC}\n" "$message"
		[[ -s "$tmpfile" ]] && cat "$tmpfile"
	else
		printf "\r    ${RED}✖${D_RED} %s${NC}\n" "$message"
		cat "$tmpfile"
	fi

	rm -f "$tmpfile"
	return $exit_code
}

# ===== PROGRESS BAR =====

progress_bar() {
	local current=$1
	local total=$2
	local width=${3:-50}
	local percentage=$((current * 100 / total))
	local filled=$((current * width / total))
	local empty=$((width - filled))

	local bar=""
	for ((i = 0; i < filled; i++)); do
		bar+="█"
	done
	for ((i = 0; i < empty; i++)); do
		bar+="░"
	done

	printf "\r${GRAY_19}[${D_NC}${D_GREEN}%s${D_NC}${GRAY_19}]${D_NC} %3d%%" "$bar" "$percentage"
}

# ===== STEP FUNCTIONS =====

step_start() {
	local step="$1"
	local message="$2"
	echo -e "    ${GRAY_19}[$step]${D_NC} $message"
}

step_success() {
	local step="$1"
	local message="$2"
	echo -e "    ${GREEN}[$step]${D_GREEN} $message ✔${NC}"
}

step_error() {
	local step="$1"
	local message="$2"
	echo -e "    ${RED}[$step]${D_RED} $message ✖${NC}" >&2
}

# ===== STATUS ICONS =====

icon_success() {
	echo -e "${GREEN}✓${NC}"
}

icon_error() {
	echo -e "${RED}✗${NC}"
}

icon_warning() {
	echo -e "${YELLOW}⚠${NC}"
}

icon_info() {
	echo -e "${WHITE}ℹ${NC}"
}

icon_arrow() {
	echo -e "${GRAY_19}→${NC}"
}

# ===== BADGE FUNCTIONS =====

badge() {
	local text="$1"
	local color="${2:-GRAY_19}"
	echo -e "${!color}[ $text ]${NC}"
}

badge_new() {
	echo -e "${D_GREEN}[ NEW ]${NC}"
}

badge_beta() {
	echo -e "${D_YELLOW}[ BETA ]${NC}"
}

badge_deprecated() {
	echo -e "${D_RED}[ DEPRECATED ]${NC}"
}

# ===== TIP FUNCTION =====

log_tip() {
	echo -e "    ${GRAY_19}●${NC} $*"
}
