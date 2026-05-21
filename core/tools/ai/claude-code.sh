#!/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

_detect_ubuntu_root() {
	local root
	root="$(find /data/data/com.termux -maxdepth 10 -type d \
		-name "rootfs" -path "*/containers/ubuntu/*" 2>/dev/null | head -1)"

	if [ -z "$root" ]; then
		root="$(find /data/data/com.termux -maxdepth 10 -type d \
			-name "ubuntu" -path "*/installed-rootfs/*" 2>/dev/null | head -1)"
	fi

	echo "$root"
}

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
	local ubuntu_root="$1"
	cat <<EOF >"$PREFIX/bin/claude"
#!/bin/bash

UBUNTU_ROOTFS="$ubuntu_root"

EXCLUDE_REGEX="^(PATH|LD_PRELOAD|LD_LIBRARY_PATH|PREFIX|HOME|PWD|OLDPWD|SHELL|IFS|_|SHLVL|PROMPT_COMMAND|TERMCAP|LS_COLORS|TERM)="

ENV_ARGS=()
while IFS= read -r line; do
        if [[ -n "\$line" && ! "\$line" =~ \$EXCLUDE_REGEX ]]; then
                ENV_ARGS+=("--env" "\$line")
        fi
done < <(env)

ENV_ARGS+=(
        "--env" "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
        "--env" "TERM=\$TERM"
        "--env" "HOME=/root"
)

unset LD_PRELOAD
proot-distro login \\
        "\${ENV_ARGS[@]}" \\
        --termux-home \\
        --shared-tmp \\
        --bind "\$UBUNTU_ROOTFS/root/.local:/root/.local" \\
        --bind "\$UBUNTU_ROOTFS/root/.claude:/root/.claude" \\
        --work-dir "\$PWD" \\
        ubuntu \\
        -- /root/.local/bin/claude "\$@"
EOF
	chmod +x "$PREFIX/bin/claude"
}

_write_claude_path() {
	local ubuntu_bashrc="$1"
	if ! grep -q '.local/bin' "$ubuntu_bashrc" 2>/dev/null; then
		printf '\n# claude-code\nexport PATH=/root/.local/bin:$PATH\n' >>"$ubuntu_bashrc"
	fi
}

install_claude_code() {
	if command -v claude &>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"

	if ! command -v proot-distro &>/dev/null; then
		pkg install proot-distro -y &>>"$LOG_FILE"
	fi

	if [ ! -d "$(_detect_ubuntu_root)" ]; then
		proot-distro install ubuntu &>>"$LOG_FILE"
	fi

	_proot_ubuntu /bin/bash -c \
		'apt-get update && apt-get upgrade -y && apt-get install -y curl ca-certificates' \
		&>>"$LOG_FILE"

	_install_claude_binary

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"

	if [ -z "$ubuntu_root" ]; then
		log_error "Ubuntu rootfs not found"
		return 1
	fi

	if ! _proot_ubuntu test -x /root/.local/bin/claude &>>"$LOG_FILE"; then
		log_error "Claude Code binary not found after install"
		return 1
	fi

	_write_claude_wrapper "$ubuntu_root"
	_write_claude_path "$ubuntu_root/root/.bashrc"

	log_success "Claude Code installed"
	return 0
}

uninstall_claude_code() {
	log_info "Uninstalling Claude Code..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c \
		'rm -f /root/.local/bin/claude && rm -rf /root/.claude && rm -rf /root/.local/share/claude' \
		&>>"$LOG_FILE"

	local ubuntu_bashrc
	ubuntu_bashrc="$(_detect_ubuntu_root)/root/.bashrc"

	if [ -f "$ubuntu_bashrc" ]; then
		sed -i '/# claude-code/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
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
