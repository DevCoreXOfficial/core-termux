#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/install_ai.log"

install_ai() {
  separator
  box "Installing AI Tools"
  separator
  echo

  log_info "Installing AI tools..."
  echo
  log_info "☕ Grab a coffee! This process typically takes 1h-2h hours."
  log_info "   Don't worry, it's normal for this to take a while..."
  echo

  mkdir -p "$(dirname "$LOG_FILE")"

  _install_ai_tools_wrapper
  log_success "AI tools installed successfully"
  separator
  echo
  list_item "Qwen Code ${GRAY}(${D_GREEN}qwen${GRAY})"
  list_item "Gemini CLI ${GRAY}(${D_GREEN}gemini${GRAY})"
  list_item "Mistral Vibe ${GRAY}(${D_GREEN}vibe${GRAY})"
  list_item "OpenClaude ${GRAY}(${D_GREEN}openclaude${GRAY})"
  list_item "Claude Code ${GRAY}(${D_GREEN}claude${GRAY})"
  list_item "OpenClaw ${GRAY}(${D_GREEN}openclaw${GRAY})"
  list_item "Ollama ${GRAY}(${D_GREEN}ollama${GRAY})"
  list_item "Codex ${GRAY}(${D_GREEN}codex${GRAY})"
  list_item "OpenCode ${GRAY}(${D_GREEN}opencode${GRAY})"
  list_item "MiMo Code ${GRAY}(${D_GREEN}mimocode${GRAY})"
  list_item "Engram ${GRAY}(${D_GREEN}engram${GRAY})"
  list_item "CodeGraph ${GRAY}(${D_GREEN}codegraph${GRAY})"
  list_item "Pi ${GRAY}(${D_GREEN}pi${GRAY})"
  list_item "Antigravity CLI ${GRAY}(${D_GREEN}agy${GRAY})"
  list_item "Minimax CLI ${GRAY}(${D_GREEN}mmx${GRAY})"
  list_item "Gentle AI ${GRAY}(${D_GREEN}gentle-ai${GRAY})"
  list_item "GGA ${GRAY}(${D_GREEN}gga${GRAY})"
  list_item "Hermes Agent ${GRAY}(${D_GREEN}hermes${GRAY})"
  list_item "Kimi Code ${GRAY}(${D_GREEN}kimi${GRAY})"
  list_item "Command Code ${GRAY}(${D_GREEN}command-code${GRAY})"
  list_item "Freebuff ${GRAY}(${D_GREEN}freebuff${GRAY})"
  echo
}

_install_ai_tools_wrapper() {
  import "@/tools/ai/all"
  install_all_ai_tools
}

uninstall_ai() {
  if ! command -v opencode &>/dev/null && ! command -v freebuff &>/dev/null; then
    log_info "AI Tools are not installed"
    return 0
  fi
  separator
  box "Uninstalling AI Tools"
  separator
  echo

  log_info "Uninstalling AI tools..."

  _uninstall_ai_tools_wrapper
  log_success "AI tools uninstalled"
}

_uninstall_ai_tools_wrapper() {
  import "@/tools/ai/all"
  uninstall_all_ai_tools
}

update_ai() {
  separator
  box "Updating AI Tools"
  separator
  echo

  log_info "Updating AI tools..."

  _update_ai_tools_wrapper
  log_success "AI tools updated"
}

_update_ai_tools_wrapper() {
  import "@/tools/ai/all"
  update_all_ai_tools
}

reinstall_ai() {
  separator
  box "Reinstalling AI Tools"
  separator
  echo

  log_info "Reinstalling AI tools..."
  echo

  _reinstall_ai_tools_wrapper
  log_success "AI tools reinstalled successfully"
  separator
  echo
  list_item "Qwen Code"
  list_item "Gemini CLI"
  list_item "Mistral Vibe"
  list_item "OpenClaude"
  list_item "Claude Code"
  list_item "OpenClaw"
  list_item "Ollama"
  list_item "Codex"
  list_item "OpenCode"
  list_item "MiMo Code"
  list_item "Engram"
  list_item "CodeGraph"
  list_item "Pi"
  list_item "Antigravity CLI"
  list_item "Minimax CLI"
  list_item "Gentle AI"
  list_item "GGA"
  list_item "Hermes Agent"
  list_item "Kimi Code"
  list_item "Command Code"
  list_item "Freebuff"
  echo
}

_reinstall_ai_tools_wrapper() {
  import "@/tools/ai/all"
  reinstall_all_ai_tools
}
