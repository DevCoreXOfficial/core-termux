#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_tools.log"

# Paquetes de herramientas
TOOLS_PACKAGES=(
	"gh"
	"wget"
	"curl"
	"lsd"
	"bat"
	"proot"
	"ncurses-utils"
	"tmate"
	"cloudflared"
	"translate-shell"
	"html2text"
	"jq"
	"bc"
	"tree"
	"fzf"
	"imagemagick"
	"shfmt"
	"make"
)

# Instalar herramientas
install_tools() {
	separator
	box "Installing Development Tools"
	separator
	echo

	log_info "Installing development tools..."

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Installing tools" _install_tools_packages; then
		log_success "Tools installed successfully"
		separator
		echo
		list_item "GitHub CLI"
		list_item "Wget"
		list_item "Curl"
		list_item "LSD (ls replacement)"
		list_item "Bat (cat replacement)"
		list_item "Proot (chroot alternative)"
		list_item "Ncurses Utils"
		list_item "Tmate (terminal sharing)"
		list_item "Cloudflared (Cloudflare Tunnel)"
		list_item "Translate Shell"
		list_item "html2text (HTML to text converter)"
		list_item "jq (JSON processor)"
		list_item "bc (calculator)"
		list_item "Tree (directory listing)"
		list_item "Fzf (fuzzy finder)"
		list_item "ImageMagick (image manipulation)"
		list_item "Shfmt (shell script formatter)"
		list_item "Make (build automation)"
		echo
	else
		log_error "Failed to install tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar
_install_tools_packages() {
	pkg install "${TOOLS_PACKAGES[@]}" -y &>"$LOG_FILE"
}

# Desinstalar herramientas
uninstall_tools() {
	separator
	box "Uninstalling Development Tools"
	separator
	echo

	log_info "Uninstalling development tools..."

	if loading "Uninstalling tools" _uninstall_tools_packages; then
		log_success "Tools uninstalled"
	else
		log_error "Failed to uninstall tools"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_tools_packages() {
	pkg uninstall "${TOOLS_PACKAGES[@]}" -y &>"$LOG_FILE"
}

# Actualizar herramientas
update_tools() {
	separator
	box "Updating Development Tools"
	separator
	echo

	log_info "Updating development tools..."

	if loading "Updating tools" _update_tools_packages; then
		log_success "Tools updated"
	else
		log_error "Failed to update tools"
		return 1
	fi
}

# Función interna para actualizar
_update_tools_packages() {
	pkg upgrade "${TOOLS_PACKAGES[@]}" -y &>"$LOG_FILE"
}
