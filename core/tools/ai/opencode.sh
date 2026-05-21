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

_install_opencode_binary() {
	_proot_ubuntu /bin/bash -c '
                export SHELL=/bin/bash
                export TMPDIR=/tmp
                export HOME=/root
                curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
        ' &>>"$LOG_FILE"
}

_write_opencode_wrapper() {
	local ubuntu_root="$1"
	cat <<EOF >"$PREFIX/bin/opencode"
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
        --bind "\$UBUNTU_ROOTFS/root/.opencode:/root/.opencode" \\
        --work-dir \$PWD \\
        ubuntu \\
        -- /root/.opencode/bin/opencode "\$@"
EOF
	chmod +x "$PREFIX/bin/opencode"
}

_write_opencode_path() {
	local ubuntu_bashrc="$1"
	if ! grep -q '.opencode/bin' "$ubuntu_bashrc" 2>/dev/null; then
		printf '\n# opencode\nexport PATH=/root/.opencode/bin:$PATH\n' >>"$ubuntu_bashrc"
	fi
}

install_opencode() {
	if command -v opencode &>/dev/null; then
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

	_install_opencode_binary

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"

	if [ -z "$ubuntu_root" ]; then
		log_error "Ubuntu rootfs not found"
		return 1
	fi

	local opencode_bin="$ubuntu_root/root/.opencode/bin/opencode"

	if [ ! -f "$opencode_bin" ]; then
		log_error "OpenCode binary not found after install"
		return 1
	fi

	_write_opencode_wrapper "$ubuntu_root"
	_write_opencode_path "$ubuntu_root/root/.bashrc"

	log_success "OpenCode installed"
	return 0
}

uninstall_opencode() {
	log_info "Uninstalling OpenCode..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c 'rm -rf /root/.opencode' &>>"$LOG_FILE"

	local ubuntu_bashrc
	ubuntu_bashrc="$(_detect_ubuntu_root)/root/.bashrc"

	if [ -f "$ubuntu_bashrc" ]; then
		sed -i '/# opencode/d; /export PATH=\/root\/.opencode\/bin/d' "$ubuntu_bashrc"
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

	_install_opencode_binary

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"
	local opencode_bin="$ubuntu_root/root/.opencode/bin/opencode"

	if [ ! -f "$opencode_bin" ]; then
		log_error "OpenCode binary not found after update"
		return 1
	fi

	log_success "OpenCode updated"
	return 0
}
