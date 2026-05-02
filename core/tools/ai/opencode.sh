#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

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