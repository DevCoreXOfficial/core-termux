#!/usr/bin/env bash
# Platform: Termux / Android.
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"
import "@/utils/log"

LOG_FILE="$CORE_CACHE/install_shell.log"
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

SHELL_PKGS=(zsh lsd bat fzf zoxide git)

add_to_zshrc() {
  local line="$1"
  if ! grep -qxF "$line" ~/.zshrc 2>/dev/null; then
    echo "$line" >>~/.zshrc
  fi
}

_install_deps() {
  loading "Installing base packages" _install_deps_impl
}

_install_deps_impl() {
  yes | pkg install "${SHELL_PKGS[@]}" &>>"$LOG_FILE"
}

_install_oh_my_zsh() {
  [[ -d "$OH_MY_ZSH_DIR" ]] && return 0
  loading "Downloading Oh My Zsh" _install_oh_my_zsh_impl
}

_install_oh_my_zsh_impl() {
  local temp_file="${PREFIX:-/data/data/com.termux/files/usr}/tmp/omz_install.sh"
  mkdir -p "$(dirname "$temp_file")"
  if ! curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$temp_file" &>>"$LOG_FILE"; then
    log_error "Failed to download Oh My Zsh"
    return 1
  fi
  sed -i '/exec zsh -l/s/^/#/' "$temp_file"
  sh "$temp_file" &>>"$LOG_FILE"
  rm -f "$temp_file"
}

# Official plugin repositories (name|repo)
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

_install_plugins() {
  loading "Cloning ZSH plugins" _install_plugins_impl
}

_install_plugins_impl() {
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

_wire_zshrc() {
  loading "Configuring .zshrc" _wire_zshrc_impl
}

_wire_zshrc_impl() {
  add_to_zshrc 'alias ls="lsd"'
  add_to_zshrc 'alias cat="bat --theme=Dracula --style=plain --paging=never"'
  add_to_zshrc 'eval "$(zoxide init zsh)"'

  add_to_zshrc "unalias gga 2>/dev/null"
  add_to_zshrc 'export GOPATH="$HOME/.local/go"'
  add_to_zshrc 'export GOCACHE="$HOME/.cache/go"'
  add_to_zshrc 'export GOMODCACHE="$GOPATH/pkg/mod"'
  add_to_zshrc 'export PATH=$PATH:$HOME/go/bin'
  add_to_zshrc 'export OPENCLAW_DISABLE_BONJOUR=1'

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
    add_to_zshrc "zstyle ':fzf-tab:*' switch-word yes"
  fi
  [[ -d "$P/zsh-you-should-use" ]] && add_to_zshrc "source $P/zsh-you-should-use/you-should-use.plugin.zsh"
  [[ -d "$P/zsh-autopair" ]] && add_to_zshrc "source $P/zsh-autopair/autopair.zsh"
  [[ -d "$P/better-npm" ]] && add_to_zshrc "source $P/better-npm/zsh-better-npm-completion.plugin.zsh"

  # Persistent session: restore last directory in new sessions.
  if ! grep -q "# ===== Persistent Directory =====" ~/.zshrc 2>/dev/null; then
    mkdir -p "$CORE_CACHE"
    echo "$HOME" >"$CORE_CACHE/last_dir"
    cat >>~/.zshrc <<EOF

# ===== Persistent Directory =====
LAST_DIR_FILE="\$HOME/.cache/core/last_dir"
SESSION_TIMESTAMP="\$HOME/.cache/core/.session_time"
SESSION_TIMEOUT=5

save_dir() {
  mkdir -p "\$HOME/.cache/core" 2>/dev/null
  pwd > "\$LAST_DIR_FILE"
  date +%s > "\$SESSION_TIMESTAMP"
}

restore_dir() {
  if [[ -f "\$SESSION_TIMESTAMP" ]] && [[ -f "\$LAST_DIR_FILE" ]]; then
    local current_time last_time diff
    current_time=\$(date +%s)
    last_time=\$(cat "\$SESSION_TIMESTAMP" 2>/dev/null || echo 0)
    diff=\$((current_time - last_time))
    if [[ \$diff -lt \$SESSION_TIMEOUT ]]; then
      local dir
      dir=\$(cat "\$LAST_DIR_FILE")
      if [[ -d "\$dir" ]] && [[ "\$dir" != "\$HOME" ]]; then
        cd "\$dir" 2>/dev/null
      fi
    fi
  fi
  date +%s > "\$SESSION_TIMESTAMP"
}

if typeset -f add-zsh-hook &>/dev/null; then
  add-zsh-hook precmd save_dir
  restore_dir
else
  restore_dir
  trap 'save_dir' EXIT
fi
EOF
  fi
}

case "${1:-install}" in
  install)
    mkdir -p "$(dirname "$LOG_FILE")" "$CORE_CACHE"
    _install_deps || exit 1
    _install_oh_my_zsh || exit 1
    _install_plugins || exit 1
    _wire_zshrc
    log_success "ZSH environment ready — restart your shell or run: exec zsh"
    ;;
  uninstall)
    confirm_remove_configs "ZSH plugins" "$ZSH_PLUGINS_DIR" >/dev/null 2>&1 || true
    rm -rf "$ZSH_PLUGINS_DIR"
    loading "Removing Oh My Zsh" rm -rf "$OH_MY_ZSH_DIR"
    log_success "ZSH environment removed (.zshrc lines kept)"
    ;;
  update)
    mkdir -p "$(dirname "$LOG_FILE")"
    loading "Updating plugins" _install_plugins_impl
    log_success "ZSH environment updated"
    ;;
  *) exit 0 ;;
esac
