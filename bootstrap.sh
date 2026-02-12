#!/bin/bash
source ~/.core-termux/config
echo -e "${D_CYAN}Starting Core-Termux Update... ${WHITE}"

# global message only once
echo -e "${D_CYAN}Checking required npm modules... ${WHITE}"

# Check and install npm modules
check_and_install() {
    local module="$1"
    local bin_name="$2"
    
    if ! command -v "$bin_name" >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing ${module}... ${WHITE}"
        npm install -g "$module"
    else
        echo -e "${GREEN}✓ ${bin_name} already installed ${WHITE}"
    fi
}

# Install perl (only if missing)
if ! command -v perl >/dev/null 2>&1; then
    echo -e "${D_CYAN}Installing perl... ${WHITE}"
    yes | pkg install perl
fi

# Install each module
check_and_install "psqlformat" "psqlformat"
check_and_install "@google/gemini-cli@0.1.14" "gemini"
check_and_install "@qwen-code/qwen-code@0.0.9" "qwen"
check_and_install "npm-check-updates" "ncu"
check_and_install "ngrok" "ngrok"

# new extra-keys
new_line="extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"

sed -i "s|^extra-keys =.*|${new_line}|" ~/.termux/termux.properties

# new alias for bat
if ! grep -q 'alias cat="bat --theme=Dracula --style=plain --paging=never"' ~/.zshrc; then
    echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >>~/.zshrc
    echo -e "${D_CYAN}Alias for cat created. ${WHITE}"
fi

# zsh-autocomplete – install only if not already present
echo -e "${D_CYAN}Checking zsh-autocomplete plugin... ${WHITE}"

PLUGIN_DIR="$HOME/.zsh-plugins/zsh-autocomplete"
SOURCE_LINE='source ~/.zsh-plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh'

if [ -d "$PLUGIN_DIR" ] || grep -q "$SOURCE_LINE" ~/.zshrc; then
    echo -e "${GREEN}zsh-autocomplete already installed. ${WHITE}"
else
    echo -e "${YELLOW}Installing zsh-autocomplete plugin... ${WHITE}"
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "$PLUGIN_DIR"
    echo "$SOURCE_LINE" >>~/.zshrc
    echo -e "${GREEN}zsh-autocomplete installed successfully. ${WHITE}"
fi

# final message
echo -e "
${D_CYAN}Update complete!

${BLACK}[ ${CYAN}• ${BLACK}] ${YELLOW} Added intelligent real-time autocompletion with ${CYAN}zsh-autocomplete ${YELLOW}:
      - Type any command and get suggestions as you type
      - Menu selection with arrow keys
      - Shows descriptions and previews where available
      - Highly configurable and very fast

${GREEN}Please restart Termux (or run ${CYAN}exec zsh ${GREEN}) to apply the changes.${WHITE}
"
