#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

# Prerequisites for npm-based AI tools (qwen, gemini, claude, openclaude, openclaw)
_install_ai_npm_prereqs() {
	if command -v node &>/dev/null && command -v npm &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install nodejs-lts git ripgrep -y &>>"$LOG_FILE"
}

# Prerequisites for pip-based AI tools (mistral-vibe)
_install_ai_pip_prereqs() {
	if command -v python &>/dev/null && command -v pip &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install python clang make rust libffi openssl pkg-config git ripgrep -y &>>"$LOG_FILE"
	pip install --upgrade pip setuptools wheel &>>"$LOG_FILE"
}

# ===== QWEN CODE =====
install_qwen_code() {
	if command -v qwen &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Qwen Code"
		return 1
	fi
}

uninstall_qwen_code() {
	log_info "Uninstalling Qwen Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		log_success "Qwen Code uninstalled"
		return 0
	else
		log_error "Failed to uninstall Qwen Code"
		return 1
	fi
}

update_qwen_code() {
	log_info "Updating Qwen Code..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @qwen-code/qwen-code &>>"$LOG_FILE"; then
		log_success "Qwen Code updated"
		return 0
	else
		log_error "Failed to update Qwen Code"
		return 1
	fi
}

# ===== GEMINI CLI =====
install_gemini_cli() {
	if command -v gemini &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @google/gemini-cli &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Gemini CLI"
		return 1
	fi
}

uninstall_gemini_cli() {
	log_info "Uninstalling Gemini CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @google/gemini-cli &>>"$LOG_FILE"; then
		log_success "Gemini CLI uninstalled"
		return 0
	else
		log_error "Failed to uninstall Gemini CLI"
		return 1
	fi
}

update_gemini_cli() {
	log_info "Updating Gemini CLI..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @google/gemini-cli &>>"$LOG_FILE"; then
		log_success "Gemini CLI updated"
		return 0
	else
		log_error "Failed to update Gemini CLI"
		return 1
	fi
}

# ===== CLAUDE CODE =====
install_claude_code() {
	if command -v claude &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @anthropic-ai/claude-code &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Claude Code"
		return 1
	fi
}

uninstall_claude_code() {
	log_info "Uninstalling Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @anthropic-ai/claude-code &>>"$LOG_FILE"; then
		log_success "Claude Code uninstalled"
		return 0
	else
		log_error "Failed to uninstall Claude Code"
		return 1
	fi
}

update_claude_code() {
	log_info "Updating Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @anthropic-ai/claude-code &>>"$LOG_FILE"; then
		log_success "Claude Code updated"
		return 0
	else
		log_error "Failed to update Claude Code"
		return 1
	fi
}

# ===== MISTRAL VIBE =====
install_mistral_vibe() {
	if command -v vibe &>/dev/null; then
		return 0
	fi

	_install_ai_pip_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"

	if pip install mistral-vibe &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Mistral Vibe"
		return 1
	fi
}

uninstall_mistral_vibe() {
	log_info "Uninstalling Mistral Vibe..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pip uninstall mistral-vibe -y &>>"$LOG_FILE"; then
		log_success "Mistral Vibe uninstalled"
		return 0
	else
		log_error "Failed to uninstall Mistral Vibe"
		return 1
	fi
}

update_mistral_vibe() {
	log_info "Updating Mistral Vibe..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pip install --upgrade mistral-vibe &>>"$LOG_FILE"; then
		log_success "Mistral Vibe updated"
		return 0
	else
		log_error "Failed to update Mistral Vibe"
		return 1
	fi
}

# ===== OPENCLAUDE =====
install_openclaude() {
	if command -v openclaude &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install OpenClaude"
		return 1
	fi
}

uninstall_openclaude() {
	log_info "Uninstalling OpenClaude..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		log_success "OpenClaude uninstalled"
		return 0
	else
		log_error "Failed to uninstall OpenClaude"
		return 1
	fi
}

update_openclaude() {
	log_info "Updating OpenClaude..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g @gitlawb/openclaude &>>"$LOG_FILE"; then
		log_success "OpenClaude updated"
		return 0
	else
		log_error "Failed to update OpenClaude"
		return 1
	fi
}

