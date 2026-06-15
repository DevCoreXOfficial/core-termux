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
    list_item "all        - Reinstall everything (uninstall + install)"
    list_item "language   - Reinstall language packages"
    list_item "db         - Reinstall databases"
    list_item "ai         - Reinstall AI tools"
    list_item "editor     - Reinstall code editor"
    list_item "tools      - Reinstall development tools"
    list_item "node       - Reinstall Node.js global modules"
    list_item "shell      - Reinstall ZSH + Oh My Zsh"
    list_item "ui         - Reinstall Termux UI"
    list_item "automation - Reinstall automation tools"
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
  all)
    separator
    box "Reinstalling Complete Environment"
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

    reinstall_language
    reinstall_db
    reinstall_ai
    reinstall_editor
    reinstall_tools
    reinstall_node
    reinstall_shell
    reinstall_ui
    reinstall_automation

    separator
    log_success "Complete environment reinstalled successfully"
    separator
    echo
    log_warn "Please restart Termux to apply all changes"
    echo
    ;;
  language)
    import "@/modules/language"
    reinstall_language
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
  tools)
    import "@/modules/tools"
    reinstall_tools
    ;;
  node)
    import "@/modules/node-modules"
    reinstall_node
    ;;
  shell)
    import "@/modules/shell"
    reinstall_shell
    ;;
  ui)
    import "@/modules/ui"
    reinstall_ui
    ;;
  automation)
    import "@/modules/automation"
    reinstall_automation
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
        if loading "Reinstalling Qwen Code" reinstall_qwen_code; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      gemini-cli)
        if loading "Reinstalling Gemini CLI" reinstall_gemini_cli; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      claude-code)
        if loading "Reinstalling Claude Code" reinstall_claude_code; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      mistral-vibe)
        if loading "Reinstalling Mistral Vibe" reinstall_mistral_vibe; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      openclaude)
        if loading "Reinstalling OpenClaude" reinstall_openclaude; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      openclaw)
        if loading "Reinstalling OpenClaw" reinstall_openclaw; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      ollama)
        if loading "Reinstalling Ollama" reinstall_ollama; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      codex)
        if loading "Reinstalling Codex CLI" reinstall_codex; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      opencode)
        if loading "Reinstalling OpenCode" reinstall_opencode; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      mimocode)
        if loading "Reinstalling MiMo Code" reinstall_mimocode; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      engram)
        if loading "Reinstalling Engram" reinstall_engram; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      codegraph)
        if loading "Reinstalling CodeGraph" reinstall_codegraph; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      pi)
        if loading "Reinstalling Pi Coding Agent" reinstall_pi; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      antigravity-cli)
        if loading "Reinstalling Antigravity CLI" reinstall_antigravity_cli; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      minimax-cli)
        if loading "Reinstalling Minimax CLI" reinstall_minimax_cli; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      gentle-ai)
        if loading "Reinstalling Gentle AI" reinstall_gentle_ai; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      gga)
        if loading "Reinstalling GGA" reinstall_gga; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      hermes-agent)
        if reinstall_hermes_agent; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      kimi-code)
        if loading "Reinstalling Kimi Code" reinstall_kimi_code; then ((reinstalled_count++)); else ((failed_count++)); fi
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
        if loading "Reinstalling PostgreSQL" reinstall_postgresql; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      mariadb)
        if loading "Reinstalling MariaDB" reinstall_mariadb; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      sqlite)
        if loading "Reinstalling SQLite" reinstall_sqlite; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      mongodb)
        if loading "Reinstalling MongoDB" reinstall_mongodb; then ((reinstalled_count++)); else ((failed_count++)); fi
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
  tools)
    import "@/tools/tools/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      gh)
        if loading "Reinstalling GitHub CLI" reinstall_gh; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      wget)
        if loading "Reinstalling Wget" reinstall_wget; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      curl)
        if loading "Reinstalling Curl" reinstall_curl; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      lsd)
        if loading "Reinstalling LSD" reinstall_lsd; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      bat)
        if loading "Reinstalling Bat" reinstall_bat; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      proot)
        if loading "Reinstalling Proot" reinstall_proot; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      ncurses)
        if loading "Reinstalling Ncurses Utils" reinstall_ncurses; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      tmate)
        if loading "Reinstalling Tmate" reinstall_tmate; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      cloudflared)
        if loading "Reinstalling Cloudflared" reinstall_cloudflared; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      translate)
        if loading "Reinstalling Translate Shell" reinstall_translate; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      html2text)
        if loading "Reinstalling html2text" reinstall_html2text; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      jq)
        if loading "Reinstalling jq" reinstall_jq; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      bc)
        if loading "Reinstalling bc" reinstall_bc; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      tree)
        if loading "Reinstalling Tree" reinstall_tree; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      fzf)
        if loading "Reinstalling Fzf" reinstall_fzf; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      imagemagick)
        if loading "Reinstalling ImageMagick" reinstall_imagemagick; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      shfmt)
        if loading "Reinstalling Shfmt" reinstall_shfmt; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      make)
        if loading "Reinstalling Make" reinstall_make; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      udocker)
        if loading "Reinstalling Udocker" reinstall_udocker; then ((reinstalled_count++)); else ((failed_count++)); fi
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
  node)
    import "@/tools/node/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      typescript)
        if loading "Reinstalling TypeScript" reinstall_typescript; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      nestjs)
        if loading "Reinstalling NestJS CLI" reinstall_nestjs; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      prettier)
        if loading "Reinstalling Prettier" reinstall_prettier; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      live-server)
        if loading "Reinstalling Live Server" reinstall_live_server; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      localtunnel)
        if loading "Reinstalling Localtunnel" reinstall_localtunnel; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      vercel)
        if loading "Reinstalling Vercel CLI" reinstall_vercel; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      markserv)
        if loading "Reinstalling Markserv" reinstall_markserv; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      psqlformat)
        if loading "Reinstalling PSQL Format" reinstall_psqlformat; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      ncu)
        if loading "Reinstalling NPM Check Updates" reinstall_ncu; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      ngrok)
        if loading "Reinstalling Ngrok" reinstall_ngrok; then ((reinstalled_count++)); else ((failed_count++)); fi
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
  language)
    import "@/tools/language/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      nodejs)
        if loading "Reinstalling Node.js LTS" reinstall_nodejs; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      python)
        if loading "Reinstalling Python" reinstall_python; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      perl)
        if loading "Reinstalling Perl" reinstall_perl; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      php)
        if loading "Reinstalling PHP" reinstall_php; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      rust)
        if loading "Reinstalling Rust" reinstall_rust; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      clang)
        if loading "Reinstalling C/C++ (clang)" reinstall_clang; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      golang)
        if loading "Reinstalling Go (golang)" reinstall_golang; then ((reinstalled_count++)); else ((failed_count++)); fi
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
        if loading "Reinstalling powerlevel10k" reinstall_powerlevel10k; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      zsh-defer)
        if loading "Reinstalling zsh-defer" reinstall_zsh_defer; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      zsh-autosuggestions)
        if loading "Reinstalling zsh-autosuggestions" reinstall_zsh_autosuggestions; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      zsh-syntax-highlighting)
        if loading "Reinstalling zsh-syntax-highlighting" reinstall_zsh_syntax_highlighting; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      history-substring)
        if loading "Reinstalling zsh-history-substring-search" reinstall_history_substring; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      zsh-completions)
        if loading "Reinstalling zsh-completions" reinstall_zsh_completions; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      fzf-tab)
        if loading "Reinstalling fzf-tab" reinstall_fzf_tab; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      you-should-use)
        if loading "Reinstalling zsh-you-should-use" reinstall_you_should_use; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      zsh-autopair)
        if loading "Reinstalling zsh-autopair" reinstall_zsh_autopair; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      better-npm)
        if loading "Reinstalling zsh-better-npm-completion" reinstall_better_npm; then ((reinstalled_count++)); else ((failed_count++)); fi
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
        if loading "Reinstalling Neovim" reinstall_neovim; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      nvchad)
        if loading "Reinstalling NvChad" reinstall_nvchad; then ((reinstalled_count++)); else ((failed_count++)); fi
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
        if loading "Reinstalling Meslo Nerd Font" reinstall_font; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      extra-keys)
        if loading "Reinstalling Extra Keys" reinstall_extra_keys; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      cursor)
        if loading "Reinstalling Cursor Color" reinstall_cursor; then ((reinstalled_count++)); else ((failed_count++)); fi
        ;;
      banner)
        if loading "Reinstalling Core-Termux Banner" reinstall_banner; then ((reinstalled_count++)); else ((failed_count++)); fi
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
  automation)
    import "@/tools/automation/all"
    local reinstalled_count=0
    local failed_count=0

    for tool in "${tools[@]}"; do
      case "$tool" in
      n8n)
        if loading "Reinstalling n8n" reinstall_n8n; then ((reinstalled_count++)); else ((failed_count++)); fi
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
