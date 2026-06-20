#!/data/data/com.termux/files/usr/bin/bash

import "@/utils/log"
import "@/utils/colors"

update_main() {

  if [[ $# -eq 0 ]]; then
    echo
    box "Core Update"
    echo
    log_info "Usage: core update <target>"
    log_info "Usage: core update <target> --tool1 --tool2"
    echo
    log_info "Available targets:"
    echo
    list_item "all        - Update framework + all installed packages"
    list_item "core       - Update only Core-Termux framework"
    list_item "language   - Update language packages (pkg upgrade)"
    list_item "db         - Update databases"
    list_item "ai         - Update AI tools (npm/pip/pkg)"
    list_item "editor     - Update Neovim configuration"
    list_item "tools      - Update development tools"
    list_item "node       - Update Node.js global modules"
    list_item "shell      - Update ZSH plugins"
    list_item "ui         - Update Termux UI"
    list_item "automation - Update Automation Tools"
    echo
    log_info "Update specific tools with flags:"
    echo
    list_item "core update ai --qwen-code --ollama"
    list_item "core update db --postgresql --sqlite"
    list_item "Run ${D_CYAN}core list <target>${NC} to see all available tools"
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
    echo "Run 'core update' to see available targets"
    return 1
  fi

  # If no tool flags, update entire module (original behavior)
  if [[ ${#tool_flags[@]} -eq 0 ]]; then
    _update_full_module "$module_target"
  else
    # Update specific tools
    _update_specific_tools "$module_target" "${tool_flags[@]}"
  fi
}

# Update entire module (original behavior)
_update_full_module() {
  local target="$1"

  case "$target" in
  all)
    separator
    box "Updating Everything"
    separator
    echo

    update_core

    import "@/modules/language"
    import "@/modules/db"
    import "@/modules/ai"
    import "@/modules/editor"
    import "@/modules/tools"
    import "@/modules/node-modules"
    import "@/modules/shell"
    import "@/modules/ui"
    import "@/modules/automation"

    update_language
    update_db
    update_ai
    update_editor
    update_tools
    update_node
    update_shell
    update_ui
    update_automation

    separator
    log_success "All updates completed"
    separator
    echo
    ;;
  core)
    update_core
    ;;
  language)
    import "@/modules/language"
    update_language
    ;;
  db)
    import "@/modules/db"
    update_db
    ;;
  ai)
    import "@/modules/ai"
    update_ai
    ;;
  editor)
    import "@/modules/editor"
    update_editor
    ;;
  tools)
    import "@/modules/tools"
    update_tools
    ;;
  node)
    import "@/modules/node-modules"
    update_node
    ;;
  shell)
    import "@/modules/shell"
    update_shell
    ;;
  ui)
    import "@/modules/ui"
    update_ui
    ;;
  automation)
    import "@/modules/automation"
    update_automation
    ;;
  *)
    log_warn "Unknown update target: $target"
    echo "Run 'core update' to see available targets"
    ;;
  esac
}