# ===== OPENCLAW =====
install_openclaw() {
	if command -v openclaw &>/dev/null; then
		return 0
	fi

	_install_ai_npm_prereqs

	npm install -g @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm install -g openclaw@latest &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install OpenClaw"
		return 1
	fi
}

uninstall_openclaw() {
	log_info "Uninstalling OpenClaw..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if npm uninstall -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
		log_success "OpenClaw uninstalled"
		return 0
	else
		log_error "Failed to uninstall OpenClaw"
		return 1
	fi
}

update_openclaw() {
	log_info "Updating OpenClaw..."
	mkdir -p "$(dirname "$LOG_FILE")"
	export GYP_DEFINES="android_ndk_path=''"
	export ANDROID_API_LEVEL=24

	if npm update -g openclaw @larksuiteoapi/node-sdk nostr-tools @slack/web-api @whiskeysockets/baileys &>>"$LOG_FILE"; then
		log_success "OpenClaw updated"
		return 0
	else
		log_error "Failed to update OpenClaw"
		return 1
	fi
}

# ===== OLLAMA =====
install_ollama() {
	if command -v ollama &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install ollama -y &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Ollama"
		return 1
	fi
}

uninstall_ollama() {
	log_info "Uninstalling Ollama..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall ollama -y &>>"$LOG_FILE"; then
		log_success "Ollama uninstalled"
		return 0
	else
		log_error "Failed to uninstall Ollama"
		return 1
	fi
}

update_ollama() {
	log_info "Updating Ollama..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade ollama -y &>>"$LOG_FILE"; then
		log_success "Ollama updated"
		return 0
	else
		log_error "Failed to update Ollama"
		return 1
	fi
}

# ===== CODEX =====
install_codex() {
	if command -v codex &>/dev/null; then
		return 0
	fi

	pkg install tur-repo -y &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg install codex -y &>>"$LOG_FILE"; then
		return 0
	else
		log_error "Failed to install Codex"
		return 1
	fi
}

uninstall_codex() {
	log_info "Uninstalling Codex..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg uninstall codex -y &>>"$LOG_FILE"; then
		log_success "Codex uninstalled"
		return 0
	else
		log_error "Failed to uninstall Codex"
		return 1
	fi
}

update_codex() {
	log_info "Updating Codex..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if pkg upgrade codex -y &>>"$LOG_FILE"; then
		log_success "Codex updated"
		return 0
	else
		log_error "Failed to update Codex"
		return 1
	fi
}

# ===== OPENCODE =====

install_opencode() {
	if command -v opencode &>/dev/null; then
		return 0
	fi

	pkg install proot-distro -y &>>"$LOG_FILE"

	mkdir -p "$(dirname "$LOG_FILE")"

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

ENV_ARGS=()                                                while IFS= read -r line; do
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

	if [ $? -eq 0 ]; then
		return 0
	else
		log_error "Failed to install OpenCode"
		return 1
	fi
}

uninstall_opencode() {
	log_info "Uninstalling OpenCode..."
	mkdir -p "$(dirname "$LOG_FILE")"

	if proot-distro remove alpine &>>"$LOG_FILE" && rm "$PREFIX/bin/opencode" &>>"$LOG_FILE"; then
		log_success "OpenCode uninstalled"
		return 0
	else
		log_error "Failed to uninstall OpenCode"
		return 1
	fi
}

update_opencode() {
	log_info "Updating OpenCode..."
	mkdir -p "$(dirname "$LOG_FILE")"
	LATEST_VERSION=$(curl -sI https://github.com/anomalyco/opencode/releases/latest | grep -i location | sed -E 's#.*/tag/([^[:space:]]+).*#\1#')
	TAR_NAME="opencode-linux-arm64-musl.tar.gz"
	REPO="https://github.com/anomalyco/opencode/releases/download/$LATEST_VERSION/$TAR_NAME"
	ALPINE_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/alpine"

	if rm $ALPINE_ROOT/bin/opencode && curl -L $REPO -o $TMPDIR/$TAR_NAME &>>"$LOG_FILE" && tar -zxf $TMPDIR/$TAR_NAME -C $ALPINE_ROOT/bin && rm $TMPDIR/$TAR_NAME && chmod +x $ALPINE_ROOT/bin/opencode &>>"$LOG_FILE"; then
		log_success "OpenCode updated"
		return 0
	else
		log_error "Failed to update OpenCode"
		return 1
	fi
}
