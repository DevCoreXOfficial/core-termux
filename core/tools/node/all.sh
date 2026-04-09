#!/bin/bash

import "@/utils/log"
import "@/fix/localtunnel"

LOG_FILE="$CORE_CACHE/install_node_modules.log"

# ===== TYPESCRIPT=====
install_typescript() {
	if command -v tsc &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript installed"
		return 0
	else
		log_error "Failed to install TypeScript"
		return 1
	fi
}

uninstall_typescript() {
	log_info "Uninstalling TypeScript..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript uninstalled"
		return 0
	else
		log_error "Failed to uninstall TypeScript"
		return 1
	fi
}

update_typescript() {
	log_info "Updating TypeScript..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g typescript &>>"$LOG_FILE"; then
		log_success "TypeScript updated"
		return 0
	else
		log_error "Failed to update TypeScript"
		return 1
	fi
}

# ===== NESTJS CLI =====
install_nestjs() {
	if command -v nest &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI installed"
		return 0
	else
		log_error "Failed to install NestJS CLI"
		return 1
	fi
}

uninstall_nestjs() {
	log_info "Uninstalling NestJS CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall NestJS CLI"
		return 1
	fi
}

update_nestjs() {
	log_info "Updating NestJS CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g @nestjs/cli &>>"$LOG_FILE"; then
		log_success "NestJS CLI updated"
		return 0
	else
		log_error "Failed to update NestJS CLI"
		return 1
	fi
}

# ===== PRETTIER =====
install_prettier() {
	if command -v prettier &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier installed"
		return 0
	else
		log_error "Failed to install Prettier"
		return 1
	fi
}

uninstall_prettier() {
	log_info "Uninstalling Prettier..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier uninstalled"
		return 0
	else
		log_error "Failed to uninstall Prettier"
		return 1
	fi
}

update_prettier() {
	log_info "Updating Prettier..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g prettier &>>"$LOG_FILE"; then
		log_success "Prettier updated"
		return 0
	else
		log_error "Failed to update Prettier"
		return 1
	fi
}

# ===== LIVE SERVER =====
install_live_server() {
	if command -v live-server &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server installed"
		return 0
	else
		log_error "Failed to install Live Server"
		return 1
	fi
}

uninstall_live_server() {
	log_info "Uninstalling Live Server..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server uninstalled"
		return 0
	else
		log_error "Failed to uninstall Live Server"
		return 1
	fi
}

update_live_server() {
	log_info "Updating Live Server..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g live-server &>>"$LOG_FILE"; then
		log_success "Live Server updated"
		return 0
	else
		log_error "Failed to update Live Server"
		return 1
	fi
}

# ===== LOCALTUNNEL =====
install_localtunnel() {
	if command -v lt &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel installed"
		log_info "Applying localtunnel fix for Android..."
		fix_localtunnel_openurl &>>"$LOG_FILE"
		return 0
	else
		log_error "Failed to install Localtunnel"
		return 1
	fi
}

uninstall_localtunnel() {
	log_info "Uninstalling Localtunnel..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel uninstalled"
		return 0
	else
		log_error "Failed to uninstall Localtunnel"
		return 1
	fi
}

update_localtunnel() {
	log_info "Updating Localtunnel..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g localtunnel &>>"$LOG_FILE"; then
		log_success "Localtunnel updated"
		return 0
	else
		log_error "Failed to update Localtunnel"
		return 1
	fi
}

# ===== VERCEL CLI =====
install_vercel() {
	if command -v vercel &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g vercel &>>"$LOG_FILE"; then
		log_success "Vercel CLI installed"
		return 0
	else
		log_error "Failed to install Vercel CLI"
		return 1
	fi
}

uninstall_vercel() {
	log_info "Uninstalling Vercel CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g vercel &>>"$LOG_FILE"; then
		log_success "Vercel CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall Vercel CLI"
		return 1
	fi
}

update_vercel() {
	log_info "Updating Vercel CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g vercel &>>"$LOG_FILE"; then
		log_success "Vercel CLI updated"
		return 0
	else
		log_error "Failed to update Vercel CLI"
		return 1
	fi
}

# ===== MARKSERV =====
install_markserv() {
	if command -v markserv &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv installed"
		return 0
	else
		log_error "Failed to install Markserv"
		return 1
	fi
}

uninstall_markserv() {
	log_info "Uninstalling Markserv..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv uninstalled"
		return 0
	else
		log_error "Failed to uninstall Markserv"
		return 1
	fi
}

update_markserv() {
	log_info "Updating Markserv..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g markserv &>>"$LOG_FILE"; then
		log_success "Markserv updated"
		return 0
	else
		log_error "Failed to update Markserv"
		return 1
	fi
}

# ===== PSQL FORMAT =====
install_psqlformat() {
	if command -v psqlformat &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format installed"
		return 0
	else
		log_error "Failed to install PSQL Format"
		return 1
	fi
}

uninstall_psqlformat() {
	log_info "Uninstalling PSQL Format..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format uninstalled"
		return 0
	else
		log_error "Failed to uninstall PSQL Format"
		return 1
	fi
}

update_psqlformat() {
	log_info "Updating PSQL Format..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g psqlformat &>>"$LOG_FILE"; then
		log_success "PSQL Format updated"
		return 0
	else
		log_error "Failed to update PSQL Format"
		return 1
	fi
}

# ===== NPM CHECK UPDATES =====
install_ncu() {
	if command -v ncu &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates installed"
		return 0
	else
		log_error "Failed to install NPM Check Updates"
		return 1
	fi
}

uninstall_ncu() {
	log_info "Uninstalling NPM Check Updates..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates uninstalled"
		return 0
	else
		log_error "Failed to uninstall NPM Check Updates"
		return 1
	fi
}

update_ncu() {
	log_info "Updating NPM Check Updates..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g npm-check-updates &>>"$LOG_FILE"; then
		log_success "NPM Check Updates updated"
		return 0
	else
		log_error "Failed to update NPM Check Updates"
		return 1
	fi
}

# ===== NGROK =====
install_ngrok() {
	if command -v ngrok &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if npm install -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok installed"
		return 0
	else
		log_error "Failed to install Ngrok"
		return 1
	fi
}

uninstall_ngrok() {
	log_info "Uninstalling Ngrok..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ngrok"
		return 1
	fi
}

update_ngrok() {
	log_info "Updating Ngrok..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm update -g ngrok &>>"$LOG_FILE"; then
		log_success "Ngrok updated"
		return 0
	else
		log_error "Failed to update Ngrok"
		return 1
	fi
}
