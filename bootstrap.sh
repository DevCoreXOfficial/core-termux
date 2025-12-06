#!/bin/bash
source ~/.core-termux/config

echo -e "${D_CYAN}Starting Core-Termux Update...${WHITE}"

# node modules list (to verify and install)
node_modules=(
	"psqlformat"
	"@google/gemini-cli@0.1.14"
	"@qwen-code/qwen-code@0.0.9"
	"npm-check-updates"
	"ngrok"
)

# install perl (only if missing)
if ! command -v perl >/dev/null 2>&1; then
	echo -e "${D_CYAN}Installing perl...${WHITE}"
	yes | pkg install perl
fi

# install npm modules ONLY if not installed
echo -e "${D_CYAN}Checking required npm modules...${WHITE}"

for module in "${node_modules[@]}"; do
	# extract base name (removes @version)
	base_name=$(echo "$module" | awk -F'@' '{print $1}')

	# check if installed using grep, works with scope packages
	if npm list -g --depth=0 | grep -q " $base_name@"; then
		echo -e "${GREEN}${base_name} already installed.${WHITE}"
	else
		echo -e "${YELLOW}Installing ${module}...${WHITE}"
		npm install -g "$module"
	fi
done

# new extra-keys
new_line="extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"

sed -i "s|^extra-keys =.*|${new_line}|" ~/.termux/termux.properties

# new alias
if ! grep -q 'alias cat="bat --theme=Dracula --style=plain --paging=never"' ~/.zshrc; then
	echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >>~/.zshrc
	echo -e "${D_CYAN}Alias for cat created.${WHITE}"
fi

# message of new changes
echo -e "
${D_CYAN}What's new?

${BLACK}[${CYAN}*${BLACK}]${YELLOW} Removed automatic updates for Termux packages and global npm modules.
${BLACK}[${CYAN}*${BLACK}]${YELLOW} Now npm modules are installed only if they are not already present on the system.

${GREEN}Update complete, please restart Termux.${WHITE}
"
