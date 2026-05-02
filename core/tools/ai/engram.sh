#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_engram() {
	if command -v engram &>/dev/null; then
		return 0
	fi

	export GOPATH="$HOME/.local/go"
	export GOCACHE="$HOME/.cache/go"
	export GOMODCACHE="$GOPATH/pkg/mod"

	pkg install golang git sqlite -y &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"

	if git clone https://github.com/Gentleman-Programming/engram ~/.cache/core-termux/engram && go build -C ~/.cache/core-termux/engram/cmd/engram -o $PREFIX/bin/engram &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Engram"
		return 1
	fi
}

uninstall_engram() {
	log_info "Uninstalling Engram..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if rm -rf ~/.cache/core-termux/engram && rm "$PREFIX/bin/engram" &>>"$LOG_FILE"; then
		log_success "Engram uninstalled"
		return 0
	else
		log_error "Failed to uninstall Engram"
		return 1
	fi
}

update_engram() {
	log_info "Updating Engram..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GOPATH="$HOME/.local/go"
	export GOCACHE="$HOME/.cache/go"
	export GOMODCACHE="$GOPATH/pkg/mod"

	if git -C ~/.cache/core-termux/engram pull &>>"$LOG_FILE" && go build -C ~/.cache/core-termux/engram/cmd/engram -o $PREFIX/bin/engram &>>"$LOG_FILE"; then
		log_success "Engram updated"
		return 0
	else
		log_error "Failed to update Engram"
		return 1
	fi
}