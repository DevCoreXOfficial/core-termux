#!/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
OPENCODE_BIN="$UBUNTU_ROOT/root/.opencode/bin/opencode"
UBUNTU_BASHRC="$UBUNTU_ROOT/root/.bashrc"

_proot_ubuntu() {
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- "$@"
}

_install_binary() {
	_proot_ubuntu /bin/bash -c '
                export SHELL=/bin/bash
                export TMPDIR=/tmp
                export HOME=/root
                curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
        ' &>>"$LOG_FILE"
}

_write_wrapper() {
	cat <<'EOF' >"$PREFIX/bin/opencode"
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
        --bind "$UBUNTU_ROOTFS/root/.opencode:/root/.opencode" \
        --work-dir $PWD \
        ubuntu \
        -- /root/.opencode/bin/opencode "$@"
EOF
	chmod +x "$PREFIX/bin/opencode"
}

_write_path() {
	if ! grep -q '.opencode/bin' "$UBUNTU_BASHRC" 2>/dev/null; then
		printf '\n# opencode\nexport PATH=/root/.opencode/bin:$PATH\n' >>"$UBUNTU_BASHRC"
	fi
}

install_opencode() {
	if command -v opencode &>/dev/null; then
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

	_install_binary

	if [ ! -f "$OPENCODE_BIN" ]; then
		log_error "OpenCode binary not found after install"
		return 1
	fi

	_write_wrapper
	_write_path

	log_success "OpenCode installed"
	return 0
}

uninstall_opencode() {
	log_info "Uninstalling OpenCode..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode' &>>"$LOG_FILE"

	if [ -f "$UBUNTU_BASHRC" ]; then
		sed -i '/# opencode/d; /export PATH=\/root\/.opencode\/bin/d' "$UBUNTU_BASHRC"
	fi

	if rm -f "$PREFIX/bin/opencode" &>>"$LOG_FILE"; then
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

	_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode' &>>"$LOG_FILE"

	_install_binary

	if [ ! -f "$OPENCODE_BIN" ]; then
		log_error "OpenCode binary not found after update"
		return 1
	fi

	log_success "OpenCode updated"
	return 0
}
