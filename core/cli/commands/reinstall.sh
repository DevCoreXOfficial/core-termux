#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

reinstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Core Reinstall"
    echo
    log_info "Usage: core reinstall <target>"
    log_info "Usage: core reinstall <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "lang       - Reinstall language packages"
    list_item "db         - Reinstall databases"
    list_item "ai         - Reinstall AI tools"
    list_item "editor     - Reinstall code editor"
    list_item "dev        - Reinstall development tools"
    list_item "npm        - Reinstall Node.js global modules"
    list_item "shell      - Reinstall ZSH + Oh My Zsh"
    list_item "ui         - Reinstall Termux UI"
    list_item "auto       - Reinstall automation tools"
    echo
    log_info "Reinstall specific tools with flags:"
    echo
    list_item "core reinstall ai --qwen-code --ollama"
    list_item "core reinstall db --postgresql --sqlite"
    list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
    echo
    log_warn "This will uninstall and then install the selected components!"
    echo
    return
  fi

  local module_target=""
  local -a tool_flags=()

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      local flag="${arg#--}"
      tool_flags+=("$flag")
    elif [[ -z "$module_target" ]]; then
      module_target="$arg"
    fi
  done

  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'core reinstall' to see available targets"
    return 1
  fi

  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _reinstall_full_module "$module_target"
  else
    _reinstall_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

_reinstall_full_module() {
  local target="$1"

  case "$target" in
  lang)
    import "@/modules/lang"
    reinstall_lang
    ;;
  db)
    import "@/modules/db"
    reinstall_db
    ;;
  ai)
    import "@/modules/ai"
    reinstall_ai
    ;;
  editor)
    import "@/modules/editor"
    reinstall_editor
    ;;
  dev)
    import "@/modules/dev"
    reinstall_dev
    ;;
  npm)
    import "@/modules/npm"
    reinstall_npm
    ;;
  shell)
    import "@/modules/shell"
    reinstall_shell
    ;;
  ui)
    import "@/modules/ui"
    reinstall_ui
    ;;
  auto)
    import "@/modules/auto"
    reinstall_auto
    ;;
  *)
    log_warn "Unknown reinstall target: $target"
    echo "Run 'core reinstall' to see available targets"
    ;;
  esac
}

_reinstall_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
      minimax-cli)
        reinstall_minimax_cli
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        reinstall_gentle_ai
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
      command-code)
        reinstall_command_code
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      freebuff)
        reinstall_freebuff
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count AI tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        reinstall_postgresql
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        reinstall_mariadb
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        reinstall_sqlite
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        reinstall_mongodb
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count database(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to reinstall"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        reinstall_gh
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        reinstall_wget
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        reinstall_curl
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        reinstall_lsd
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        reinstall_bat
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        reinstall_proot
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        reinstall_ncurses
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        reinstall_tmate
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        reinstall_cloudflared
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        reinstall_translate
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        reinstall_html2text
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        reinstall_jq
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        reinstall_bc
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        reinstall_tree
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        reinstall_fzf
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        reinstall_imagemagick
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        reinstall_shfmt
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        reinstall_make
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        reinstall_udocker
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        reinstall_typescript
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        reinstall_nestjs
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        reinstall_prettier
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        reinstall_live_server
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        reinstall_localtunnel
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        reinstall_vercel
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        reinstall_markserv
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        reinstall_psqlformat
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        reinstall_ncu
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        reinstall_ngrok
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count Node.js module(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to reinstall"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        reinstall_npmjs
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        reinstall_python
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        reinstall_perl
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        reinstall_php
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        reinstall_rust
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        reinstall_clang
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        reinstall_golang
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count language(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to reinstall"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      powerlevel10k)
        reinstall_powerlevel10k
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-defer)
        reinstall_zsh_defer
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-autosuggestions)
        reinstall_zsh_autosuggestions
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-syntax-highlighting)
        reinstall_zsh_syntax_highlighting
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      history-substring)
        reinstall_history_substring
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-completions)
        reinstall_zsh_completions
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      fzf-tab)
        reinstall_fzf_tab
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      you-should-use)
        reinstall_you_should_use
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-autopair)
        reinstall_zsh_autopair
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      better-npm)
        reinstall_better_npm
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count plugin(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to reinstall"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        reinstall_neovim
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        reinstall_nvchad
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count editor component(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to reinstall"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        reinstall_font
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        reinstall_extra_keys
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        reinstall_cursor
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        reinstall_banner
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count UI component(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to reinstall"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        reinstall_n8n
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $reinstalled_count -gt 0 ]]; then
      log_success "$reinstalled_count automation tool(s) reinstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to reinstall"
    fi
    echo
    ;;
  *)
    log_warn "Unknown reinstall target: $module"
    echo "Run 'core reinstall' to see available targets"
    ;;
  esac
}
