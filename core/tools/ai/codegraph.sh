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

_install_codegraph_binary() {
	_proot_ubuntu /bin/bash -c '
                export SHELL=/bin/bash
                export TMPDIR=/tmp
                export HOME=/root
                export PATH="/root/.local/bin:$PATH"
                curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
        ' &>>"$LOG_FILE"
}

_write_codegraph_wrapper() {
	local ubuntu_root="$1"
	cat <<EOF >"$PREFIX/bin/codegraph"
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
        --shared-tmp \\
        --bind "\$UBUNTU_ROOTFS/root/.codegraph:/root/.codegraph" \\
        --bind "\$UBUNTU_ROOTFS/root/.local:/root/.local" \\
        --work-dir \$PWD \\
        ubuntu \\
        -- /root/.local/bin/codegraph "\$@"
EOF
	chmod +x "$PREFIX/bin/codegraph"
}

_write_codegraph_path() {
	local ubuntu_bashrc="$1"
	if ! grep -q '.local/bin' "$ubuntu_bashrc" 2>/dev/null; then
		printf '\n# codegraph\nexport PATH=/root/.local/bin:$PATH\n' >>"$ubuntu_bashrc"
	fi
}

install_codegraph() {
	if command -v codegraph &>/dev/null; then
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

	_install_codegraph_binary

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"

	if [ -z "$ubuntu_root" ]; then
		log_error "Ubuntu rootfs not found"
		return 1
	fi

	local codegraph_bin="$ubuntu_root/root/.local/bin/codegraph"

	if [ ! -L "$codegraph_bin" ] && [ ! -f "$codegraph_bin" ]; then
		log_error "CodeGraph binary not found after install"
		return 1
	fi

	_write_codegraph_wrapper "$ubuntu_root"
	_write_codegraph_path "$ubuntu_root/root/.bashrc"

	log_success "CodeGraph installed"
	return 0
}

uninstall_codegraph() {
	log_info "Uninstalling CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c 'rm -rf /root/.codegraph && rm -f /root/.local/bin/codegraph' \
		&>>"$LOG_FILE"

	local ubuntu_bashrc
	ubuntu_bashrc="$(_detect_ubuntu_root)/root/.bashrc"

	if [ -f "$ubuntu_bashrc" ]; then
		sed -i '/# codegraph/d; /export PATH=\/root\/.local\/bin/d' "$ubuntu_bashrc"
	fi

	if rm -f "$PREFIX/bin/codegraph" &>>"$LOG_FILE"; then
		log_success "CodeGraph uninstalled"
		return 0
	else
		log_error "Failed to uninstall CodeGraph"
		return 1
	fi
}

update_codegraph() {
	log_info "Updating CodeGraph..."
	mkdir -p "$(dirname "$LOG_FILE")"

	_proot_ubuntu /bin/bash -c 'rm -rf /root/.codegraph && rm -f /root/.local/bin/codegraph' \
		&>>"$LOG_FILE"

	_install_codegraph_binary

	local ubuntu_root
	ubuntu_root="$(_detect_ubuntu_root)"
	local codegraph_bin="$ubuntu_root/root/.local/bin/codegraph"

	if [ ! -L "$codegraph_bin" ] && [ ! -f "$codegraph_bin" ]; then
		log_error "CodeGraph binary not found after update"
		return 1
	fi

	log_success "CodeGraph updated"
	return 0
}
