#!/bin/bash
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
OPENCODE_BIN="$UBUNTU_ROOT/root/.opencode/bin/opencode"

_proot_ubuntu() {
	proot-distro login \
		--termux-home \
		--shared-tmp \
		ubuntu \
		-- "$@"
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

	# Actualizar repos sin entrar a shell interactiva
	_proot_ubuntu /bin/bash -c \
		'apt-get update -y && apt-get upgrade -y' \
		&>>"$LOG_FILE"

	# Instalar opencode con el instalador oficial
	# HOME=/root es crítico para que el instalador escriba en el rootfs de Ubuntu
	# y no en el home de Termux (que sería sobreescrito por --termux-home)
	_proot_ubuntu /bin/bash -c \
		'HOME=/root curl -fsSL https://opencode.ai/install | bash' \
		&>>"$LOG_FILE"

	# Verificar que el binario quedó en el rootfs de Ubuntu
	if [ ! -f "$OPENCODE_BIN" ]; then
		log_error "OpenCode binary not found after install"
		return 1
	fi

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

	# Eliminar binario y directorio desde el rootfs (sin --termux-home para ver /root real)
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- /bin/bash -c 'rm -rf /root/.opencode' \
		&>>"$LOG_FILE"

	# Limpiar entrada del PATH en .bashrc del rootfs
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- /bin/bash -c \
		'sed -i "/# opencode/d; /export PATH=\/root\/.opencode\/bin/d" /root/.bashrc' \
		&>>"$LOG_FILE"

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

	# Eliminar binario anterior y reinstalar con el instalador oficial
	proot-distro login \
		--shared-tmp \
		ubuntu \
		-- /bin/bash -c \
		'rm -rf /root/.opencode && HOME=/root curl -fsSL https://opencode.ai/install | bash' \
		&>>"$LOG_FILE"

	if [ ! -f "$OPENCODE_BIN" ]; then
		log_error "OpenCode binary not found after update"
		return 1
	fi

	log_success "OpenCode updated"
	return 0
}
