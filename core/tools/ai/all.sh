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
  "qoder"
  "kilocode-cli"
  "kimchi"
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
  "command-code"
  "freebuff"
  "ctx7"
  "openspec"
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
source "$(dirname "$BASH_SOURCE")/qoder/install.sh"
source "$(dirname "$BASH_SOURCE")/kilocode-cli/install.sh"
source "$(dirname "$BASH_SOURCE")/kimchi/install.sh"
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
source "$(dirname "$BASH_SOURCE")/command-code/install.sh"
source "$(dirname "$BASH_SOURCE")/freebuff/install.sh"
source "$(dirname "$BASH_SOURCE")/ctx7/install.sh"
source "$(dirname "$BASH_SOURCE")/openspec/install.sh"

install_all_ai_tools() {
  local installed_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      loading "Installing Qwen Code" install_qwen_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      loading "Installing Gemini CLI" install_gemini_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      loading "Installing Claude Code" install_claude_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      loading "Installing Mistral Vibe" install_mistral_vibe
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      loading "Installing OpenClaude" install_openclaude
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      loading "Installing OpenClaw" install_openclaw
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      loading "Installing Ollama" install_ollama
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      loading "Installing Codex CLI" install_codex
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      loading "Installing OpenCode" install_opencode
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    qoder)
      loading "Installing Qoder" install_qoder
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    kilocode-cli)
      loading "Installing Kilo Code CLI" install_kilocode_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    kimchi)
      loading "Installing Kimchi" install_kimchi
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      loading "Installing MiMo Code" install_mimocode
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      loading "Installing Engram" install_engram
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      loading "Installing CodeGraph" install_codegraph
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      loading "Installing Pi" install_pi
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      loading "Installing Antigravity CLI" install_antigravity_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      loading "Installing Gentle AI" install_gentle_ai
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      loading "Installing Minimax CLI" install_minimax_cli
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      loading "Installing GGA" install_gga
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      loading "Installing Hermes Agent" install_hermes_agent
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      loading "Installing Kimi Code" install_kimi_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    command-code)
      loading "Installing Command Code" install_command_code
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    freebuff)
      loading "Installing Freebuff" install_freebuff
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    ctx7)
      loading "Installing Context7" install_ctx7
      case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
      ;;
    openspec)
      loading "Installing OpenSpec" install_openspec
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
      loading "Uninstalling Qwen Code" uninstall_qwen_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      loading "Uninstalling Gemini CLI" uninstall_gemini_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      loading "Uninstalling Claude Code" uninstall_claude_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      loading "Uninstalling Mistral Vibe" uninstall_mistral_vibe
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      loading "Uninstalling OpenClaude" uninstall_openclaude
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      loading "Uninstalling OpenClaw" uninstall_openclaw
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      loading "Uninstalling Ollama" uninstall_ollama
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      loading "Uninstalling Codex CLI" uninstall_codex
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      loading "Uninstalling OpenCode" uninstall_opencode
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    qoder)
      loading "Uninstalling Qoder" uninstall_qoder
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kilocode-cli)
      loading "Uninstalling Kilo Code CLI" uninstall_kilocode_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimchi)
      loading "Uninstalling Kimchi" uninstall_kimchi
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      loading "Uninstalling MiMo Code" uninstall_mimocode
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      loading "Uninstalling Engram" uninstall_engram
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      loading "Uninstalling CodeGraph" uninstall_codegraph
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      loading "Uninstalling Pi" uninstall_pi
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      loading "Uninstalling Antigravity CLI" uninstall_antigravity_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      loading "Uninstalling Gentle AI" uninstall_gentle_ai
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      loading "Uninstalling Minimax CLI" uninstall_minimax_cli
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      loading "Uninstalling GGA" uninstall_gga
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      loading "Uninstalling Hermes Agent" uninstall_hermes_agent
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      loading "Uninstalling Kimi Code" uninstall_kimi_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    command-code)
      loading "Uninstalling Command Code" uninstall_command_code
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    freebuff)
      loading "Uninstalling Freebuff" uninstall_freebuff
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ctx7)
      loading "Uninstalling Context7" uninstall_ctx7
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openspec)
      loading "Uninstalling OpenSpec" uninstall_openspec
      case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}