# Update specific tools within a module
_update_specific_tools() {
  local module="$1"
  shift
  local -a tools=("$@")

  case "$module" in
  ai)
    import "@/tools/ai/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      qwen-code)
        loading "Updating Qwen Code" update_qwen_code
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      gemini-cli)
        loading "Updating Gemini CLI" update_gemini_cli
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      claude-code)
        loading "Updating Claude Code" update_claude_code
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mistral-vibe)
        loading "Updating Mistral Vibe" update_mistral_vibe
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      openclaude)
        loading "Updating OpenClaude" update_openclaude
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      openclaw)
        loading "Updating OpenClaw" update_openclaw
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ollama)
        loading "Updating Ollama" update_ollama
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      codex)
        loading "Updating Codex" update_codex
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      opencode)
        loading "Updating OpenCode" update_opencode
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mimocode)
        loading "Updating MiMo Code" update_mimocode
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      engram)
        loading "Updating Engram" update_engram
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      codegraph)
        loading "Updating CodeGraph" update_codegraph
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      pi)
        loading "Updating Pi Coding Agent" update_pi
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      antigravity-cli)
        loading "Updating Antigravity CLI" update_antigravity_cli
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      minimax-cli)
        loading "Updating Minimax CLI" update_minimax_cli
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        loading "Updating gentle-ai" update_gentle_ai
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      gga)
        loading "Updating GGA" update_gga
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      hermes-agent)
        loading "Updating Hermes Agent" update_hermes_agent
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      kimi-code)
        loading "Updating Kimi Code" update_kimi_code
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown AI tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count AI tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  db)
    import "@/tools/db/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      postgresql)
        loading "Updating PostgreSQL" update_postgresql
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        loading "Updating MariaDB" update_mariadb
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        loading "Updating SQLite" update_sqlite
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        loading "Updating MongoDB" update_mongodb
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown database: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count database(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count database(s) failed to update"
    fi
    echo
    ;;
  tools)
    import "@/tools/tools/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        loading "Updating GitHub CLI" update_gh
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        loading "Updating Wget" update_wget
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        loading "Updating Curl" update_curl
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        loading "Updating LSD" update_lsd
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        loading "Updating Bat" update_bat
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        loading "Updating Proot" update_proot
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        loading "Updating Ncurses Utils" update_ncurses
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        loading "Updating Tmate" update_tmate
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        loading "Updating Cloudflared" update_cloudflared
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        loading "Updating Translate Shell" update_translate
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        loading "Updating html2text" update_html2text
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        loading "Updating jq" update_jq
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        loading "Updating bc" update_bc
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        loading "Updating Tree" update_tree
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        loading "Updating Fzf" update_fzf
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        loading "Updating ImageMagick" update_imagemagick
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        loading "Updating Shfmt" update_shfmt
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        loading "Updating Make" update_make
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        loading "Updating Udocker" update_udocker
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  node)
    import "@/tools/node/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        loading "Updating TypeScript" update_typescript
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        loading "Updating NestJS CLI" update_nestjs
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        loading "Updating Prettier" update_prettier
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        loading "Updating Live Server" update_live_server
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        loading "Updating Localtunnel" update_localtunnel
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        loading "Updating Vercel CLI" update_vercel
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        loading "Updating Markserv" update_markserv
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        loading "Updating PSQL Format" update_psqlformat
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        loading "Updating NPM Check Updates" update_ncu
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        loading "Updating Ngrok" update_ngrok
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown node module: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count Node.js module(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count module(s) failed to update"
    fi
    echo
    ;;
  language)
    import "@/tools/language/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        loading "Updating Node.js LTS" update_nodejs
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        loading "Updating Python" update_python
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        loading "Updating Perl" update_perl
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        loading "Updating PHP" update_php
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        loading "Updating Rust" update_rust
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        loading "Updating C/C++ (clang)" update_clang
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        loading "Updating Go (golang)" update_golang
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown language: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count language(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count language(s) failed to update"
    fi
    echo
    ;;
  shell)
    import "@/tools/shell/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
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
      *)
        log_warn "Unknown plugin: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count plugin(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count plugin(s) failed to update"
    fi
    echo
    ;;
  editor)
    import "@/tools/editor/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      neovim)
        loading "Updating Neovim" update_neovim
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        loading "Updating NvChad" update_nvchad
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown editor component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count editor component(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to update"
    fi
    echo
    ;;
  ui)
    import "@/tools/ui/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      font)
        loading "Updating Meslo Nerd Font" update_font
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        loading "Updating Extra Keys" update_extra_keys
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        loading "Updating Cursor Color" update_cursor
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        loading "Updating Core-Termux Banner" update_banner
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown UI component: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count UI component(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count component(s) failed to update"
    fi
    echo
    ;;
  automation)
    import "@/tools/automation/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        loading "Updating n8n" update_n8n
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      *)
        log_warn "Unknown automation tool: --$tool"
        ;;
      esac
    done

    echo
    if [[ $updated_count -gt 0 ]]; then
      log_success "$updated_count automation tool(s) updated"
    fi
    if [[ $failed_count -gt 0 ]]; then
      log_warn "$failed_count tool(s) failed to update"
    fi
    echo
    ;;
  *)
    log_warn "Unknown update target: $module"
    echo "Run 'core update' to see available targets"
    ;;
  esac
}

# Actualizar Core-Termux
update_core() {
  separator
  box "◈ UPDATING CORE-TERMUX ◈"
  separator
  echo

  if [[ -d "$CORE_PATH/../.git" ]]; then
    loading "Updating Core-Termux" _update_core_repo
    local rc=$?

    echo
    if [[ $rc -eq 0 ]]; then
      log_success "Core-Termux updated"
    elif [[ $rc -eq 2 ]]; then
      log_success "Core-Termux is already up to date"
    else
      log_error "Failed to update Core-Termux"
      log_info "Check your internet connection or run git pull manually"
    fi

    rm -f "$CORE_CACHE/new_version" "$CORE_CACHE/last_version_check"
  else
    log_warn "Not a git repository, cannot update"
    log_info "If you installed via curl, reinstall with:"
    echo "  curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash"
  fi

  echo
}

_update_core_repo() {
  local repo_dir="$CORE_PATH/.."
  local old_head

  old_head=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)

  if ! git -C "$repo_dir" pull --ff-only &>/dev/null; then
    return 1
  fi

  if [[ "$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)" == "$old_head" ]]; then
    return 2
  fi

  git -C "$repo_dir" log --oneline --no-decorate "$old_head..HEAD" 2>/dev/null | while IFS= read -r line; do
    printf "    ${CYAN}▸${NC} %s\n" "$line"
  done

  return 0
}
