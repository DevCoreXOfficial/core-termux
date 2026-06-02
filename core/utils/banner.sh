#!/data/data/com.termux/files/usr/bin/bash

BANNER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BANNER_FILE="$(cd "$BANNER_SCRIPT_DIR/../.." && pwd)/assets/banner/devcorex.txt"
BANNER_VERSION="$(grep "^CORE_VERSION=" "$BANNER_SCRIPT_DIR/env.sh" 2>/dev/null | cut -d'"' -f2)"

DGREEN="\033[0;32m"
NC="\033[0m"
GRAY="\033[0;90m"

if [[ -f "$BANNER_FILE" ]]; then
	cat "$BANNER_FILE"
fi

if [[ -n "$BANNER_VERSION" ]]; then
  printf "\n"
	printf " ${GRAY}DevCoreX ${NC}Software Development Community${NC}\n"
	printf "     ${NC}Welcome to${GRAY} Core-Termux ${DGREEN}v%s${NC}\n" "$BANNER_VERSION"
	printf "        ${NC}Run ${DGREEN}core${NC} to get started${NC}\n"
fi
echo
