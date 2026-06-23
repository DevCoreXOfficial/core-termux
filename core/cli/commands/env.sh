#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

# ── Detect rc file: zsh > bash ─────────────────────────────
_env_rc_file() {
	if [[ -f "$HOME/.zshrc" ]]; then
		echo "$HOME/.zshrc"
	else
		echo "$HOME/.bashrc"
	fi
}

# ── Validate variable name ─────────────────────────────────
_env_valid_key() {
	local key="$1"
	if [[ -z "$key" ]]; then
		log_error "Variable name cannot be empty"
		return 1
	fi
	if [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
		log_error "Invalid variable name: $key"
		list_item "Must start with a letter or underscore, followed by letters, digits, or underscores"
		return 1
	fi
}

# ── Help ────────────────────────────────────────────────────
env_help() {
	echo
	box "Environment Variables Manager"
	echo
	log_info "Usage: core env [options]"
	echo
	separator_section "Available Commands"
	echo
	printf "    ${D_CYAN}%-12s${NC} %s\n" "set" "Create or update an environment variable"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "unset" "Remove an environment variable"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "ls" "List all user-defined variables"
	echo
	separator_section "Examples"
	echo
	printf "    ${D_CYAN}core env set${NC}              # Interactive: add/update a variable\n"
	printf "    ${D_CYAN}core env unset${NC}            # Interactive: select and remove a variable\n"
	printf "    ${D_CYAN}core env ls${NC}               # List all export vars in rc file\n"
	echo
}

# ── Set / Update ────────────────────────────────────────────
env_set() {
	local rc_file
	rc_file=$(_env_rc_file)

	separator
	box "Set Environment Variable"
	separator
	echo

	local key value
	read_input "Variable name" key
	_env_valid_key "$key" || return 1

	read_secret "Value for $key" value

	if grep -q "^export $key=" "$rc_file" 2>/dev/null; then
		local current_value
		current_value=$(grep "^export $key=" "$rc_file" | head -1 | sed 's/^export [^=]*=//')
		echo
		log_info "Current value: ${D_DIM}${current_value:0:40}${D_NC}"
		log_warn "Variable $D_CYAN$key$D_YELLOW already exists in $(basename "$rc_file")"
		read_confirm "Replace it?" confirm
		if [[ "$confirm" != "y" ]]; then
			echo
			log_warn "Operation cancelled"
			separator
			return 0
		fi
		sed -i "/^export ${key}=/d" "$rc_file"
		echo
		log_info "Replacing $D_CYAN$key$D_NC..."
	else
		echo
	fi

	echo "export $key=$value" >>"$rc_file"

	echo
	log_success "Variable ${D_CYAN}${key}${D_GREEN} set in ${D_NC}$(basename "$rc_file")"
	list_item "Run: ${D_CYAN}source $(basename "$rc_file")${D_NC} to apply, or restart your terminal"
	separator
}

# ── Unset / Remove ─────────────────────────────────────────
env_unset() {
	local rc_file
	rc_file=$(_env_rc_file)

	# Gather existing variables
	local -a keys=()
	local line k
	while IFS= read -r line; do
		line="${line#export }"
		k="${line%%=*}"
		keys+=("$k")
	done < <(grep "^export " "$rc_file" 2>/dev/null || true)

	if [[ ${#keys[@]} -eq 0 ]]; then
		separator
		box "Remove Environment Variable"
		separator
		echo
		log_warn "No environment variables found in $(basename "$rc_file")"
		list_item "Add one first: ${D_CYAN}core env set${D_NC}"
		separator
		return 0
	fi

	separator
	box "Remove Environment Variable"
	separator
	echo
	log_info "Current variables in $(basename "$rc_file"):"
	echo

	for k in "${keys[@]}"; do
		printf "    ${D_GREEN}•${D_NC} ${D_CYAN}%s${D_NC}\n" "$k"
	done

	echo
	read_input "Enter the name to remove" key

	local found=false
	for k in "${keys[@]}"; do
		if [[ "$k" == "$key" ]]; then
			found=true
			break
		fi
	done

	if ! $found; then
		echo
		log_error "Variable $D_CYAN$key$D_RED not found in $(basename "$rc_file")"
		separator
		return 1
	fi

	echo
	log_warn "This will remove $D_CYAN$key$D_YELLOW from $(basename "$rc_file")"
	read_confirm "Are you sure?" confirm
	if [[ "$confirm" != "y" ]]; then
		echo
		log_warn "Operation cancelled"
		separator
		return 0
	fi

	sed -i "/^export ${key}=/d" "$rc_file"

	echo
	log_success "Variable ${D_CYAN}${key}${D_GREEN} removed from ${D_NC}$(basename "$rc_file")"
	list_item "Run: ${D_CYAN}source $(basename "$rc_file")${D_NC} to apply, or restart your terminal"
	separator
}

# ── List ─────────────────────────────────────────────────────
env_ls() {
	local rc_file
	rc_file=$(_env_rc_file)

	separator
	box "Environment Variables"
	separator
	echo
	log_info "File: $(basename "$rc_file")"
	echo

	local count=0
	local line

	while IFS= read -r line; do
		line="${line#export }"
		local k="${line%%=*}"
		local v="${line#*=}"
		printf "    ${D_GREEN}%-28s${NC} ${GRAY}=${NC} ${D_DIM}%s${NC}\n" "$k" "$v"
		((count++))
	done < <(grep "^export " "$rc_file" 2>/dev/null || true)

	if [[ $count -eq 0 ]]; then
		list_item "No environment variables defined yet"
		echo
		list_item "Add one: ${D_CYAN}core env set${D_NC}"
	fi

	echo
	separator
	list_item "$count variable(s) in $(basename "$rc_file")"
	separator
}

# ── Main dispatcher ──────────────────────────────────────────
env_main() {
	local cmd="$1"
	shift || true

	case "$cmd" in
	set)
		env_set
		;;
	unset)
		env_unset
		;;
	ls | list)
		env_ls
		;;
	"" | --help | -h)
		env_help
		;;
	*)
		log_error "Unknown command: $cmd"
		echo
		env_help
		exit 1
		;;
	esac
}
