#!/bin/bash

# import config file
source ./config

# install core-termux
echo -e "
${GREEN}Installing development enviroment...${WHITE}
"

# create installation directory
if [[ ! -d ~/.core-termux ]]; then
	mkdir -p ~/.core-termux
	cp config ~/.core-termux
fi

# path to installation
echo "core='${PWD}'" >>~/.core-termux/config

# update termux repositories
yes | pkg update && yes | pkg upgrade

# install termux packages
yes | pkg install git gh zsh neovim nodejs python perl php curl wget lua-language-server lsd bat tur-repo proot ncurses-utils ripgrep stylua tmate cloudflared translate-shell html2text jq postgresql mariadb sqlite bc tree fzf imagemagick shfmt

# install termux-users repositories
yes | pkg install mongodb

# installing node global modules
npm install -g @devcorex/dev.x typescript @nestjs/cli prettier live-server localtunnel vercel markserv psqlformat @google/gemini-cli@0.1.14 @qwen-code/qwen-code@0.0.9 npm-check-updates ngrok

# fixed localtunnel android error
sed -i '/case '\''win32'\''/,/break;/ a\    case '\''android'\'':\n        command = '\''termux-open-url'\'';\n        break;' ${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js

sed -i 's/break;/break;/' ${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js

# download oh-my-zsh shell
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install.sh
sed -i '/exec zsh -l/s/^/#/' install.sh
sh install.sh
rm install.sh

# create zsh-plugins directory
if [[ ! -d ~/.zsh-plugins ]]; then
	mkdir -p ~/.zsh-plugins
fi

# check zsh-plugins directory
if [[ -d ~/.zsh-plugins ]]; then

	####### ZSH PLUGINS #######

	# zsh-defer
	git clone https://github.com/romkatv/zsh-defer.git ~/.zsh-plugins/zsh-defer && echo 'source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh' >>~/.zshrc

	# powerlevel10k
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh-plugins/powerlevel10k && echo 'source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

	# zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh-plugins/zsh-autosuggestions && echo 'source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >>~/.zshrc

	# zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-plugins/zsh-syntax-highlighting && echo 'source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>~/.zshrc

	# zsh-history-substring-search
	git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh-plugins/zsh-history-substring-search && echo 'source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh' >>~/.zshrc

	echo "bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down" >>~/.zshrc

	# zsh-completions
	git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh-plugins/zsh-completions && echo 'fpath+=~/.zsh-plugins/zsh-completions' >>~/.zshrc

	# fzf-tab
	git clone https://github.com/Aloxaf/fzf-tab.git ~/.zsh-plugins/fzf-tab && echo 'source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh' >>~/.zshrc

	echo "zstyle ':completion:*' menu-select yes
zstyle ':fzf-tab:*' switch-word yes" >>~/.zshrc

	# zsh-you-should-use
	git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.zsh-plugins/zsh-you-should-use && echo 'source ~/.zsh-plugins/zsh-you-should-use/you-should-use.plugin.zsh' >>~/.zshrc

	# zsh-autopair
	git clone https://github.com/hlissner/zsh-autopair.git ~/.zsh-plugins/zsh-autopair && echo 'source ~/.zsh-plugins/zsh-autopair/autopair.zsh' >>~/.zshrc

	# zsh-better-npm-completion
	git clone https://github.com/lukechilds/zsh-better-npm-completion.git ~/.zsh-plugins/zsh-better-npm-completion && echo 'source ~/.zsh-plugins/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh' >>~/.zshrc

	# add alias to ~/.zshrc
	echo "core='${PWD}'" >>~/.zshrc
	echo 'alias ls="lsd"' >>~/.zshrc
	echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >>~/.zshrc
	echo 'INITIAL_PATH=$(pwd)' >>~/.zshrc
	echo 'source ${core}/update.sh > >(tee /dev/tty) 2>&1' >>~/.zshrc
	echo 'cd ${INITIAL_PATH}' >>~/.zshrc

fi

# custom termux-keys and cursor
echo "terminal-cursor-blink-rate=500

extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]" >>~/.termux/termux.properties
echo "cursor=#00FF00" >>~/.termux/colors.properties

# add Meslo Nerd Font
cp ./assets/fonts/font.ttf ~/.termux/font.ttf

# download nvchad (code editor)
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim

git clone https://github.com/DevCoreXOfficial/nvchad-termux.git ~/.core-termux/nvchad-termux
cd ~/.core-termux/nvchad-termux
exec bash nvchad.sh

# successfully message
echo -e "${YELLOW}Please restart your Termux${WHITE}"
