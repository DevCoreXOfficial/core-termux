#!/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
UBUNTU_BASHRC="$UBUNTU_ROOT/root/.bashrc"

_proot_ubuntu() {
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- "$@"
}

_install_claude_binary() {
	_proot_ubuntu /bin/bash -c '
                export SHELL=/bin/bash
                export TMPDIR=/tmp
                export HOME=/root
                curl -fsSL https://claude.ai/install.sh | bash
        ' &>>"$LOG_FILE"
}

_write_claude_wrapper() {
	cat <<'EOF' >"$PREFIX/bin/claude"
#!/bin/bash

UBUNTU_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

EXCLUDE_REGEX="^(PATH|LD_PRELOAD|LD_LIBRARY_PATH|PREFIX|HOME|PWD|OLDPWD|SHELL|IFS|_|SHLVL|PROMPT_COMMAND|TERMCAP|LS_COLORS|TERM)="

ENV_ARGS=()
while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ $EXCLUDE_REGEX ]]; then
                ENV_ARGS+=("--env" "$line")
        fi
done < <(env)

ENV_ARGS+=(
        "--env" "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
        "--env" "TERM=$TERM"
        "--env" "HOME=/root"
)

unset LD_PRELOAD
proot-distro login \
        "${ENV_ARGS[@]}" \
        --termux-home \
        --shared-tmp \
        --bind "$UBUNTU_ROOTFS/root/.local:/root/.local" \
        --bind "$UBUNTU_ROOTFS/root/.claude:/root/.claude" \
        --work-dir "$PWD" \
        ubuntu \
        -- /root/.local/bin/claude "$@"
EOF
	chmod +x "$PREFIX/bin/claude"
}

_write_claude_path() {
	if ! grep -q '.local/bin' "$UBUNTU_BASHRC" 2>/dev/null; then
		printf '\n# claude-code\nexport PATH=/root/.local/bin:$PATH\n' >>"$UBUNTU_BASHRC"
	fi
}

install_claude_code() {
	if command -v claude &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	pkg install proot-distro -y &>>"$LOG_FILE"

	if [ ! -d "$UBUNTU_ROOT" ]; then
		proot-distro install ubuntu &>>"$LOG_FILE"
	fi

	_proot_ubuntu /bin/bash -c \
		'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
		&>>"$LOG_FILE"

	_install_claude_binary

	if ! _proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
		log_error "Claude Code binary not found after install"
		return 1
	fi

	_write_claude_wrapper
	_write_claude_path

	log_success "Claude Code installed"
	return 0
}

uninstall_claude_code() {
	log_info "Uninstalling Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c \
		'rm -f /root/.local/bin/claude && rm -rf /root/.claude && rm -rf /root/.local/share/claude' \
		&>>"$LOG_FILE"

	if [ -f "$UBUNTU_BASHRC" ]; then
		sed -i '/# claude-code/d; /export PATH=\/root\/.local\/bin/d' "$UBUNTU_BASHRC"
	fi

	if rm -f "$PREFIX/bin/claude" &>>"$LOG_FILE"; then
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

	_proot_ubuntu /bin/bash -c '
                export HOME=/root
                curl -fsSL https://claude.ai/install.sh | bash
        ' &>>"$LOG_FILE"

	if ! _proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
		log_error "Claude Code binary not found after update"
		return 1
	fi

	log_success "Claude Code updated"
	return 0
}
