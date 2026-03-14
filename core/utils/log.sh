#!/bin/bash

import "@/utils/colors"

# ===== LOG FUNCTIONS =====

log_info() {
	echo -e "    ${CYAN}➜${D_CYAN} $*"${D_NC}
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

	echo -e "${GRAY}${line// /─} ${D_CYAN}${title}${GRAY} ${line// /─}${NC}"
}

# ===== CENTER TEXT =====

center_text() {
	local cols=$(tput cols)
	local text="$1"
	local padding=$(( (cols - ${#text}) / 2 ))

	# Remover códigos ANSI para calcular padding correcto
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
	echo -e "${GRAY}│${D_CYAN} $text ${GRAY}│${NC}"
	echo -e "${GRAY}╰${line// /─}╯${NC}"
}

box_large() {
	local text="$1"
	local len=${#text}
	local line=$(printf "%$((len + 4))s")

	echo -e "${GRAY}╔${line// /═}╗${NC}"
	echo -e "${GRAY}║${D_CYAN}  $text  ${GRAY}║${NC}"
	echo -e "${GRAY}╚${line// /═}╝${NC}"
}

box_with_subtitle() {
	local title="$1"
	local subtitle="$2"
	local max_len=$(( ${#title} > ${#subtitle} ? ${#title} : ${#subtitle} ))
	local line=$(printf "%$((max_len + 2))s")

	echo -e "${GRAY}╭${line// /─}╮${NC}"
	echo -e "${GRAY}│${D_CYAN} $title${GRAY}$(printf "%$((max_len - ${#title}))s") │${NC}"
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
# Uso simple: table_row "valor1" "valor2" "valor3"
# Por defecto: col 1 → D_GREEN, col 2 → D_CYAN, resto → sin color
# También acepta colores custom: table_row "${RED}valor${NC}" ...
table_row() {
	local -a colored=()
	local i=0
	for field in "$@"; do
		# Solo aplicar color por defecto si el campo no contiene ya un escape ANSI
		if [[ "$field" != *$'\x1b['* ]]; then
			case $i in
			0) colored+=("${D_GREEN}${field}${NC}") ;;
			1) colored+=("${D_CYAN}${field}${NC}") ;;
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
# Elimina códigos de escape ANSI para medir la longitud visual real
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
# Genera una línea horizontal con los caracteres correctos según posición
# $1: char izquierdo, $2: char relleno, $3: char separador, $4: char derecho
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

	# Headers (D_RED por defecto)
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
# El segundo argumento es el nombre de la variable donde se guarda el resultado.

# --- Texto simple ---
# Uso: read_input "Prompt" VAR_NAME
read_input() {
	local prompt="$1"
	local var="$2"
	local _val

	echo -e -n "    ${GRAY}┌─${D_CYAN} ${prompt} ${NC}\n"
	echo -e -n "    ${GRAY}└─${D_CYAN}▶ ${D_NC}"
	read -r _val
	read -r "$var" <<<"$_val"
}

# --- Confirmación s/n ---
# Uso: read_confirm "¿Continuar?" VAR_NAME
# Retorna 0 si sí, 1 si no. VAR_NAME recibe "y" o "n"
read_confirm() {
	local prompt="$1"
	local var="$2"
	local _val

	while true; do
		echo -e -n "    ${GRAY}┌─${D_YELLOW} ${prompt} ${GRAY}[${D_GREEN}y${GRAY}/${D_RED}n${GRAY}]${D_NC}\n"
		echo -e -n "    ${GRAY}└─${D_YELLOW}▶ ${D_NC}"
		read -rn1 _val
		echo
		case "${_val,,}" in
		y)
			read -r "$var" <<<"y"
			return 0
			;;
		n)
			read -r "$var" <<<"n"
			return 1
			;;
		*) echo -e "    ${RED}✖${D_NC} Reply ${D_GREEN}y${D_NC} o ${D_RED}n${D_NC}" ;;
		esac
	done
}

# --- Selección de opciones ---
# Uso: read_select "Prompt" VAR_NAME "Opción1" "Opción2" ...
# VAR_NAME recibe el texto de la opción elegida
read_select() {
	local prompt="$1"
	local var="$2"
	shift 2
	local -a options=("$@")
	local selected=0
	local total=${#options[@]}

	_render_select() {
		echo -e "    ${GRAY}┌─${D_CYAN} ${prompt}${NC}"
		for ((i = 0; i < total; i++)); do
			if ((i == selected)); then
				echo -e "    ${GRAY}│  ${D_CYAN}▶ ${WHITE}${options[$i]}${D_NC}"
			else
				echo -e "    ${GRAY}│    ${GRAY}${options[$i]}${D_NC}"
			fi
		done
		echo -e -n "    ${GRAY}└─${D_NC} ${GRAY}↑↓ move  Enter confirm${D_NC}"
	}

	tput civis # ocultar cursor
	tput sc    # guardar posición del cursor
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

		tput rc # restaurar posición guardada
		tput ed # borrar desde cursor hasta fin de pantalla
		_render_select
	done

	echo
	tput cnorm # mostrar cursor

	read -r "$var" <<<"${options[$selected]}"
	echo -e "    ${GRAY}└─${D_CYAN}▶ ${D_NC}${options[$selected]}${D_NC}"
}

# ===== LOADING SPINNER =====

loading() {
	local message="$1"
	shift

	local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
	local delay=0.08

	"$@" &>/dev/null &
	local pid=$!

	local i=0

	while kill -0 "$pid" 2>/dev/null; do
		printf "\r"
		echo -ne "${D_CYAN}${message}${D_NC} ${frames[i]}"
		((i = (i + 1) % ${#frames[@]}))
		sleep $delay
	done

	wait $pid
	local exit_code=$?

	printf "\r"

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

	printf "\r${D_CYAN}[${D_NC}${D_GREEN}%s${D_NC}${D_CYAN}]${D_NC} %3d%%" "$bar" "$percentage"
}

# ===== STEP FUNCTIONS =====

step_start() {
	local step="$1"
	local message="$2"
	echo -e "    ${D_CYAN}[$step]${D_NC} $message"
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
	echo -e "${CYAN}ℹ${NC}"
}

icon_arrow() {
	echo -e "${D_CYAN}→${NC}"
}

# ===== BADGE FUNCTIONS =====

badge() {
	local text="$1"
	local color="${2:-D_CYAN}"
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
