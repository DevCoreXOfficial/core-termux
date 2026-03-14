#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

# Directorios de configuración de Termux
TERMUX_DIR="$HOME/.termux"
TERMUX_ASSETS_DIR="$(dirname "$CORE_PATH")/assets"
LOG_FILE="$CORE_CACHE/install_ui.log"

# Configurar extra-keys para Termux
setup_extra_keys() {
	log_info "Configuring Termux extra-keys..."

	cat >"$TERMUX_DIR/termux.properties" <<'EOF'
terminal-cursor-blink-rate=500

extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]
EOF

	log_success "Extra-keys configured"
}

# Configurar color del cursor
setup_cursor_color() {
	log_info "Configuring cursor color..."

	cat >"$TERMUX_DIR/colors.properties" <<'EOF'
cursor=#00FF00
EOF

	log_success "Cursor color set to #00FF00 (green)"
}

# Instalar fuente Meslo Nerd Font
setup_font() {
	log_info "Installing Meslo Nerd Font..."

	local font_source="$(dirname "$CORE_PATH")/assets/fonts/font.ttf"
	local font_dest="$TERMUX_DIR/font.ttf"

	log_debug "Font source: $font_source"
	log_debug "Font dest: $font_dest"

	# Verificar si existe el directorio de assets
	if [[ ! -d "$(dirname "$font_source")" ]]; then
		mkdir -p "$(dirname "$font_source")"
	fi

	# Copiar la fuente al directorio de Termux
	if [[ -f "$font_source" ]]; then
		cp "$font_source" "$font_dest"
		log_success "Meslo Nerd Font installed"
	else
		log_warn "Font file not found at: $font_source"
		log_warn "Skipping font installation"
		return 1
	fi
}

# Aplicar configuración de Termux
apply_termux_config() {
	log_info "Applying Termux configuration..."

	# Recargar configuración de Termux
	if command -v termux-reload-settings &>/dev/null; then
		termux-reload-settings &>>"$LOG_FILE"
		log_success "Termux settings reloaded"
	else
		log_warn "termux-reload-settings not available"
	fi
}

# Mostrar información de configuración
show_config_info() {
	echo
	box "Termux UI Configuration"
	echo
	list_item "Cursor: Green (#00FF00)"
	list_item "Extra-keys: Custom layout with navigation"
	list_item "Font: Meslo Nerd Font"
	echo
}

# Función principal para configurar UI
setup_ui() {
	separator
	box "Configuring Termux UI"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	# Crear directorio de Termux si no existe
	if [[ ! -d "$TERMUX_DIR" ]]; then
		mkdir -p "$TERMUX_DIR"
		log_info "Created Termux directory: $TERMUX_DIR"
	fi

	# Configurar extra-keys
	setup_extra_keys

	# Configurar cursor
	setup_cursor_color

	# Instalar fuente
	setup_font

	# Mostrar información
	show_config_info

	separator
	log_success "Termux UI configuration completed"
	separator
	echo
	log_warn "Please restart Termux to apply all changes"
	echo
}

# Restaurar configuración por defecto
restore_ui_default() {
	log_info "Restoring Termux UI to default..."

	# Eliminar archivos de configuración
	if [[ -f "$TERMUX_DIR/termux.properties" ]]; then
		rm "$TERMUX_DIR/termux.properties"
		log_success "Extra-keys restored to default"
	fi

	if [[ -f "$TERMUX_DIR/colors.properties" ]]; then
		rm "$TERMUX_DIR/colors.properties"
		log_success "Cursor color restored to default"
	fi

	if [[ -f "$TERMUX_DIR/font.ttf" ]]; then
		rm "$TERMUX_DIR/font.ttf"
		log_success "Font restored to default"
	fi

	log_success "Termux UI restored to default"
}

# Desinstalar UI
uninstall_ui() {
	separator
	box "Uninstalling Termux UI Configuration"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	restore_ui_default

	echo
	separator
	log_success "Termux UI configuration uninstalled"
	separator
	echo
	log_warn "Please restart Termux to apply changes"
	echo
}

# Actualizar UI (re-aplicar configuración)
update_ui() {
	separator
	box "Updating Termux UI Configuration"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	setup_ui

	echo
	separator
	log_success "Termux UI configuration updated"
	separator
	echo
}
