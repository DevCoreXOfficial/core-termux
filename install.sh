#!/data/data/com.termux/files/usr/bin/bash

set -e

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
BLUE='\e[1;34m'
NC='\e[0m'

REPO="https://github.com/DevCoreXOfficial/core-termux"
BRANCH="main"
CORE_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/core-termux"
CORE_TOOL_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/core-termux-data"
CORE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/core-termux"
CORE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/core-termux"

TOTAL_STEPS=5
CURRENT_STEP=0

progress_bar() {
	local current=$1
	local total=$2
	local width=${3:-40}
	local percentage=$((current * 100 / total))
	local filled=$((current * width / total))
	local empty=$((width - filled))

	printf -v bar "%*s" "$filled" ""
	bar="${bar// /█}"
	printf -v space "%*s" "$empty" ""
	space="${space// /░}"

	printf "\r${CYAN}[${NC}${GREEN}%s${NC}${CYAN}]${NC} %3d%%" "${bar}${space}" "$percentage"
}

log_step() {
	local step="$1"
	local desc="$2"
	CURRENT_STEP=$((CURRENT_STEP + 1))
	printf "\r%*s\r" "$(tput cols)" ""
	echo -e "\n  ${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${NC} ${CYAN}${desc}${NC}"
}

log_ok() {
	echo -e "  ${GREEN}✔${NC} $1"
}

log_fail() {
	echo -e "  ${RED}✖${NC} $1" >&2
}

log_info() {
	echo -e "  ${CYAN}→${NC} $1"
}

separator() {
	local cols=$(tput cols)
	local line=$(printf "%${cols}s")
	echo -e "${YELLOW}${line// /─}${NC}"
}

banner() {
	echo -e "${CYAN}"
	cat << 'EOF'
╔══════════════════════════════════════╗
║         Core-Termux Installer        ║
║   Modular Dev Environment for Termux ║
╚══════════════════════════════════════╝
EOF
	echo -e "${NC}"
}

install_dependencies() {
	log_step 1 "Installing dependencies"

	progress_bar 0 10
	if ! command -v git &>/dev/null; then
		pkg install -y git &>/dev/null
	fi
	progress_bar 5 10
	if ! command -v tput &>/dev/null; then
		pkg install -y ncurses-utils &>/dev/null
	fi
	progress_bar 10 10
	echo
	log_ok "Dependencies installed (git, ncurses-utils)"
}

setup_directories() {
	log_step 2 "Setting up directories"

	mkdir -p "$CORE_DATA" "$CORE_TOOL_DATA" "$CORE_CACHE" "$CORE_CONFIG"

	log_info "Repo:    $CORE_DATA"
	log_info "Data:    $CORE_TOOL_DATA"
	log_info "Cache:   $CORE_CACHE"
	log_info "Config:  $CORE_CONFIG"
	log_ok "Directories created"
}

clone_repo() {
	log_step 3 "Cloning repository"

	local script_dir
	script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local is_dev_install=0

	if [[ -d "$script_dir/.git" ]] && [[ "$script_dir" != "$CORE_DATA" ]]; then
		is_dev_install=1
	fi

	if [[ $is_dev_install -eq 1 ]]; then
		CORE_DATA="$script_dir"
		log_info "Developer installation detected"
		log_ok "Using local repository"
	elif [[ -d "$CORE_DATA/.git" ]]; then
		progress_bar 3 10
		git -C "$CORE_DATA" pull origin "$BRANCH" &>/dev/null
		progress_bar 10 10
		echo
		log_ok "Repository updated"
	else
		progress_bar 0 10
		git clone --depth=1 -b "$BRANCH" "$REPO" "$CORE_DATA" &>/dev/null &
		local pid=$!
		while kill -0 "$pid" 2>/dev/null; do
			for i in $(seq 0 10); do
				progress_bar $i 10
				sleep 0.1
			done
		done
		wait "$pid"
		progress_bar 10 10
		echo
		log_ok "Repository cloned"
	fi

	export CORE_DATA
}

create_symlink() {
	log_step 4 "Creating core command"

	rm -f "$PREFIX/bin/core"
	ln -sf "$CORE_DATA/core/bin/core" "$PREFIX/bin/core"

	if [[ -L "$PREFIX/bin/core" ]]; then
		log_ok "Symlink created: core → ${CORE_DATA}/core/bin/core"
	else
		log_fail "Failed to create symlink"
		return 1
	fi
}

save_config() {
	log_step 5 "Saving configuration"

	cat >"$CORE_CONFIG/config" <<EOF
core_data='$CORE_DATA'
core_cache='$CORE_CACHE'
core_config='$CORE_CONFIG'
core_source='$CORE_DATA'
core_tool_data='$CORE_TOOL_DATA'
EOF

	log_ok "Configuration saved"
}

show_final_message() {
	echo
	separator
	echo -e "${GREEN}  Core-Termux installed successfully!${NC}"
	separator
	echo
	echo -e "  ${CYAN}Next steps:${NC}"
	echo
	echo -e "  ${GREEN}1.${NC} Run: ${CYAN}core${NC}"
	echo -e "  ${GREEN}2.${NC} Run: ${CYAN}core setup full${NC} (recommended)"
	echo
	echo -e "  ${YELLOW}Or install individually:${NC}"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install language" "Programming languages"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install db" "Databases"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install ai" "AI tools"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install editor" "Code editor"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install tools" "Dev tools"
  printf "    ${CYAN}%-20s${NC} %s\n" "core install node" "Node.js tools"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install shell" "ZSH shell"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install ui" "Termux UI"
	printf "    ${CYAN}%-20s${NC} %s\n" "core install automation" "n8n"
	echo
}

main() {
	banner
	echo
	install_dependencies
	setup_directories
	clone_repo
	create_symlink
	save_config
	show_final_message
}

main
