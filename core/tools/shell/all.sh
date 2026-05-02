#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

SHELL_PLUGINS=(
	"powerlevel10k"
	"zsh-defer"
	"zsh-autosuggestions"
	"zsh-syntax-highlighting"
	"history-substring"
	"zsh-completions"
	"fzf-tab"
	"you-should-use"
	"zsh-autopair"
	"better-npm"
)

source "$(dirname "$BASH_SOURCE")/powerlevel10k.sh"
source "$(dirname "$BASH_SOURCE")/zsh-defer.sh"
source "$(dirname "$BASH_SOURCE")/zsh-autosuggestions.sh"
source "$(dirname "$BASH_SOURCE")/zsh-syntax-highlighting.sh"
source "$(dirname "$BASH_SOURCE")/history-substring.sh"
source "$(dirname "$BASH_SOURCE")/zsh-completions.sh"
source "$(dirname "$BASH_SOURCE")/fzf-tab.sh"
source "$(dirname "$BASH_SOURCE")/you-should-use.sh"
source "$(dirname "$BASH_SOURCE")/zsh-autopair.sh"
source "$(dirname "$BASH_SOURCE")/better-npm.sh"

install_all_shell_plugins() {
	local installed_count=0
	local failed_count=0

	for tool in "${SHELL_PLUGINS[@]}"; do
		case "$tool" in
		powerlevel10k)
			if install_powerlevel10k; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-defer)
			if install_zsh_defer; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-autosuggestions)
			if install_zsh_autosuggestions; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-syntax-highlighting)
			if install_zsh_syntax_highlighting; then ((installed_count++)); else ((failed_count++)); fi
			;;
		history-substring)
			if install_history_substring; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-completions)
			if install_zsh_completions; then ((installed_count++)); else ((failed_count++)); fi
			;;
		fzf-tab)
			if install_fzf_tab; then ((installed_count++)); else ((failed_count++)); fi
			;;
		you-should-use)
			if install_you_should_use; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-autopair)
			if install_zsh_autopair; then ((installed_count++)); else ((failed_count++)); fi
			;;
		better-npm)
			if install_better_npm; then ((installed_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

uninstall_all_shell_plugins() {
	local uninstalled_count=0
	local failed_count=0

	for tool in "${SHELL_PLUGINS[@]}"; do
		case "$tool" in
		powerlevel10k)
			if uninstall_powerlevel10k; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-defer)
			if uninstall_zsh_defer; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-autosuggestions)
			if uninstall_zsh_autosuggestions; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-syntax-highlighting)
			if uninstall_zsh_syntax_highlighting; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		history-substring)
			if uninstall_history_substring; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-completions)
			if uninstall_zsh_completions; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		fzf-tab)
			if uninstall_fzf_tab; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		you-should-use)
			if uninstall_you_should_use; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-autopair)
			if uninstall_zsh_autopair; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		better-npm)
			if uninstall_better_npm; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}

update_all_shell_plugins() {
	local updated_count=0
	local failed_count=0

	for tool in "${SHELL_PLUGINS[@]}"; do
		case "$tool" in
		powerlevel10k)
			if update_powerlevel10k; then ((updated_count++)); else ((failed_count++)); fi
			;;
		zsh-defer)
			if update_zsh_defer; then ((updated_count++)); else ((failed_count++)); fi
			;;
		zsh-autosuggestions)
			if update_zsh_autosuggestions; then ((updated_count++)); else ((failed_count++)); fi
			;;
		zsh-syntax-highlighting)
			if update_zsh_syntax_highlighting; then ((updated_count++)); else ((failed_count++)); fi
			;;
		history-substring)
			if update_history_substring; then ((updated_count++)); else ((failed_count++)); fi
			;;
		zsh-completions)
			if update_zsh_completions; then ((updated_count++)); else ((failed_count++)); fi
			;;
		fzf-tab)
			if update_fzf_tab; then ((updated_count++)); else ((failed_count++)); fi
			;;
		you-should-use)
			if update_you_should_use; then ((updated_count++)); else ((failed_count++)); fi
			;;
		zsh-autopair)
			if update_zsh_autopair; then ((updated_count++)); else ((failed_count++)); fi
			;;
		better-npm)
			if update_better_npm; then ((updated_count++)); else ((failed_count++)); fi
			;;
		esac
	done

	return 0
}