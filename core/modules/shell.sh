#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

# Variables globales
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
LOG_FILE="$CORE_CACHE/install_shell.log"

# Instalar zsh y zoxide en Termux
install_termux_packages() {
	log_info "Installing zsh and zoxide in Termux..."

	if pkg install -y zsh zoxide &>>"$LOG_FILE"; then
		log_success "zsh and zoxide installed successfully"
		return 0
	else
		log_error "Failed to install zsh and zoxide"
		return 1
	fi
}

# Instalar Oh My Zsh
install_oh_my_zsh() {
	if [[ -d "$OH_MY_ZSH_DIR" ]]; then
		log_warn "Oh My Zsh already installed"
		return 0
	fi

	log_info "Downloading Oh My Zsh..."
	log_info "When prompted, enter (Y/n) to set ZSH as your default shell"
	echo

	# Usar $PREFIX/tmp en Termux (compatible con Android)
	local temp_dir="${PREFIX:-/tmp}/tmp"
	mkdir -p "$temp_dir"
	local temp_file="$temp_dir/omz_install.sh"

	if curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$temp_file" &>>"$LOG_FILE"; then
		sed -i '/exec zsh -l/s/^/#/' "$temp_file"
		sh "$temp_file" &>>"$LOG_FILE"
		rm "$temp_file"
		log_success "Oh My Zsh installed successfully"
		return 0
	else
		log_error "Failed to download Oh My Zsh"
		return 1
	fi
}

# Crear directorio de plugins ZSH
setup_zsh_plugins_dir() {
	if [[ ! -d "$ZSH_PLUGINS_DIR" ]]; then
		mkdir -p "$ZSH_PLUGINS_DIR"
		log_info "Created zsh-plugins directory: $ZSH_PLUGINS_DIR"
	fi
}

# Clonar plugin con manejo de errores
clone_plugin() {
	local repo="$1"
	local name="$2"
	local target="$ZSH_PLUGINS_DIR/$name"

	if [[ -d "$target" ]]; then
		log_warn "Plugin '$name' already exists, skipping..."
		return 0
	fi

	if git clone --depth=1 "$repo" "$target" &>>"$LOG_FILE"; then
		log_success "Cloned plugin: $name"
		return 0
	else
		log_error "Failed to clone plugin: $name"
		return 1
	fi
}

# Agregar línea al .zshrc si no existe
add_to_zshrc() {
	local line="$1"
	if ! grep -qxF "$line" ~/.zshrc 2>/dev/null; then
		echo "$line" >>~/.zshrc
	fi
}

# Instalar todos los plugins ZSH
install_zsh_plugins() {
	setup_zsh_plugins_dir

	log_info "Installing ZSH plugins..."

	# zsh-defer
	clone_plugin "https://github.com/romkatv/zsh-defer.git" "zsh-defer"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh'

	# powerlevel10k
	clone_plugin "https://github.com/romkatv/powerlevel10k.git" "powerlevel10k"
	add_to_zshrc 'source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme'

	# zsh-autosuggestions
	clone_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

	# zsh-syntax-highlighting
	clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

	# zsh-history-substring-search
	clone_plugin "https://github.com/zsh-users/zsh-history-substring-search.git" "zsh-history-substring-search"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh'

	# Bindkeys para history-substring-search
	add_to_zshrc "bindkey '^[[A' history-substring-search-up"
	add_to_zshrc "bindkey '^[[B' history-substring-search-down"

	# zsh-completions
	clone_plugin "https://github.com/zsh-users/zsh-completions.git" "zsh-completions"
	add_to_zshrc 'fpath+=~/.zsh-plugins/zsh-completions'

	# fzf-tab
	clone_plugin "https://github.com/Aloxaf/fzf-tab.git" "fzf-tab"
	add_to_zshrc 'source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh'

	# Configuración de fzf-tab
	add_to_zshrc "zstyle ':completion:*' menu-select yes"
	add_to_zshrc "zstyle ':fzf-tab:*' switch-word yes"

	# zsh-you-should-use
	clone_plugin "https://github.com/MichaelAquilina/zsh-you-should-use.git" "zsh-you-should-use"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-you-should-use/you-should-use.plugin.zsh'

	# zsh-autopair
	clone_plugin "https://github.com/hlissner/zsh-autopair.git" "zsh-autopair"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-autopair/autopair.zsh'

	# zsh-better-npm-completion
	clone_plugin "https://github.com/lukechilds/zsh-better-npm-completion.git" "zsh-better-npm-completion"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh'

	# zsh-autocomplete
	clone_plugin "https://github.com/marlonrichert/zsh-autocomplete.git" "zsh-autocomplete"
	add_to_zshrc 'source ~/.zsh-plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh'

	log_success "All ZSH plugins installed"
}

# Configurar aliases básicos
setup_zsh_aliases() {
	log_info "Setting up ZSH aliases..."

	add_to_zshrc "alias ls=\"lsd\""
	add_to_zshrc 'alias cat="bat --theme=Dracula --style=plain --paging=never"'
	add_to_zshrc 'eval "$(zoxide init zsh)"'

	log_success "ZSH aliases configured"
}

