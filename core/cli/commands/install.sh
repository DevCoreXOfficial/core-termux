#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

install_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Core Install"
    echo
    log_info "Usage: core install <target>"
    log_info "Usage: core install <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "full       - Install everything (recommended)"
    list_item "language   - Language packages (Node.js, Python, Perl, PHP, Rust, C, C++, Go)"
    list_item "db         - Databases (PostgreSQL, MariaDB, SQLite, MongoDB)"
    list_item "ai         - AI tools (OpenCode, Gentle AI, Claude Code, etc.)"
    list_item "editor     - Code editor (Neovim + NvChad)"
    list_item "tools      - Development tools"
    list_item "node       - Node.js global modules (npm packages)"
    list_item "shell      - ZSH + Oh My Zsh + plugins"
    list_item "ui         - Termux UI (font, cursor, extra-keys, banner)"
    list_item "automation - Automation Tools (n8n)"

    echo
    log_info "Install specific tools with flags:"
    echo
    list_item "core install ai --qwen-code --ollama"
    list_item "core install db --postgresql --sqlite"
    list_item "core install tools --gh --fzf --jq"
    list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
    echo
    return
  fi

  # Separate module target from tool flags
  local module_target=""
  local -a tool_flags=()

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      # Remove -- prefix and convert to lowercase
      local flag="${arg#--}"
      tool_flags+=("$flag")
    elif [[ -z "$module_target" ]]; then
      module_target="$arg"
    fi
  done

  # If no module target specified, show error
  if [[ -z "$module_target" ]]; then
    log_error "No target specified"
    echo "Run 'core install' to see available targets"
    return 1
  fi

  # If no tool flags, install entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _install_full_module "$module_target"
  else
    # Install specific tools
    _install_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Install entire module (original behavior)
_install_full_module() {
  local target="$1"

  case "$target" in
  full)
    separator
    box "Installing Complete Environment"
    separator
    echo

    import "@/modules/language"
    import "@/modules/db"
    import "@/modules/ai"
    import "@/modules/editor"
    import "@/modules/tools"
    import "@/modules/node-modules"
    import "@/modules/shell"
    import "@/modules/ui"
    import "@/modules/automation"

    install_language
    install_db
    install_ai
    install_editor
    install_tools
    install_node
    install_shell
    setup_ui
    install_automation

    separator
    log_success "Complete environment installed successfully"
    separator
    echo
    log_warn "Please restart Termux to apply all changes"
    echo
    ;;
  db)
    import "@/modules/db"
    install_db
    ;;
  ai)
    import "@/modules/ai"
    install_ai
    ;;
  editor)
    import "@/modules/editor"
    install_editor
    ;;
  language)
    import "@/modules/language"
    install_language
    ;;
  tools)
    import "@/modules/tools"
    install_tools
    ;;
  node)
    import "@/modules/node-modules"
    install_node
    ;;
  shell)
    import "@/modules/shell"
    install_shell
    ;;
  ui)
    import "@/modules/ui"
    setup_ui
    ;;
  automation)
    import "@/modules/automation"
    install_automation
    ;;
  *)
    log_warn "Unknown install target: $target"
    echo "Run 'core install' to see available targets"
    ;;
  esac
}

# Install specific tools within a module
_install_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
        install_claude_code
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
        install_opencode
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      mimocode)
        install_mimocode
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
        loading "Installing Pi Coding Agent" install_pi
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      antigravity-cli)
        install_antigravity_cli
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      minimax-cli)
        loading "Installing Minimax CLI" install_minimax_cli
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        install_gentle_ai
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      gga)
        install_gga
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
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count AI tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        loading "Installing PostgreSQL" install_postgresql
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        loading "Installing MariaDB" install_mariadb
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        loading "Installing SQLite" install_sqlite
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        loading "Installing MongoDB" install_mongodb
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count database(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to install"
    fi
    echo
    ;;
  tools)
    import "@/tools/tools/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        loading "Installing GitHub CLI" install_gh
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        loading "Installing Wget" install_wget
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        loading "Installing Curl" install_curl
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        loading "Installing LSD" install_lsd
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        loading "Installing Bat" install_bat
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        loading "Installing Proot" install_proot
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        loading "Installing Ncurses Utils" install_ncurses
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        loading "Installing Tmate" install_tmate
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        loading "Installing Cloudflared" install_cloudflared
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        loading "Installing Translate Shell" install_translate
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        loading "Installing html2text" install_html2text
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        loading "Installing jq" install_jq
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        loading "Installing bc" install_bc
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        loading "Installing Tree" install_tree
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        loading "Installing Fzf" install_fzf
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        loading "Installing ImageMagick" install_imagemagick
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        loading "Installing Shfmt" install_shfmt
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        loading "Installing Make" install_make
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        loading "Installing udocker" install_udocker
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  node)
    import "@/tools/node/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        loading "Installing TypeScript" install_typescript
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        loading "Installing NestJS CLI" install_nestjs
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        loading "Installing Prettier" install_prettier
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        loading "Installing Live Server" install_live_server
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        loading "Installing Localtunnel" install_localtunnel
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        loading "Installing Vercel CLI" install_vercel
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        loading "Installing Markserv" install_markserv
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        loading "Installing PSQL Format" install_psqlformat
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        loading "Installing NPM Check Updates" install_ncu
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        loading "Installing Ngrok" install_ngrok
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count Node.js module(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to install"
    fi
    echo
    ;;
  language)
    import "@/tools/language/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        loading "Installing Node.js LTS" install_nodejs
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        loading "Installing Python" install_python
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        loading "Installing Perl" install_perl
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        loading "Installing PHP" install_php
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        loading "Installing Rust" install_rust
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        loading "Installing C/C++ (clang)" install_clang
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        loading "Installing Go (golang)" install_golang
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count language(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to install"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count plugin(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to install"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        loading "Installing Neovim" install_neovim
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        loading "Installing NvChad" install_nvchad
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count editor component(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to install"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        loading "Installing Meslo Nerd Font" install_font
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        loading "Configuring Extra Keys" install_extra_keys
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        loading "Configuring Cursor Color" install_cursor
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        loading "Installing Core-Termux Banner" install_banner
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count UI component(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to install"
    fi
    echo
    ;;
  automation)
    import "@/tools/automation/all"
    local installed_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        loading "Installing n8n" install_n8n
        case $? in 0) ((installed_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $installed_count -gt 0 ]]; then
      log_success "$installed_count automation tool(s) installed"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to install"
    fi
    echo
    ;;
  *)
    log_warn "Unknown install target: $module"
    echo "Run 'core install' to see available targets"
    ;;
  esac
}
