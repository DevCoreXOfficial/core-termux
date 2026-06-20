#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

install_clang() {
	if command -v clang &>/dev/null; then
		log_info "C/C++ (Clang) is already installed"
		return 2
	fi
	log_info "Installing C/C++ (Clang)..."

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install clang -y &>>"$LOG_FILE"; then
		log_success "C/C++ (Clang) installed"
		return 0
	else
		return 1
	fi
}

uninstall_clang() {
	if ! command -v clang &>/dev/null; then
		log_info "C/C++ (Clang) is not installed"
		return 2
	fi
	log_info "Uninstalling C/C++ (Clang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall clang -y &>>"$LOG_FILE"; then
		log_success "C/C++ (clang) uninstalled"
		return 0
	else
		log_error "Failed to uninstall C/C++ (clang)"
		return 1
	fi
}

update_clang() {
	log_info "Updating C/C++ (Clang)..."
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade clang -y &>>"$LOG_FILE"; then
		log_success "C/C++ (clang) updated"
		return 0
	else
		log_error "Failed to update C/C++ (clang)"
		return 1
	fi
}

reinstall_clang() {
	uninstall_clang
	install_clang
}