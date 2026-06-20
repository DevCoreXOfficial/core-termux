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

source "$(dirname "$BASH_SOURCE")/powerlevel10k/install.sh"
source "$(dirname "$BASH_SOURCE")/zsh-defer/install.sh"
source "$(dirname "$BASH_SOURCE")/zsh-autosuggestions/install.sh"
source "$(dirname "$BASH_SOURCE")/zsh-syntax-highlighting/install.sh"
source "$(dirname "$BASH_SOURCE")/history-substring/install.sh"
source "$(dirname "$BASH_SOURCE")/zsh-completions/install.sh"
source "$(dirname "$BASH_SOURCE")/fzf-tab/install.sh"
source "$(dirname "$BASH_SOURCE")/you-should-use/install.sh"
source "$(dirname "$BASH_SOURCE")/zsh-autopair/install.sh"
source "$(dirname "$BASH_SOURCE")/better-npm/install.sh"

install_all_shell_plugins() {
	local installed_count=0
	local failed_count=0

	for tool in "${SHELL_PLUGINS[@]}"; do
		case "$tool" in
		powerlevel10k)
			if loading "Installing powerlevel10k" install_powerlevel10k; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-defer)
			if loading "Installing zsh-defer" install_zsh_defer; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-autosuggestions)
			if loading "Installing zsh-autosuggestions" install_zsh_autosuggestions; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-syntax-highlighting)
			if loading "Installing zsh-syntax-highlighting" install_zsh_syntax_highlighting; then ((installed_count++)); else ((failed_count++)); fi
			;;
		history-substring)
			if loading "Installing zsh-history-substring-search" install_history_substring; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-completions)
			if loading "Installing zsh-completions" install_zsh_completions; then ((installed_count++)); else ((failed_count++)); fi
			;;
		fzf-tab)
			if loading "Installing fzf-tab" install_fzf_tab; then ((installed_count++)); else ((failed_count++)); fi
			;;
		you-should-use)
			if loading "Installing zsh-you-should-use" install_you_should_use; then ((installed_count++)); else ((failed_count++)); fi
			;;
		zsh-autopair)
			if loading "Installing zsh-autopair" install_zsh_autopair; then ((installed_count++)); else ((failed_count++)); fi
			;;
		better-npm)
			if loading "Installing zsh-better-npm-completion" install_better_npm; then ((installed_count++)); else ((failed_count++)); fi
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
			if loading "Uninstalling powerlevel10k" uninstall_powerlevel10k; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-defer)
			if loading "Uninstalling zsh-defer" uninstall_zsh_defer; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-autosuggestions)
			if loading "Uninstalling zsh-autosuggestions" uninstall_zsh_autosuggestions; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-syntax-highlighting)
			if loading "Uninstalling zsh-syntax-highlighting" uninstall_zsh_syntax_highlighting; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		history-substring)
			if loading "Uninstalling zsh-history-substring-search" uninstall_history_substring; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-completions)
			if loading "Uninstalling zsh-completions" uninstall_zsh_completions; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		fzf-tab)
			if loading "Uninstalling fzf-tab" uninstall_fzf_tab; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		you-should-use)
			if loading "Uninstalling zsh-you-should-use" uninstall_you_should_use; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		zsh-autopair)
			if loading "Uninstalling zsh-autopair" uninstall_zsh_autopair; then ((uninstalled_count++)); else ((failed_count++)); fi
			;;
		better-npm)
			if loading "Uninstalling zsh-better-npm-completion" uninstall_better_npm; then ((uninstalled_count++)); else ((failed_count++)); fi
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
      if loading "Updating powerlevel10k" update_powerlevel10k; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    zsh-defer)
      if loading "Updating zsh-defer" update_zsh_defer; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    zsh-autosuggestions)
      if loading "Updating zsh-autosuggestions" update_zsh_autosuggestions; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    zsh-syntax-highlighting)
      if loading "Updating zsh-syntax-highlighting" update_zsh_syntax_highlighting; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    history-substring)
      if loading "Updating zsh-history-substring-search" update_history_substring; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    zsh-completions)
      if loading "Updating zsh-completions" update_zsh_completions; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    fzf-tab)
      if loading "Updating fzf-tab" update_fzf_tab; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    you-should-use)
      if loading "Updating zsh-you-should-use" update_you_should_use; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    zsh-autopair)
      if loading "Updating zsh-autopair" update_zsh_autopair; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    better-npm)
      if loading "Updating zsh-better-npm-completion" update_better_npm; then ((updated_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}

reinstall_all_shell_plugins() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${SHELL_PLUGINS[@]}"; do
    case "$tool" in
    powerlevel10k)
      if loading "Reinstalling powerlevel10k" reinstall_powerlevel10k; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    zsh-defer)
      if loading "Reinstalling zsh-defer" reinstall_zsh_defer; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    zsh-autosuggestions)
      if loading "Reinstalling zsh-autosuggestions" reinstall_zsh_autosuggestions; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    zsh-syntax-highlighting)
      if loading "Reinstalling zsh-syntax-highlighting" reinstall_zsh_syntax_highlighting; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    history-substring)
      if loading "Reinstalling zsh-history-substring-search" reinstall_history_substring; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    zsh-completions)
      if loading "Reinstalling zsh-completions" reinstall_zsh_completions; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    fzf-tab)
      if loading "Reinstalling fzf-tab" reinstall_fzf_tab; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    you-should-use)
      if loading "Reinstalling zsh-you-should-use" reinstall_you_should_use; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    zsh-autopair)
      if loading "Reinstalling zsh-autopair" reinstall_zsh_autopair; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    better-npm)
      if loading "Reinstalling zsh-better-npm-completion" reinstall_better_npm; then ((reinstalled_count++)); else ((failed_count++)); fi
      ;;
    esac
  done

  return 0
}