update_all_ai_tools() {
  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      update_qwen_code
      ;;
    gemini-cli)
      update_gemini_cli
      ;;
    claude-code)
      update_claude_code
      ;;
    mistral-vibe)
      update_mistral_vibe
      ;;
    openclaude)
      update_openclaude
      ;;
    openclaw)
      update_openclaw
      ;;
    ollama)
      update_ollama
      ;;
    codex)
      update_codex
      ;;
    opencode)
      update_opencode
      ;;
    qoder)
      update_qoder
      ;;
    kilocode-cli)
      update_kilocode_cli
      ;;
    kimchi)
      update_kimchi
      ;;
    mimocode)
      update_mimocode
      ;;
    engram)
      update_engram
      ;;
    codegraph)
      update_codegraph
      ;;
    pi)
      update_pi
      ;;
    antigravity-cli)
      update_antigravity_cli
      ;;
    gentle-ai)
      update_gentle_ai
      ;;
    minimax-cli)
      update_minimax_cli
      ;;
    gga)
      update_gga
      ;;
    hermes-agent)
      update_hermes_agent
      ;;
    kimi-code)
      update_kimi_code
      ;;
    command-code)
      update_command_code
      ;;
    freebuff)
      update_freebuff
      ;;
    ctx7)
      update_ctx7
      ;;
    openspec)
      update_openspec
      ;;
    esac
  done
  echo
}

reinstall_all_ai_tools() {
  local reinstalled_count=0
  local failed_count=0

  for tool in "${AI_TOOLS[@]}"; do
    case "$tool" in
    qwen-code)
      loading "Reinstalling Qwen Code" reinstall_qwen_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gemini-cli)
      loading "Reinstalling Gemini CLI" reinstall_gemini_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    claude-code)
      loading "Reinstalling Claude Code" reinstall_claude_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mistral-vibe)
      loading "Reinstalling Mistral Vibe" reinstall_mistral_vibe
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaude)
      loading "Reinstalling OpenClaude" reinstall_openclaude
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openclaw)
      loading "Reinstalling OpenClaw" reinstall_openclaw
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ollama)
      loading "Reinstalling Ollama" reinstall_ollama
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codex)
      loading "Reinstalling Codex CLI" reinstall_codex
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    opencode)
      loading "Reinstalling OpenCode" reinstall_opencode
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    qoder)
      loading "Reinstalling Qoder" reinstall_qoder
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kilocode-cli)
      loading "Reinstalling Kilo Code CLI" reinstall_kilocode_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimchi)
      loading "Reinstalling Kimchi" reinstall_kimchi
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    mimocode)
      loading "Reinstalling MiMo Code" reinstall_mimocode
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    engram)
      loading "Reinstalling Engram" reinstall_engram
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    codegraph)
      loading "Reinstalling CodeGraph" reinstall_codegraph
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    pi)
      loading "Reinstalling Pi" reinstall_pi
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    antigravity-cli)
      loading "Reinstalling Antigravity CLI" reinstall_antigravity_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gentle-ai)
      loading "Reinstalling Gentle AI" reinstall_gentle_ai
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    minimax-cli)
      loading "Reinstalling Minimax CLI" reinstall_minimax_cli
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    gga)
      loading "Reinstalling GGA" reinstall_gga
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    hermes-agent)
      loading "Reinstalling Hermes Agent" reinstall_hermes_agent
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    kimi-code)
      loading "Reinstalling Kimi Code" reinstall_kimi_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    command-code)
      loading "Reinstalling Command Code" reinstall_command_code
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    freebuff)
      loading "Reinstalling Freebuff" reinstall_freebuff
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    ctx7)
      loading "Reinstalling Context7" reinstall_ctx7
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    openspec)
      loading "Reinstalling OpenSpec" reinstall_openspec
      case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
      ;;
    esac
  done

  return 0
}
