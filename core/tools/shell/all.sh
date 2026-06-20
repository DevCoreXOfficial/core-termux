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
			loading "Installing powerlevel10k" install_powerlevel10k
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		zsh-defer)
			loading "Installing zsh-defer" install_zsh_defer
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		zsh-autosuggestions)
			loading "Installing zsh-autosuggestions" install_zsh_autosuggestions
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		zsh-syntax-highlighting)
			loading "Installing zsh-syntax-highlighting" install_zsh_syntax_highlighting
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		history-substring)
			loading "Installing zsh-history-substring-search" install_history_substring
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		zsh-completions)
			loading "Installing zsh-completions" install_zsh_completions
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		fzf-tab)
			loading "Installing fzf-tab" install_fzf_tab
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		you-should-use)
			loading "Installing zsh-you-should-use" install_you_should_use
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		zsh-autopair)
			loading "Installing zsh-autopair" install_zsh_autopair
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
			;;
		better-npm)
			loading "Installing zsh-better-npm-completion" install_better_npm
			case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
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
			loading "Uninstalling powerlevel10k" uninstall_powerlevel10k
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		zsh-defer)
			loading "Uninstalling zsh-defer" uninstall_zsh_defer
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		zsh-autosuggestions)
			loading "Uninstalling zsh-autosuggestions" uninstall_zsh_autosuggestions
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		zsh-syntax-highlighting)
			loading "Uninstalling zsh-syntax-highlighting" uninstall_zsh_syntax_highlighting
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		history-substring)
			loading "Uninstalling zsh-history-substring-search" uninstall_history_substring
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		zsh-completions)
			loading "Uninstalling zsh-completions" uninstall_zsh_completions
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		fzf-tab)
			loading "Uninstalling fzf-tab" uninstall_fzf_tab
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		you-should-use)
			loading "Uninstalling zsh-you-should-use" uninstall_you_should_use
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		zsh-autopair)
			loading "Uninstalling zsh-autopair" uninstall_zsh_autopair
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
			;;
		better-npm)
			loading "Uninstalling zsh-better-npm-completion" uninstall_better_npm
			case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
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
      loading "Updating powerlevel10k" update_powerlevel10k
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-defer)
      loading "Updating zsh-defer" update_zsh_defer
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-autosuggestions)
      loading "Updating zsh-autosuggestions" update_zsh_autosuggestions
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-syntax-highlighting)
      loading "Updating zsh-syntax-highlighting" update_zsh_syntax_highlighting
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    history-substring)
      loading "Updating zsh-history-substring-search" update_history_substring
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-completions)
      loading "Updating zsh-completions" update_zsh_completions
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    fzf-tab)
      loading "Updating fzf-tab" update_fzf_tab
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    you-should-use)
      loading "Updating zsh-you-should-use" update_you_should_use
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-autopair)
      loading "Updating zsh-autopair" update_zsh_autopair
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    better-npm)
      loading "Updating zsh-better-npm-completion" update_better_npm
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
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
      loading "Reinstalling powerlevel10k" reinstall_powerlevel10k
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-defer)
      loading "Reinstalling zsh-defer" reinstall_zsh_defer
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-autosuggestions)
      loading "Reinstalling zsh-autosuggestions" reinstall_zsh_autosuggestions
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-syntax-highlighting)
      loading "Reinstalling zsh-syntax-highlighting" reinstall_zsh_syntax_highlighting
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    history-substring)
      loading "Reinstalling zsh-history-substring-search" reinstall_history_substring
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-completions)
      loading "Reinstalling zsh-completions" reinstall_zsh_completions
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    fzf-tab)
      loading "Reinstalling fzf-tab" reinstall_fzf_tab
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    you-should-use)
      loading "Reinstalling zsh-you-should-use" reinstall_you_should_use
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    zsh-autopair)
      loading "Reinstalling zsh-autopair" reinstall_zsh_autopair
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    better-npm)
      loading "Reinstalling zsh-better-npm-completion" reinstall_better_npm
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}