# Configurar sesión persistente (guardar directorio)
setupPersistentSession() {
	log_info "Configuring persistent session..."

	# Crear directorio de caché si no existe
	mkdir -p "$CORE_CACHE" 2>/dev/null || mkdir -p ~/.cache/core-termux

	# Guardar directorio inicial (home por defecto)
	echo "$HOME" > ~/.cache/core-termux/last_dir

	# Verificar si el código ya existe (idempotencia)
	if grep -q "# ===== Persistent Directory =====" ~/.zshrc 2>/dev/null; then
		log_warn "Persistent session already configured"
		return 0
	fi

	# Agregar código de sesión persistente
	cat >>~/.zshrc <<'EOF'

# ===== Persistent Directory =====
# Solo restaura directorio en nuevas sesiones dentro de Termux (no al abrir Termux desde cero)
# Usa timestamp para detectar si Termux fue cerrado completamente

LAST_DIR_FILE="$HOME/.cache/core-termux/last_dir"
SESSION_TIMESTAMP="$HOME/.cache/core-termux/.session_time"
SESSION_TIMEOUT=5  # Segundos para considerar que Termux fue reiniciado

save_dir() {
  mkdir -p ~/.cache/core-termux 2>/dev/null
  pwd > "$LAST_DIR_FILE"
  # Actualizar timestamp de sesión activa
  date +%s > "$SESSION_TIMESTAMP"
}

restore_dir() {
  # Si existe el timestamp y es reciente (< SESSION_TIMEOUT segundos), es nueva sesión
  if [[ -f "$SESSION_TIMESTAMP" ]] && [[ -f "$LAST_DIR_FILE" ]]; then
    local current_time
    local last_time
    current_time=$(date +%s)
    last_time=$(cat "$SESSION_TIMESTAMP" 2>/dev/null || echo 0)
    local diff=$((current_time - last_time))

    if [[ $diff -lt $SESSION_TIMEOUT ]]; then
      # Sesión activa: restaurar directorio en nueva shell
      local dir
      dir=$(cat "$LAST_DIR_FILE" 2>/dev/null)
      if [[ -d "$dir" ]] && [[ "$dir" != "$HOME" ]]; then
        cd "$dir" 2>/dev/null
      fi
    fi
    # Si diff >= SESSION_TIMEOUT, Termux fue cerrado y abierto de nuevo -> home
  fi
  # Actualizar timestamp para esta sesión
  date +%s > "$SESSION_TIMESTAMP"
}

# Hooks para guardar/restaurar
if typeset -f add-zsh-hook &>/dev/null; then
  # Oh My Zsh disponible
  add-zsh-hook precmd save_dir
  restore_dir  # Restaurar inmediatamente al cargar .zshrc
else
  # Fallback nativo de Zsh
  restore_dir  # Restaurar inmediatamente
  trap 'save_dir' EXIT  # Guardar al salir
fi
EOF

	log_success "Persistent session configured"
	log_info "New sessions within Termux will restore last directory"
	log_info "Opening Termux from scratch will start in home"
	log_info "Cache location: ~/.cache/core-termux"
}

# Instalar shell
install_shell() {
	separator
	box "Installing ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar paquetes base en Termux
	if loading "Installing zsh and zoxide" install_termux_packages; then
		log_success "Base packages installed"
	else
		log_error "Failed to install base packages"
	fi
	echo

	# Instalar Oh My Zsh
	install_oh_my_zsh
	echo

	# Instalar plugins
	if loading "Installing ZSH plugins" install_zsh_plugins; then
		log_success "ZSH plugins installed"
	else
		log_error "Failed to install ZSH plugins"
	fi
	echo

	# Configurar aliases
	setup_zsh_aliases
	echo

	# Configurar sesión persistente
	setupPersistentSession
	echo

	separator
	log_success "ZSH shell environment setup completed"
	separator
	echo
	log_warn "Please restart Termux or run: exec zsh"
	echo
}

# Desinstalar Oh My Zsh
uninstall_oh_my_zsh() {
	if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
		log_warn "Oh My Zsh not installed"
		return 0
	fi

	log_info "Uninstalling Oh My Zsh..."

	if rm -rf "$OH_MY_ZSH_DIR" &>>"$LOG_FILE"; then
		log_success "Oh My Zsh uninstalled"
	else
		log_error "Failed to uninstall Oh My Zsh"
		return 1
	fi
}

# Desinstalar plugins ZSH
uninstall_zsh_plugins() {
	if [[ ! -d "$ZSH_PLUGINS_DIR" ]]; then
		log_warn "ZSH plugins directory not found"
		return 0
	fi

	log_info "Uninstalling ZSH plugins..."

	if rm -rf "$ZSH_PLUGINS_DIR" &>>"$LOG_FILE"; then
		log_success "ZSH plugins uninstalled"
	else
		log_error "Failed to uninstall ZSH plugins"
		return 1
	fi
}

# Desinstalar shell
uninstall_shell() {
	separator
	box "Uninstalling ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	uninstall_oh_my_zsh
	uninstall_zsh_plugins

	echo
	separator
	log_success "ZSH shell environment uninstalled"
	separator
	echo
}

# Actualizar plugins ZSH
update_zsh_plugins() {
	log_info "Updating ZSH plugins..."

	for plugin_dir in "$ZSH_PLUGINS_DIR"/*/; do
		if [[ -d "$plugin_dir/.git" ]]; then
			git -C "$plugin_dir" pull &>>"$LOG_FILE"
		fi
	done

	log_success "ZSH plugins updated"
}

# Actualizar shell
update_shell() {
	separator
	box "Updating ZSH Shell Environment"
	separator
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	if loading "Updating ZSH plugins" update_zsh_plugins; then
		log_success "ZSH shell environment updated"
	else
		log_error "Failed to update ZSH plugins"
	fi

	echo
	separator
	log_success "ZSH update completed"
	separator
	echo
}
