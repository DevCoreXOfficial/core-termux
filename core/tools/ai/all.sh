#!/bin/bash

import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_ai.log"

AI_TOOLS=(
  "qwen-code"
  "gemini-cli"
  "claude-code"
  "mistral-vibe"
  "openclaude"
  "openclaw"
  "ollama"
  "codex"
  "opencode"
  "mimocode"
  "engram"
  "codegraph"
  "pi"
  "antigravity-cli"
  "gentle-ai"
  "minimax-cli"
  "gga"
  "hermes-agent"
  "kimi-code"
)

source "$(dirname "$BASH_SOURCE")/qwen-code/install.sh"
source "$(dirname "$BASH_SOURCE")/gemini-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/claude-code/install.sh"
source "$(dirname "$BASH_SOURCE")/mistral-vibe/install.sh"
source "$(dirname "$BASH_SOURCE")/openclaude/install.sh"
source "$(dirname "$BASH_SOURCE")/openclaw/install.sh"
source "$(dirname "$BASH_SOURCE")/ollama/install.sh"
source "$(dirname "$BASH_SOURCE")/codex/install.sh"
source "$(dirname "$BASH_SOURCE")/opencode/install.sh"
source "$(dirname "$BASH_SOURCE")/mimocode/install.sh"
source "$(dirname "$BASH_SOURCE")/engram/install.sh"
source "$(dirname "$BASH_SOURCE")/codegraph/install.sh"
source "$(dirname "$BASH_SOURCE")/pi/install.sh"
source "$(dirname "$BASH_SOURCE")/antigravity-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/gentle-ai/install.sh"
source "$(dirname "$BASH_SOURCE")/minimax-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/gga/install.sh"
source "$(dirname "$BASH_SOURCE")/hermes-agent/install.sh"
source "$(dirname "$BASH_SOURCE")/kimi-code/install.sh"

install_all_ai_tools() {
  local installed_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      install_qwen_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      install_gemini_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      install_claude_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      install_mistral_vibe
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      install_openclaude
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      install_openclaw
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      install_ollama
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      install_codex
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      install_opencode
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      install_mimocode
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      install_engram
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      install_codegraph
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      install_pi
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      install_antigravity_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      install_gentle_ai
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      install_minimax_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      install_gga
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      install_hermes_agent
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      install_kimi_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

uninstall_all_ai_tools() {
  local uninstalled_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      uninstall_qwen_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      uninstall_gemini_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      uninstall_claude_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      uninstall_mistral_vibe
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      uninstall_openclaude
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      uninstall_openclaw
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      uninstall_ollama
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      uninstall_codex
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      uninstall_opencode
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      uninstall_mimocode
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      uninstall_engram
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      uninstall_codegraph
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      uninstall_pi
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      uninstall_antigravity_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      uninstall_gentle_ai
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      uninstall_minimax_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      uninstall_gga
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      uninstall_hermes_agent
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      uninstall_kimi_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

update_all_ai_tools() {
  local updated_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      update_qwen_code
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      update_gemini_cli
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      update_claude_code
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      update_mistral_vibe
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      update_openclaude
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      update_openclaw
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      update_ollama
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      update_codex
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      update_opencode
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      update_mimocode
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      update_engram
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      update_codegraph
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      update_pi
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      update_antigravity_cli
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      update_gentle_ai
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      update_minimax_cli
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      update_gga
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      update_hermes_agent
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      update_kimi_code
      case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

reinstall_all_ai_tools() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      reinstall_qwen_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      reinstall_gemini_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      reinstall_claude_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      reinstall_mistral_vibe
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      reinstall_openclaude
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      reinstall_openclaw
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      reinstall_ollama
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      reinstall_codex
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      reinstall_opencode
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      reinstall_mimocode
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      reinstall_engram
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      reinstall_codegraph
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      reinstall_pi
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      reinstall_antigravity_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      reinstall_gentle_ai
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      reinstall_minimax_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      reinstall_gga
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      reinstall_hermes_agent
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      reinstall_kimi_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}
