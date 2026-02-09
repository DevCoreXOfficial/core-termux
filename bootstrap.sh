#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "${HOME}/.core-termux/config"

echo -e "${D_CYAN}Starting Core-Termux Bootstrap... ${WHITE}"

echo -e "${D_CYAN}Checking required npm modules... ${WHITE}"

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

# Ensure perl exists (some tools rely on it)
if ! command -v perl >/dev/null 2>&1; then
  echo -e "${D_CYAN}Installing perl... ${WHITE}"
  yes | pkg install perl
fi

# npm tools (keep versions for known compatibility)
check_and_install "psqlformat" "psqlformat"
check_and_install "@google/gemini-cli@0.1.14" "gemini"
check_and_install "@qwen-code/qwen-code@0.0.9" "qwen"
check_and_install "npm-check-updates" "ncu"
check_and_install "ngrok" "ngrok"
check_and_install "prettier" "prettier"
check_and_install "typescript" "tsc"

# termux keys + cursor (idempotent)
mkdir -p "${HOME}/.termux"
TERMUX_PROPS="${HOME}/.termux/termux.properties"
new_line="extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"

if [[ -f "${TERMUX_PROPS}" ]]; then
  if grep -q '^extra-keys' "${TERMUX_PROPS}"; then
    sed -i "s|^extra-keys =.*|${new_line}|" "${TERMUX_PROPS}"
  else
    echo "${new_line}" >> "${TERMUX_PROPS}"
  fi
else
  printf "terminal-cursor-blink-rate=500\n\n%s\n" "${new_line}" > "${TERMUX_PROPS}"
fi

# alias for bat
if [[ -f "${HOME}/.zshrc" ]] && ! grep -q 'alias cat="bat --theme=Dracula --style=plain --paging=never"' "${HOME}/.zshrc"; then
  echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >> "${HOME}/.zshrc"
  echo -e "${D_CYAN}Alias for cat created. ${WHITE}"
fi

# zsh-autocomplete – install only if not already present
echo -e "${D_CYAN}Checking zsh-autocomplete plugin... ${WHITE}"

PLUGIN_DIR="${HOME}/.zsh-plugins/zsh-autocomplete"
SOURCE_LINE='source ~/.zsh-plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh'

if [[ -d "${PLUGIN_DIR}" ]] || ( [[ -f "${HOME}/.zshrc" ]] && grep -q "${SOURCE_LINE}" "${HOME}/.zshrc" ); then
  echo -e "${GREEN}zsh-autocomplete already installed. ${WHITE}"
else
  echo -e "${YELLOW}Installing zsh-autocomplete plugin... ${WHITE}"
  mkdir -p "${HOME}/.zsh-plugins"
  git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git "${PLUGIN_DIR}"
  echo "${SOURCE_LINE}" >> "${HOME}/.zshrc"
  echo -e "${GREEN}zsh-autocomplete installed successfully. ${WHITE}"
fi

command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings || true

echo -e "
${D_CYAN}Bootstrap complete!${WHITE}

${GREEN}Tip:${WHITE} Run ${CYAN}core.sh menu${WHITE} for the full installer menu, doctor, backup/restore and uninstall.
"
