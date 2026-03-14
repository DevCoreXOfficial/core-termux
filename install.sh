#!/bin/bash

set -e

# Colores básicos (sin importar logs aún)
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
NC='\e[0m'

REPO="https://github.com/DevCoreXOfficial/core-termux"
BRANCH="main"
CORE_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/core-termux"
CORE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/core-termux"
CORE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/core-termux"

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║     Core-Termux Installer            ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# Función de log básico
log() {
	echo -e "    ${CYAN}➜${NC} $1"
}

success() {
	echo -e "    ${GREEN}✔${NC} $1"
}

error() {
	echo -e "    ${RED}✖${NC} $1" >&2
}

warn() {
	echo -e "    ${YELLOW}⚠${NC} $1"
}

# Instalar dependencias requeridas
install_dependencies() {
	log "Installing required dependencies..."
	pkg install -y git ncurses-utils &>/dev/null
	success "Dependencies installed (git, ncurses-utils)"
}

# Crear directorios necesarios
setup_directories() {
	log "Creating directories..."
	mkdir -p "$CORE_DATA" "$CORE_CACHE" "$CORE_CONFIG"
	success "Directories created"
}

# Clonar o actualizar repositorio
# Detecta si es instalación de dev (repo local) o usuario (curl | bash)
clone_repo() {
	log "Setting up Core-Termux repository..."

	# Detectar si se está ejecutando desde el repo de desarrollo
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local is_dev_install=0

	# Si el script está en un repo git y NO está en CORE_DATA, es instalación de dev
	if [[ -d "$script_dir/.git" ]] && [[ "$script_dir" != "$CORE_DATA" ]]; then
		is_dev_install=1
	fi

	if [[ $is_dev_install -eq 1 ]]; then
		# Instalación de desarrollador: usar el repo local existente
		log "Developer installation detected, using local repository..."
		CORE_DATA="$script_dir"
		success "Using local repository: $CORE_DATA"
	else
		# Instalación de usuario: clonar o actualizar
		if [[ -d "$CORE_DATA/.git" ]]; then
			git -C "$CORE_DATA" pull origin "$BRANCH" &>/dev/null
			success "Repository updated"
		else
			git clone --depth=1 -b "$BRANCH" "$REPO" "$CORE_DATA" &>/dev/null
			success "Repository cloned"
		fi
	fi

	# Exportar CORE_DATA para que lo usen las demás funciones
	export CORE_DATA
}

# Crear symlink del comando core
create_symlink() {
	log "Creating core command symlink..."

	# Eliminar symlink anterior si existe
	rm -f "$PREFIX/bin/core"

	# Crear nuevo symlink apuntando a $CORE_DATA/core/bin/core
	ln -sf "$CORE_DATA/core/bin/core" "$PREFIX/bin/core"

	if [[ -x "$PREFIX/bin/core" ]] || [[ -L "$PREFIX/bin/core" ]]; then
		success "Symlink created: $PREFIX/bin/core"
	else
		error "Failed to create symlink"
		return 1
	fi
}

# Guardar configuración de instalación
save_config() {
	log "Saving configuration..."

	cat >"$CORE_CONFIG/config" <<EOF
core_data='$CORE_DATA'
core_cache='$CORE_CACHE'
core_config='$CORE_CONFIG'
core_source='$CORE_DATA'
EOF

	success "Configuration saved"
}

# Mostrar mensaje final
show_final_message() {
	echo
	echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
	echo -e "${GREEN}║  Core installed successfully!        ║${NC}"
	echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
	echo
	echo -e "${CYAN}Next steps:${NC}"
	echo
	echo -e "  1. Run: ${GREEN}core${NC}"
	echo -e "  2. Run: ${GREEN}core setup full${NC} (recommended)"
	echo
	echo -e "${YELLOW}Or install modules individually:${NC}"
	echo -e "  core install language"
	echo -e "  core install db"
	echo -e "  core install ai"
	echo -e "  core install editor"
	echo -e "  core install tools"
	echo -e "  core install shell"
	echo -e "  core install ui"
	echo
}

# Main
main() {
	install_dependencies
	setup_directories
	clone_repo
	create_symlink
	save_config
	show_final_message
}

main
