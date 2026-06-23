#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

uninstall_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Core Uninstall"
    echo
    log_info "Usage: core uninstall <target>"
    log_info "Usage: core uninstall <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "lang       - Remove language packages"
    list_item "db         - Remove databases"
    list_item "ai         - Remove AI tools"
    list_item "editor     - Remove code editor"
    list_item "dev        - Remove development tools"
    list_item "npm        - Remove Node.js global modules"
    list_item "shell      - Remove ZSH + Oh My Zsh"
    list_item "ui         - Restore Termux UI to default"
    list_item "auto       - Remove automation tools"
    echo
    log_info "Uninstall specific tools with flags:"
    echo
    list_item "core uninstall ai --qwen-code --ollama"
    list_item "core uninstall db --postgresql --sqlite"
    list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
    echo
    log_warn "Warning: This will remove installed packages and configurations!"
    echo
    return
  fi

  # Separate module target from tool flags
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

  # If no module target specified, show error
  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'core uninstall' to see available targets"
    return 1
  fi

  # If no tool flags, uninstall entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _uninstall_full_module "$module_target"
  else
    # Uninstall specific tools
    _uninstall_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Uninstall entire module (original behavior)
_uninstall_full_module() {
  local target="$1"

  case "$target" in
  lang)
    import "@/modules/lang"
    uninstall_lang
    ;;
  db)
    import "@/modules/db"
    uninstall_db
    ;;
  ai)
    import "@/modules/ai"
    uninstall_ai
    ;;
  editor)
    import "@/modules/editor"
    uninstall_editor
    ;;
  dev)
    import "@/modules/dev"
    uninstall_dev
    ;;
  npm)
    import "@/modules/npm"
    uninstall_npm
    ;;
  shell)
    import "@/modules/shell"
    uninstall_shell
    ;;
  ui)
    import "@/modules/ui"
    uninstall_ui
    ;;
  auto)
    import "@/modules/auto"
    uninstall_auto
    ;;
  *)
    log_warn "Unknown uninstall target: $target"
    echo "Run 'core uninstall' to see available targets"
    ;;
  esac
}

# Uninstall specific tools within a module
_uninstall_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
        loading "Uninstalling Codex" uninstall_codex
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      opencode)
        loading "Uninstalling OpenCode" uninstall_opencode
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
        loading "Uninstalling Pi Coding Agent" uninstall_pi
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      antigravity-cli)
        loading "Uninstalling Antigravity CLI" uninstall_antigravity_cli
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      minimax-cli)
        loading "Uninstalling Minimax CLI" uninstall_minimax_cli
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        loading "Uninstalling gentle-ai" uninstall_gentle_ai
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
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count AI tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        loading "Uninstalling PostgreSQL" uninstall_postgresql
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        loading "Uninstalling MariaDB" uninstall_mariadb
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        loading "Uninstalling SQLite" uninstall_sqlite
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        loading "Uninstalling MongoDB" uninstall_mongodb
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count database(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to uninstall"
    fi
    echo
    ;;
  dev)
    import "@/tools/dev/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        loading "Uninstalling GitHub CLI" uninstall_gh
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        loading "Uninstalling Wget" uninstall_wget
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        loading "Uninstalling Curl" uninstall_curl
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        loading "Uninstalling LSD" uninstall_lsd
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        loading "Uninstalling Bat" uninstall_bat
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        loading "Uninstalling Proot" uninstall_proot
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        loading "Uninstalling Ncurses Utils" uninstall_ncurses
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        loading "Uninstalling Tmate" uninstall_tmate
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        loading "Uninstalling Cloudflared" uninstall_cloudflared
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        loading "Uninstalling Translate Shell" uninstall_translate
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        loading "Uninstalling html2text" uninstall_html2text
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        loading "Uninstalling jq" uninstall_jq
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        loading "Uninstalling bc" uninstall_bc
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        loading "Uninstalling Tree" uninstall_tree
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        loading "Uninstalling Fzf" uninstall_fzf
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        loading "Uninstalling ImageMagick" uninstall_imagemagick
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        loading "Uninstalling Shfmt" uninstall_shfmt
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        loading "Uninstalling Make" uninstall_make
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        loading "Uninstalling Udocker" uninstall_udocker
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  npm)
    import "@/tools/npm/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        loading "Uninstalling TypeScript" uninstall_typescript
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        loading "Uninstalling NestJS CLI" uninstall_nestjs
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        loading "Uninstalling Prettier" uninstall_prettier
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        loading "Uninstalling Live Server" uninstall_live_server
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        loading "Uninstalling Localtunnel" uninstall_localtunnel
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        loading "Uninstalling Vercel CLI" uninstall_vercel
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        loading "Uninstalling Markserv" uninstall_markserv
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        loading "Uninstalling PSQL Format" uninstall_psqlformat
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        loading "Uninstalling NPM Check Updates" uninstall_ncu
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        loading "Uninstalling Ngrok" uninstall_ngrok
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count Node.js module(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to uninstall"
    fi
    echo
    ;;
  lang)
    import "@/tools/lang/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        loading "Uninstalling Node.js LTS" uninstall_npmjs
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        loading "Uninstalling Python" uninstall_python
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        loading "Uninstalling Perl" uninstall_perl
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        loading "Uninstalling PHP" uninstall_php
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        loading "Uninstalling Rust" uninstall_rust
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        loading "Uninstalling C/C++ (clang)" uninstall_clang
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        loading "Uninstalling Go (golang)" uninstall_golang
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count language(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to uninstall"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count plugin(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to uninstall"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        loading "Uninstalling Neovim" uninstall_neovim
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        loading "Uninstalling NvChad" uninstall_nvchad
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count editor component(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to uninstall"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        loading "Uninstalling Meslo Nerd Font" uninstall_font
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        loading "Uninstalling Extra Keys" uninstall_extra_keys
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        loading "Uninstalling Cursor Color" uninstall_cursor
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        loading "Uninstalling Core-Termux Banner" uninstall_banner
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count UI component(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to uninstall"
    fi
    echo
    ;;
  auto)
    import "@/tools/auto/all"
    local uninstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        loading "Uninstalling n8n" uninstall_n8n
        case $? in 0) ((uninstalled_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $uninstalled_count -gt 0 ]]; then
      log_success "$uninstalled_count automation tool(s) uninstalled"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to uninstall"
    fi
    echo
    ;;
  *)
    log_warn "Unknown uninstall target: $module"
    echo "Run 'core uninstall' to see available targets"
    ;;
  esac
}
