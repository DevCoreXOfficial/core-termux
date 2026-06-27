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
    list_item "core       - Update only Core-Termux framework"
    list_item "lang       - Update language packages (pkg upgrade)"
    list_item "db         - Update databases"
    list_item "ai         - Update AI tools (npm/pip/pkg)"
    list_item "editor     - Update Neovim configuration"
    list_item "dev        - Update development tools"
    list_item "npm        - Update Node.js global modules"
    list_item "shell      - Update ZSH plugins"
    list_item "ui         - Update Termux UI"
    list_item "auto       - Update Automation Tools"
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
  core)
    update_core
    ;;
  lang)
    import "@/modules/lang"
    update_lang
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
  dev)
    import "@/modules/dev"
    update_dev
    ;;
  npm)
    import "@/modules/npm"
    update_npm
    ;;
  shell)
    import "@/modules/shell"
    update_shell
    ;;
  ui)
    import "@/modules/ui"
    update_ui
    ;;
  auto)
    import "@/modules/auto"
    update_auto
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
      minimax-cli)
        update_minimax_cli
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      gentle-ai)
        update_gentle_ai
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
      command-code)
        update_command_code
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      freebuff)
        update_freebuff
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
        update_postgresql
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mariadb)
        update_mariadb
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      sqlite)
        update_sqlite
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      mongodb)
        update_mongodb
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
  dev)
    import "@/tools/dev/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        update_gh
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      wget)
        update_wget
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      curl)
        update_curl
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      lsd)
        update_lsd
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      bat)
        update_bat
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      proot)
        update_proot
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ncurses)
        update_ncurses
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      tmate)
        update_tmate
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      cloudflared)
        update_cloudflared
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      translate)
        update_translate
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      html2text)
        update_html2text
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      jq)
        update_jq
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      bc)
        update_bc
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      tree)
        update_tree
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      fzf)
        update_fzf
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      imagemagick)
        update_imagemagick
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      shfmt)
        update_shfmt
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      make)
        update_make
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      udocker)
        update_udocker
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
  npm)
    import "@/tools/npm/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        update_typescript
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      nestjs)
        update_nestjs
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      prettier)
        update_prettier
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      live-server)
        update_live_server
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      localtunnel)
        update_localtunnel
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      vercel)
        update_vercel
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      markserv)
        update_markserv
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      psqlformat)
        update_psqlformat
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ncu)
        update_ncu
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      ngrok)
        update_ngrok
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
  lang)
    import "@/tools/lang/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        update_npmjs
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      python)
        update_python
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      perl)
        update_perl
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      php)
        update_php
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      rust)
        update_rust
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      clang)
        update_clang
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      golang)
        update_golang
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
        update_powerlevel10k
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-defer)
        update_zsh_defer
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-autosuggestions)
        update_zsh_autosuggestions
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-syntax-highlighting)
        update_zsh_syntax_highlighting
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      history-substring)
        update_history_substring
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-completions)
        update_zsh_completions
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      fzf-tab)
        update_fzf_tab
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      you-should-use)
        update_you_should_use
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      zsh-autopair)
        update_zsh_autopair
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      better-npm)
        update_better_npm
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
        update_neovim
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      nvchad)
        update_nvchad
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
        update_font
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      extra-keys)
        update_extra_keys
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      cursor)
        update_cursor
        case $? in 0) ((updated_count++));; 1) ((failed_count++));; esac
        ;;
      banner)
        update_banner
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
  auto)
    import "@/tools/auto/all"
    local updated_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        update_n8n
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
