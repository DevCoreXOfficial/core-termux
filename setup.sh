#!/bin/bash
set -euo pipefail


# import config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config"

# install core-termux
echo -e "
${GREEN}Installing development enviroment...${WHITE}
"

# create installation directory
if [[ ! -d "$HOME/.core-termux" ]]; then
  mkdir -p "$HOME/.core-termux"
  cp "$SCRIPT_DIR/config" "$HOME/.core-termux/config"
fi

# path to installation (store once)
CORE_CFG="$HOME/.core-termux/config"
if grep -qE "^core=" "$CORE_CFG"; then
  sed -i "s|^core=.*|core='${PWD}'|" "$CORE_CFG"
else
  echo "core='${PWD}'" >>"$CORE_CFG"
fi

# update termux repositories
pkg update -y && pkg upgrade -y

# install termux packages
pkg install -y git gh zsh neovim nodejs python perl php curl wget lua-language-server lsd bat tur-repo proot ncurses-utils ripgrep stylua tmate cloudflared translate-shell html2text jq postgresql mariadb sqlite bc tree fzf imagemagick shfmt

# install termux-users repositories
pkg install -y mongodb

# installing node global modules
if ! command -v npm >/dev/null 2>&1; then
  echo -e "${RED}npm is not available even though nodejs was requested. Please ensure Termux nodejs installed correctly.${WHITE}"
  exit 1
fi
npm install -g --no-progress @devcorex/dev.x typescript @nestjs/cli prettier live-server localtunnel vercel markserv psqlformat @google/gemini-cli@0.1.14 @qwen-code/qwen-code@0.0.9 npm-check-updates ngrok

# fixed localtunnel android error (only if the target file exists)

OPENURL_JS="${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js"
if [ -f "$OPENURL_JS" ]; then
  if ! grep -q "case 'android'" "$OPENURL_JS"; then
    sed -i "/case 'win32'/,/break;/ a\    case 'android':\n        command = 'termux-open-url';\n        break;" "$OPENURL_JS"
  fi
fi

# download oh-my-zsh shell
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install.sh
sed -i '/exec zsh -l/s/^/#/' install.sh
sh install.sh
rm install.sh

# create zsh-plugins directory
if [[ ! -d ~/.zsh-plugins ]]; then
	mkdir -p ~/.zsh-plugins
fi


# Helpers
ensure_line() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >>"$file"
  fi
}

clone_if_missing() {
  local repo="$1"
  local dir="$2"
  if [ ! -d "$dir" ]; then
    git clone "$repo" "$dir"
  fi
}

# check zsh-plugins directory
if [[ -d "$HOME/.zsh-plugins" ]]; then

	####### ZSH PLUGINS #######

	# zsh-defer
	clone_if_missing https://github.com/romkatv/zsh-defer.git "$HOME/.zsh-plugins/zsh-defer"
ensure_line 'source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh' "$HOME/.zshrc"

	# powerlevel10k
	clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/.zsh-plugins/powerlevel10k"
ensure_line 'source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme' "$HOME/.zshrc"

	# zsh-autosuggestions
	clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh-plugins/zsh-autosuggestions"
ensure_line 'source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' "$HOME/.zshrc"

	# zsh-syntax-highlighting
	clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-plugins/zsh-syntax-highlighting"
ensure_line 'source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' "$HOME/.zshrc"

	# zsh-history-substring-search
	clone_if_missing https://github.com/zsh-users/zsh-history-substring-search.git "$HOME/.zsh-plugins/zsh-history-substring-search"
ensure_line 'source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh' "$HOME/.zshrc"

	echo "bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down" >>~/.zshrc

	# zsh-completions
	clone_if_missing https://github.com/zsh-users/zsh-completions.git "$HOME/.zsh-plugins/zsh-completions"
ensure_line 'fpath+=~/.zsh-plugins/zsh-completions' "$HOME/.zshrc"

	# fzf-tab
	clone_if_missing https://github.com/Aloxaf/fzf-tab.git "$HOME/.zsh-plugins/fzf-tab"
ensure_line 'source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh' "$HOME/.zshrc"

	echo "zstyle ':completion:*' menu-select yes
zstyle ':fzf-tab:*' switch-word yes" >>~/.zshrc

	# zsh-you-should-use
	clone_if_missing https://github.com/MichaelAquilina/zsh-you-should-use.git "$HOME/.zsh-plugins/zsh-you-should-use"
ensure_line 'source ~/.zsh-plugins/zsh-you-should-use/you-should-use.plugin.zsh' "$HOME/.zshrc"

	# zsh-autopair
	clone_if_missing https://github.com/hlissner/zsh-autopair.git "$HOME/.zsh-plugins/zsh-autopair"
ensure_line 'source ~/.zsh-plugins/zsh-autopair/autopair.zsh' "$HOME/.zshrc"

	# zsh-better-npm-completion
	clone_if_missing https://github.com/lukechilds/zsh-better-npm-completion.git "$HOME/.zsh-plugins/zsh-better-npm-completion"
ensure_line 'source ~/.zsh-plugins/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh' "$HOME/.zshrc"

  # zsh-autocomplete
  clone_if_missing https://github.com/marlonrichert/zsh-autocomplete.git "$HOME/.zsh-plugins/zsh-autocomplete"
ensure_line 'source ~/.zsh-plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh' "$HOME/.zshrc"

	# add alias to ~/.zshrc
	echo "core='${PWD}'" >>~/.zshrc
	echo 'alias ls="lsd"' >>~/.zshrc
	echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >>~/.zshrc
	echo 'INITIAL_PATH=$(pwd)' >>~/.zshrc
	echo 'source ${core}/update.sh > >(tee /dev/tty) 2>&1' >>~/.zshrc
	echo 'cd ${INITIAL_PATH}' >>~/.zshrc

fi

# custom termux-keys and cursor
TERMUX_PROP="$HOME/.termux/termux.properties"
mkdir -p "$HOME/.termux"
touch "$TERMUX_PROP"

# terminal cursor blink rate
if grep -qE "^terminal-cursor-blink-rate\s*=" "$TERMUX_PROP"; then
  sed -i "s|^terminal-cursor-blink-rate\s*=.*|terminal-cursor-blink-rate=500|" "$TERMUX_PROP"
else
  printf '\nterminal-cursor-blink-rate=500\n' >>"$TERMUX_PROP"
fi

# extra keys row
EXTRA_KEYS="[['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"
if grep -qE "^extra-keys\s*=" "$TERMUX_PROP"; then
  sed -i "s|^extra-keys\s*=.*|extra-keys = ${EXTRA_KEYS}|" "$TERMUX_PROP"
else
  printf '\nextra-keys = %s\n' "$EXTRA_KEYS" >>"$TERMUX_PROP"
fi
set_or_append_prop_file "cursor" "#00FF00" "$HOME/.termux/colors.properties"

# add Meslo Nerd Font
cp "$SCRIPT_DIR/assets/fonts/font.ttf" "$HOME/.termux/font.ttf"

if command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings || true
fi

# download nvchad (code editor)
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim

git clone https://github.com/DevCoreXOfficial/nvchad-termux.git ~/.core-termux/nvchad-termux
cd ~/.core-termux/nvchad-termux
bash nvchad.sh

# successfully message
echo -e "${YELLOW}Please restart Termux${WHITE}"
