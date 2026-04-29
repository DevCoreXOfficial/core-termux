#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"

# Instalar herramientas de IA
install_ai() {
	separator
	box "Installing AI Tools"
	separator
	echo

	log_info "Installing AI tools..."
	echo
	log_info "☕ Grab a coffee! This process typically takes 15-30 minutes."
	log_info "   Don't worry, it's normal for this to take a while..."
	echo

	mkdir -p "$(dirname "$LOG_FILE")"

	# Instalar prerequisitos
	if loading "Installing AI prerequisites" _install_ai_prerequisites; then
		log_success "AI prerequisites installed"
	else
		log_warn "Some prerequisites may have failed"
	fi

	# Instalar herramientas de IA
	if loading "Installing AI tools" _install_ai_tools; then
		log_success "AI tools installed successfully"
		separator
		echo
		list_item "Qwen Code ${GRAY}(${D_GREEN}qwen${GRAY})"
		list_item "Gemini CLI ${GRAY}(${D_GREEN}gemini${GRAY})"
		list_item "Mistral Vibe ${GRAY}(${D_GREEN}vibe${GRAY})"
		list_item "OpenClaude ${GRAY}(${D_GREEN}openclaude${GRAY})"
		list_item "Claude Code ${GRAY}(${D_GREEN}claude${GRAY})"
		list_item "OpenClaw ${GRAY}(${D_GREEN}openclaw${GRAY})"
		list_item "Ollama ${GRAY}(${D_GREEN}ollama${GRAY})"
		list_item "Codex ${GRAY}(${D_GREEN}codex${GRAY})"
		list_item "OpenCode ${GRAY}(${D_GREEN}opencode${GRAY})"
		list_item "Engram ${GRAY}(${D_GREEN}engram${GRAY})"
		echo
	else
		log_error "Failed to install AI tools"
		log_warn "Check log file: $LOG_FILE"
		return 1
	fi
}

# Función interna para instalar prerequisitos
_install_ai_prerequisites() {
	# Actualizar repositorios e instalar dependencias del sistema
	pkg install nodejs-lts python git ripgrep clang make rust libffi openssl pkg-config ollama tur-repo udocker proot-distro golang sqlite -y &>>"$LOG_FILE"

	# Actualizar pip, setuptools y wheel para mistral-vibe
	pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
}

# Función interna para instalar herramientas
_install_ai_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24
	export GOPATH="$HOME/.local/go"
	export GOCACHE="$HOME/.cache/go"
	export GOMODCACHE="$GOPATH/pkg/mod"

	local has_changes=false

	# Qwen Code
	if command -v qwen &>/dev/null; then
		log_info "Qwen Code ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Qwen Code..."
		npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"
		has_changes=true
	fi

	# Gemini CLI
	if command -v gemini &>/dev/null; then
		log_info "Gemini CLI ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Gemini CLI..."
		npm install -g @google/gemini-cli &>>"$LOG_FILE"
		has_changes=true
	fi

	# Claude Code
	if command -v claude &>/dev/null; then
		log_info "Claude Code ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Claude Code..."
		npm install -g @anthropic-ai/claude-code &>>"$LOG_FILE"
		has_changes=true
	fi

	# Mistral Vibe
	if command -v vibe &>/dev/null; then
		log_info "Mistral Vibe ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Mistral Vibe..."
		pip install mistral-vibe &>>"$LOG_FILE"
		has_changes=true
	fi

	# OpenClaude
	if command -v openclaude &>/dev/null; then
		log_info "OpenClaude ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing OpenClaude..."
		npm install -g @gitlawb/openclaude &>>"$LOG_FILE"
		has_changes=true
	fi

	# OpenClaw
	if command -v openclaw &>/dev/null; then
		log_info "OpenClaw ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing OpenClaw..."
		npm install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys openclaw@latest &>>"$LOG_FILE"
		has_changes=true
	fi

	# Ollama
	if command -v ollama &>/dev/null; then
		log_info "Ollama ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Ollama..."
		pkg install ollama -y &>>"$LOG_FILE"
		has_changes=true
	fi

	# Codex
	if command -v codex &>/dev/null; then
		log_info "Codex ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Codex..."
		pkg install codex -y &>>"$LOG_FILE"
		has_changes=true
	fi

	# OpenCode
	if command -v opencode &>/dev/null; then
		log_info "OpenCode ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing OpenCode..."

		if [ ! -d ~/.opencode ]; then
			mkdir -p ~/.opencode &>>"$LOG_FILE"
		fi

		LATEST_VERSION=$(curl -sI https://github.com/anomalyco/opencode/releases/latest | grep -i location | sed -E 's#.*/tag/([^[:space:]]+).*#\1#')
		TAR_NAME="opencode-linux-arm64-musl.tar.gz"
		REPO="https://github.com/anomalyco/opencode/releases/download/$LATEST_VERSION/$TAR_NAME"
		ALPINE_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/alpine"

		if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/alpine" ]; then
			proot-distro install alpine &>>"$LOG_FILE"
		fi

		proot-distro login alpine --shared-tmp -- /bin/ash -c 'apk update && apk upgrade && apk add --no-cache musl ca-certificates libstdc++ libgcc gcompat' &>>"$LOG_FILE"

		curl -L $REPO -o $TMPDIR/$TAR_NAME &>>"$LOG_FILE"

		tar -zxf $TMPDIR/$TAR_NAME -C $ALPINE_ROOT/bin

		rm $TMPDIR/$TAR_NAME

		chmod +x $ALPINE_ROOT/bin/opencode

		cat <<'EOF' >"$PREFIX/bin/opencode"
#!/bin/bash

EXCLUDE_REGEX="^(PATH|LD_PRELOAD|LD_LIBRARY_PATH|PREFIX|HOME|PWD|OLDPWD|SHELL|IFS|_|SHLVL|PROMPT_COMMAND|TERMCAP|LS_COLORS|TERM)="

ENV_ARGS=()
      while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ $EXCLUDE_REGEX ]]; then
                ENV_ARGS+=("--env" "$line")
        fi
