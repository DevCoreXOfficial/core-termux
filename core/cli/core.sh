#!/usr/bin/env bash

# load log and color functions for the help output
import "@/utils/log"
import "@/utils/colors"

core_main() {
  local cmd="$1"
  shift || true

  # no command passed
  if [[ -z "$cmd" ]]; then
    core_help
    return
  fi

  # Short aliases for everyday commands.
  local -A ALIASES=(
    [i]=install
    [un]=uninstall
    [up]=update
    [ri]=reinstall
    [s]=search
    [st]=style
  )
  [[ -n "${ALIASES[$cmd]:-}" ]] && cmd="${ALIASES[$cmd]}"

  local command_file="$CORE_PATH/cli/commands/$cmd.sh"

  # check if the command exists
  if [[ -f "$command_file" ]]; then
    import "@/cli/commands/$cmd"
    "${cmd}_main" "$@"
  else
    log_error "Command not found: $cmd"
    echo
    core_help
    exit 1
  fi
}

core_help() {
  echo
  box_large "◈ CORE v${CORE_VERSION} ◈"
  echo
  log_info "${D_CYAN}One CLI — Your environment. Everywhere.${D_NC}"
  echo
  log_info "Platform: $(core_platform_label) ${D_NC}(${D_GREEN}$CORE_PLATFORM${D_NC})"
  echo
  log_info "Usage: core <command> [options]"
  echo
  separator_section "Available Commands"
  echo
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "--version" "Show current version"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "agent" "AI assistant & task agent"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "brain" "Second brain — save and search memories"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "env" "Manage environment variables"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "install" "Install tools"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "show/about" "Show tool documentation (:es for Spanish)"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "update" "Update tools or framework"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "uninstall" "Remove installed tools"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "reinstall" "Uninstall + install tools"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "open" "Open documentation in browser"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "search" "Search tools (names, descriptions, tags)"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "pg" "PostgreSQL database manager"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "init" "Configure existing projects"
  printf "    ${D_CYAN}%-12s${D_NC} %s\n" "style" "Terminal look & feel (font, banner, cursor)"
printf "    ${D_CYAN}%-12s${D_NC} %s\n" "voice" "Speech-to-agent via microphone (Termux)"
  echo
  separator_section "Quick Start"
  echo
  list_item "Run: ${D_CYAN}core install <tool>${D_NC} — e.g. ${D_CYAN}core install opencode${D_NC}"
  list_item "Run: ${D_CYAN}core show <tool>${D_NC} for tool documentation"
  list_item "Run: ${D_CYAN}core open${D_NC} for official documentation"
  echo
  separator_section "Browsing Tools"
  echo
  log_info "Every tool installs individually and is found by name:"
  echo
  list_item "${D_CYAN}core search${D_NC}            all tools with install status"
  list_item "${D_CYAN}core search <text>${D_NC}     filter — e.g. ${D_CYAN}core search cloud${D_NC}, ${D_CYAN}core search js${D_NC}"
  list_item "${D_CYAN}core install nvchad${D_NC}    editor + NvChad in one shot"
  list_item "${D_CYAN}core install oh-my-zsh${D_NC}       shell + Oh My Zsh + plugins in one shot"
  echo
  echo
  separator_section "Help"
  echo
  list_item "Aliases: ${D_CYAN}i${D_NC}=install · ${D_CYAN}un${D_NC}=uninstall · ${D_CYAN}up${D_NC}=update · ${D_CYAN}ri${D_NC}=reinstall · ${D_CYAN}s${D_NC}=search · ${D_CYAN}st${D_NC}=style"
  list_item "Run ${D_CYAN}core <command>${D_NC} for command-specific help"
  list_item "Example: ${D_CYAN}core pg${D_NC}, ${D_CYAN}core init${D_NC}"
  list_item "Docs: ${D_CYAN}core open${D_NC} — ${D_BLUE}devcorex-web.vercel.app/"
  echo
}
