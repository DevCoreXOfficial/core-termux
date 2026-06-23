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
        loading "Reinstalling Pi Coding Agent" reinstall_pi
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      antigravity-cli)
        loading "Reinstalling Antigravity CLI" reinstall_antigravity_cli
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      minimax-cli)
        loading "Reinstalling Minimax CLI" reinstall_minimax_cli
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        loading "Reinstalling Gentle AI" reinstall_gentle_ai
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      gga)
        loading "Reinstalling GGA" reinstall_gga
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      hermes-agent)
        reinstall_hermes_agent
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      kimi-code)
        loading "Reinstalling Kimi Code" reinstall_kimi_code
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
        loading "Reinstalling PostgreSQL" reinstall_postgresql
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        loading "Reinstalling MariaDB" reinstall_mariadb
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        loading "Reinstalling SQLite" reinstall_sqlite
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        loading "Reinstalling MongoDB" reinstall_mongodb
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
        loading "Reinstalling GitHub CLI" reinstall_gh
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        loading "Reinstalling Wget" reinstall_wget
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        loading "Reinstalling Curl" reinstall_curl
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        loading "Reinstalling LSD" reinstall_lsd
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        loading "Reinstalling Bat" reinstall_bat
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        loading "Reinstalling Proot" reinstall_proot
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        loading "Reinstalling Ncurses Utils" reinstall_ncurses
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        loading "Reinstalling Tmate" reinstall_tmate
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        loading "Reinstalling Cloudflared" reinstall_cloudflared
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        loading "Reinstalling Translate Shell" reinstall_translate
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        loading "Reinstalling html2text" reinstall_html2text
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        loading "Reinstalling jq" reinstall_jq
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        loading "Reinstalling bc" reinstall_bc
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        loading "Reinstalling Tree" reinstall_tree
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        loading "Reinstalling Fzf" reinstall_fzf
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        loading "Reinstalling ImageMagick" reinstall_imagemagick
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        loading "Reinstalling Shfmt" reinstall_shfmt
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        loading "Reinstalling Make" reinstall_make
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        loading "Reinstalling Udocker" reinstall_udocker
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
        loading "Reinstalling TypeScript" reinstall_typescript
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        loading "Reinstalling NestJS CLI" reinstall_nestjs
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        loading "Reinstalling Prettier" reinstall_prettier
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        loading "Reinstalling Live Server" reinstall_live_server
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        loading "Reinstalling Localtunnel" reinstall_localtunnel
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        loading "Reinstalling Vercel CLI" reinstall_vercel
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        loading "Reinstalling Markserv" reinstall_markserv
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        loading "Reinstalling PSQL Format" reinstall_psqlformat
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        loading "Reinstalling NPM Check Updates" reinstall_ncu
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        loading "Reinstalling Ngrok" reinstall_ngrok
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
        loading "Reinstalling Node.js LTS" reinstall_npmjs
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        loading "Reinstalling Python" reinstall_python
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        loading "Reinstalling Perl" reinstall_perl
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        loading "Reinstalling PHP" reinstall_php
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        loading "Reinstalling Rust" reinstall_rust
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        loading "Reinstalling C/C++ (clang)" reinstall_clang
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        loading "Reinstalling Go (golang)" reinstall_golang
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
        loading "Reinstalling Neovim" reinstall_neovim
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        loading "Reinstalling NvChad" reinstall_nvchad
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
        loading "Reinstalling Meslo Nerd Font" reinstall_font
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        loading "Reinstalling Extra Keys" reinstall_extra_keys
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        loading "Reinstalling Cursor Color" reinstall_cursor
        case $? in 0) ((reinstalled_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        loading "Reinstalling Core-Termux Banner" reinstall_banner
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
        loading "Reinstalling n8n" reinstall_n8n
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
