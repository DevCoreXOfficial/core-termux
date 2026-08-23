#!/usr/bin/env bash
# Platform: Ubuntu Linux / Ubuntu (WSL). Uses official installation methods.
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
import "@/utils/env"
import "@/utils/log"
import "@/utils/uninstall"
import "@/lib/platform"
core_detect_platform

LOG_FILE="${LOG_FILE:-$CORE_CACHE/install_shell.log}"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

SHELL_PKGS=(zsh lsd bat fzf zoxide git curl)

add_to_zshrc() {
  local line="$1"
  if ! grep -qxF "$line" ~/.zshrc 2>/dev/null; then
    echo "$line" >>~/.zshrc
  fi
}

_impl_install_deps() {
  pm_install "${SHELL_PKGS[@]}"
}

_impl_install_omz() {
  [[ -d "$OH_MY_ZSH_DIR" ]] && return 0
  local temp_file="/tmp/omz_install.sh"
  if ! curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$temp_file" &>>"$LOG_FILE"; then
    log_error "Failed to download Oh My Zsh"
    return 1
  fi
  sed -i '/exec zsh -l/s/^/#/' "$temp_file"
  sh "$temp_file" &>>"$LOG_FILE"
  rm -f "$temp_file"
}

PLUGINS=(
  "powerlevel10k|romkatv/powerlevel10k"
  "zsh-defer|romkatv/zsh-defer"
  "zsh-autosuggestions|zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting|zsh-users/zsh-syntax-highlighting"
  "history-substring|zsh-users/zsh-history-substring-search"
  "zsh-completions|zsh-users/zsh-completions"
  "fzf-tab|Aloxaf/fzf-tab"
  "you-should-use|MichaelAquilina/zsh-you-should-use"
  "zsh-autopair|hlissner/zsh-autopair"
  "better-npm|lukechilds/zsh-better-npm-completion"
)

_impl_install_plugins() {
  mkdir -p "$ZSH_PLUGINS_DIR"
  local entry name repo dest
  for entry in "${PLUGINS[@]}"; do
    name="${entry%%|*}"
    repo="${entry##*|}"
    dest="$ZSH_PLUGINS_DIR/$name"
    if [[ -d "$dest/.git" ]]; then
      git -C "$dest" pull --ff-only &>>"$LOG_FILE" || true
    else
      git clone --depth 1 "https://github.com/${repo}.git" "$dest" &>>"$LOG_FILE" ||
        log_warn "Failed to clone $name"
    fi
  done
}

_impl_wire_zshrc() {
  add_to_zshrc 'alias ls="lsd"'
  add_to_zshrc 'alias cat="bat --paging=never"'
  add_to_zshrc 'eval "$(zoxide init zsh)"'
  add_to_zshrc 'export PATH=$PATH:$HOME/go/bin'

  local P="$ZSH_PLUGINS_DIR"
  [[ -d "$P/powerlevel10k" ]] && add_to_zshrc "source $P/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -d "$P/zsh-defer" ]] && add_to_zshrc "source $P/zsh-defer/zsh-defer.plugin.zsh"
  [[ -d "$P/zsh-autosuggestions" ]] && add_to_zshrc "source $P/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -d "$P/zsh-syntax-highlighting" ]] && add_to_zshrc "source $P/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  if [[ -d "$P/history-substring" ]]; then
    add_to_zshrc "source $P/history-substring/zsh-history-substring-search.zsh"
    add_to_zshrc "bindkey '^[[A' history-substring-search-up"
    add_to_zshrc "bindkey '^[[B' history-substring-search-down"
  fi
  [[ -d "$P/zsh-completions" ]] && add_to_zshrc "fpath+=$P/zsh-completions"
  if [[ -d "$P/fzf-tab" ]]; then
    add_to_zshrc "source $P/fzf-tab/fzf-tab.plugin.zsh"
    add_to_zshrc "zstyle ':completion:*' menu-select yes"
  fi
  [[ -d "$P/zsh-you-should-use" ]] && add_to_zshrc "source $P/zsh-you-should-use/you-should-use.plugin.zsh"
  [[ -d "$P/zsh-autopair" ]] && add_to_zshrc "source $P/zsh-autopair/autopair.zsh"
  [[ -d "$P/better-npm" ]] && add_to_zshrc "source $P/better-npm/zsh-better-npm-completion.plugin.zsh"

  # Set zsh as the default shell when possible.
  if [[ "$SHELL" != *"zsh" ]] && command -v chsh >/dev/null 2>&1; then
    log_info "Run 'chsh -s \$(which zsh)' to make zsh your default shell"
  fi
}

case "${1:-install}" in
  install)
    mkdir -p "$(dirname "$LOG_FILE")" "$CORE_CACHE"
    _impl_install_deps || exit 1
    _impl_install_omz || exit 1
    _impl_install_plugins || exit 1
    _impl_wire_zshrc
    log_success "ZSH environment ready — restart your shell or run: exec zsh"
    ;;
  uninstall)
    confirm_remove_configs "ZSH plugins" "$ZSH_PLUGINS_DIR" >/dev/null 2>&1 || true
    rm -rf "$ZSH_PLUGINS_DIR"
    $CORE_SUDO rm -rf "$OH_MY_ZSH_DIR"
    log_success "ZSH environment removed (.zshrc lines kept)"
    ;;
  update)
    loading "Updating plugins" _impl_install_plugins
    log_success "ZSH environment updated"
    ;;
  *) exit 0 ;;
esac
