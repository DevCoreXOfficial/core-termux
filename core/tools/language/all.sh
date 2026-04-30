#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_language.log"

# ===== NODEJS LTS =====
install_nodejs() {
	if dpkg -s nodejs-lts 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install nodejs-lts -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_nodejs() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS uninstalled"
		return 0
	else
		log_error "Failed to uninstall Node.js LTS"
		return 1
	fi
}

update_nodejs() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade nodejs-lts -y &>>"$LOG_FILE"; then
		log_success "Node.js LTS updated"
		return 0
	else
		log_error "Failed to update Node.js LTS"
		return 1
	fi
}

# ===== PYTHON =====
install_python() {
	if dpkg -s python 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install python -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_python() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall python -y &>>"$LOG_FILE"; then
		log_success "Python uninstalled"
		return 0
	else
		log_error "Failed to uninstall Python"
		return 1
	fi
}

update_python() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade python -y &>>"$LOG_FILE"; then
		log_success "Python updated"
		return 0
	else
		log_error "Failed to update Python"
		return 1
	fi
}

# ===== PERL =====
install_perl() {
	if dpkg -s perl 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install perl -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_perl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall perl -y &>>"$LOG_FILE"; then
		log_success "Perl uninstalled"
		return 0
	else
		log_error "Failed to uninstall Perl"
		return 1
	fi
}

update_perl() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade perl -y &>>"$LOG_FILE"; then
		log_success "Perl updated"
		return 0
	else
		log_error "Failed to update Perl"
		return 1
	fi
}

# ===== PHP =====
install_php() {
	if dpkg -s php 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install php -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_php() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall php -y &>>"$LOG_FILE"; then
		log_success "PHP uninstalled"
		return 0
	else
		log_error "Failed to uninstall PHP"
		return 1
	fi
}

update_php() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade php -y &>>"$LOG_FILE"; then
		log_success "PHP updated"
		return 0
	else
		log_error "Failed to update PHP"
		return 1
	fi
}

# ===== RUST =====
install_rust() {
	if dpkg -s rust 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install rust -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_rust() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall rust -y &>>"$LOG_FILE"; then
		log_success "Rust uninstalled"
		return 0
	else
		log_error "Failed to uninstall Rust"
		return 1
	fi
}

update_rust() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade rust -y &>>"$LOG_FILE"; then
		log_success "Rust updated"
		return 0
	else
		log_error "Failed to update Rust"
		return 1
	fi
}

# ===== CLANG (C/C++) =====
install_clang() {
	if dpkg -s clang 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install clang -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_clang() {
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
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade clang -y &>>"$LOG_FILE"; then
		log_success "C/C++ (clang) updated"
		return 0
	else
		log_error "Failed to update C/C++ (clang)"
		return 1
	fi
}

# ===== GO (GOLANG) =====
install_golang() {
	if dpkg -s golang 2>/dev/null | grep -q "Status: install ok installed"; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg install golang -y &>>"$LOG_FILE"; then
		return 0
	else
		return 1
	fi
}

uninstall_golang() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg uninstall golang -y &>>"$LOG_FILE"; then
		log_success "Go (golang) uninstalled"
		return 0
	else
		log_error "Failed to uninstall Go (golang)"
		return 1
	fi
}

update_golang() {
	mkdir -p "$(dirname "$LOG_FILE")"
	if pkg upgrade golang -y &>>"$LOG_FILE"; then
		log_success "Go (golang) updated"
		return 0
	else
		log_error "Failed to update Go (golang)"
		return 1
	fi
}