done < <(env)

ENV_ARGS+=(                                                        "--env" "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
        "--env" "TERM=$TERM"
        "--env" "HOME=/root"
)

unset LD_PRELOAD
proot-distro login \
        "${ENV_ARGS[@]}" \
        --termux-home \
        --shared-tmp \
        --work-dir $PWD \
        alpine \
        -- /bin/opencode "$@"
EOF

		chmod +x "$PREFIX/bin/opencode" &>>"$LOG_FILE"

		has_changes=true
	fi

	# Engram
	if command -v engram &>/dev/null; then
		log_info "Engram ${D_GREEN}already installed${D_NC}"
	else
		log_info "Installing Engram..."
		git clone https://github.com/Gentleman-Programming/engram ~/.cache/core-termux/engram &>>"$LOG_FILE"
		go build -C ~/.cache/core-termux/engram/cmd/engram -o $PREFIX/bin/engram &>>"$LOG_FILE"
		has_changes=true
	fi
	# Return success even if nothing was installed (all already present)
	return 0
}

# Desinstalar herramientas de IA
uninstall_ai() {
	separator
	box "Uninstalling AI Tools"
	separator
	echo

	log_info "Uninstalling AI tools..."

	if loading "Uninstalling AI tools" _uninstall_ai_tools; then
		log_success "AI tools uninstalled"
	else
		log_error "Failed to uninstall AI tools"
		return 1
	fi
}

# Función interna para desinstalar
_uninstall_ai_tools() {
	# qwen-code gemini-cli claude-code openclaude
	npm uninstall -g @qwen-code/qwen-code @google/gemini-cli @anthropic-ai/claude-code openclaw @gitlawb/openclaude &>"$LOG_FILE"

	# openclaw
	npm uninstall -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

	# mistral-vibe
	pip uninstall mistral-vibe -y &>>"$LOG_FILE"

	# codex
	pkg uninstall codex -y &>>"$LOG_FILE"

	# opencode
	proot-distro remove alpine &>>"$LOG_FILE"
	rm "$PREFIX/bin/opencode" &>>"$LOG_FILE"

	# engram
	rm -rf ~/.cache/core-termux/engram && rm "$PREFIX/bin/engram" &>>"$LOG_FILE"
}

# Actualizar herramientas de IA
update_ai() {
	separator
	box "Updating AI Tools"
	separator
	echo

	log_info "Updating AI tools..."

	if loading "Updating AI tools" _update_ai_tools; then
		log_success "AI tools updated"
	else
		log_error "Failed to update AI tools"
		return 1
	fi
}

# Función interna para actualizar
_update_ai_tools() {
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24
	export GOPATH="$HOME/.local/go"
	export GOCACHE="$HOME/.cache/go"
	export GOMODCACHE="$GOPATH/pkg/mod"

	# qwen-code gemini-cli claude-code openclaude
	npm update -g @qwen-code/qwen-code @google/gemini-cli @anthropic-ai/claude-code openclaw @gitlawb/openclaude &>>"$LOG_FILE"

	# openclaw
	npm update -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

	# mistral-vibe
	pip install --upgrade mistral-vibe &>>"$LOG_FILE"

	# ollama
	pkg upgrade ollama -y &>>"$LOG_FILE"

	# codex
	pkg upgrade codex -y &>>"$LOG_FILE"

	# opencode
	LATEST_VERSION=$(curl -sI https://github.com/anomalyco/opencode/releases/latest | grep -i location | sed -E 's#.*/tag/([^[:space:]]+).*#\1#')
	TAR_NAME="opencode-linux-arm64-musl.tar.gz"
	REPO="https://github.com/anomalyco/opencode/releases/download/$LATEST_VERSION/$TAR_NAME"
	ALPINE_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/alpine"

	rm $ALPINE_ROOT/bin/opencode
	curl -L $REPO -o $TMPDIR/$TAR_NAME &>>"$LOG_FILE"
	tar -zxf $TMPDIR/$TAR_NAME -C $ALPINE_ROOT/bin
	rm $TMPDIR/$TAR_NAME
	chmod +x $ALPINE_ROOT/bin/opencode

	# engram
	git -C ~/.cache/core-termux/engram pull &>>"$LOG_FILE"
	go build -C ~/.cache/core-termux/engram/cmd/engram -o $PREFIX/bin/engram &>>"$LOG_FILE"
}
