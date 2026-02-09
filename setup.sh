#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${ROOT_DIR}/config"

PROFILE="full"   # full|minimal|web|cli
ASSUME_YES=0
INSTALL_NVCHAD=1
INSTALL_ZSH=1
INSTALL_DB=1
INSTALL_AI=1

usage() {
  cat <<EOF
Usage: bash setup.sh [options]

Options:
  --profile <full|minimal|web|cli>   Installation profile (default: full)
  --yes                              Non-interactive (auto-yes)
  --no-nvchad                        Skip NvChad install
  --no-zsh                           Skip Oh-My-Zsh + plugins
  --no-db                            Skip databases (postgres/mariadb/sqlite/mongodb)
  --no-ai                            Skip AI CLIs (gemini/qwen)
  -h, --help                         Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-full}"; shift 2 ;;
    --yes) ASSUME_YES=1; shift ;;
    --no-nvchad) INSTALL_NVCHAD=0; shift ;;
    --no-zsh) INSTALL_ZSH=0; shift ;;
    --no-db) INSTALL_DB=0; shift ;;
    --no-ai) INSTALL_AI=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
done

echo -e "
${GREEN}Installing development environment...${WHITE}
${CYAN}Profile:${WHITE} ${PROFILE}
"

# Backup current configs before changes
bash "${ROOT_DIR}/tools.sh" backup || true

# create installation directory
if [[ ! -d "${HOME}/.core-termux" ]]; then
  mkdir -p "${HOME}/.core-termux"
  cp "${ROOT_DIR}/config" "${HOME}/.core-termux/config"
fi

# path to installation
if ! grep -q "^core=" "${HOME}/.core-termux/config" 2>/dev/null; then
  echo "core='${ROOT_DIR}'" >> "${HOME}/.core-termux/config"
fi

# update termux repositories
if [[ "${ASSUME_YES}" -eq 1 ]]; then
  yes | pkg update && yes | pkg upgrade
else
  pkg update && pkg upgrade
fi

# package sets
BASE_PKGS=(git gh zsh neovim nodejs python perl php curl wget lsd bat ncurses-utils ripgrep stylua tmate cloudflared translate-shell html2text jq bc tree fzf imagemagick shfmt)
WEB_PKGS=(lua-language-server)
DB_PKGS=(postgresql mariadb sqlite)
EXTRA_REPOS=(tur-repo proot)
TERMUX_USERS_PKGS=(mongodb)

# always install base
install_pkgs() {
  local pkgs=("$@")
  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    yes | pkg install "${pkgs[@]}"
  else
    pkg install "${pkgs[@]}"
  fi
}

# enable extra repo if present in profile
install_pkgs "${EXTRA_REPOS[@]}"

# profile logic
case "${PROFILE}" in
  full)
    install_pkgs "${BASE_PKGS[@]}" "${WEB_PKGS[@]}"
    ;;
  minimal)
    # minimal CLI dev set
    install_pkgs git zsh nodejs python curl wget ripgrep fzf bat lsd
    INSTALL_NVCHAD=0
    INSTALL_DB=0
    INSTALL_AI=0
    ;;
  web)
    install_pkgs "${BASE_PKGS[@]}" "${WEB_PKGS[@]}"
    INSTALL_DB=0
    ;;
  cli)
    install_pkgs git zsh nodejs python curl wget ripgrep fzf bat lsd shfmt jq
    INSTALL_NVCHAD=0
    INSTALL_DB=0
    ;;
  *)
    echo "Invalid profile: ${PROFILE}"; exit 2 ;;
esac

# databases
if [[ "${INSTALL_DB}" -eq 1 ]]; then
  install_pkgs "${DB_PKGS[@]}"
  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    yes | pkg install "${TERMUX_USERS_PKGS[@]}"
  else
    pkg install "${TERMUX_USERS_PKGS[@]}"
  fi
fi

# node global modules
echo -e "${D_CYAN}Installing global npm modules...${WHITE}"
NPM_MODULES=(@devcorex/dev.x typescript @nestjs/cli prettier live-server localtunnel vercel markserv psqlformat npm-check-updates ngrok)
if [[ "${INSTALL_AI}" -eq 1 ]]; then
  NPM_MODULES+=(@google/gemini-cli@0.1.14 @qwen-code/qwen-code@0.0.9)
fi
npm install -g "${NPM_MODULES[@]}"

# fix localtunnel android error (safe/conditional)
OPENURL_PATH="${PREFIX}/lib/node_modules/localtunnel/node_modules/openurl/openurl.js"
if [[ -f "${OPENURL_PATH}" ]] && ! grep -q "case 'android'" "${OPENURL_PATH}"; then
  sed -i "/case 'win32'/,/break;/ a\\    case 'android':\\n        command = 'termux-open-url';\\n        break;" "${OPENURL_PATH}" || true
fi

# zsh setup
if [[ "${INSTALL_ZSH}" -eq 1 ]]; then
  echo -e "${D_CYAN}Installing Oh-My-Zsh and plugins...${WHITE}"

  # download oh-my-zsh shell
  curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o /tmp/ct-install.sh
  sed -i '/exec zsh -l/s/^/#/' /tmp/ct-install.sh
  sh /tmp/ct-install.sh
  rm -f /tmp/ct-install.sh

  # create zsh-plugins directory
  mkdir -p "${HOME}/.zsh-plugins"

  # helper clone once
  clone_once() {
    local url="$1" dir="$2" source_line="$3"
    if [[ -d "${dir}" ]]; then
      echo -e "${GREEN}✓${WHITE} $(basename "${dir}") already present"
      return 0
    fi
    git clone --depth=1 "${url}" "${dir}"
    if [[ -n "${source_line}" ]] && ! grep -qF "${source_line}" "${HOME}/.zshrc"; then
      echo "${source_line}" >> "${HOME}/.zshrc"
    fi
  }

  clone_once "https://github.com/romkatv/zsh-defer.git" "${HOME}/.zsh-plugins/zsh-defer" "source ~/.zsh-plugins/zsh-defer/zsh-defer.plugin.zsh"
  clone_once "https://github.com/romkatv/powerlevel10k.git" "${HOME}/.zsh-plugins/powerlevel10k" "source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme"
  clone_once "https://github.com/zsh-users/zsh-autosuggestions.git" "${HOME}/.zsh-plugins/zsh-autosuggestions" "source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  clone_once "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${HOME}/.zsh-plugins/zsh-syntax-highlighting" "source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  clone_once "https://github.com/zsh-users/zsh-history-substring-search.git" "${HOME}/.zsh-plugins/zsh-history-substring-search" "source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
  if ! grep -q "history-substring-search-up" "${HOME}/.zshrc"; then
    cat >> "${HOME}/.zshrc" <<'ZEOF'
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
ZEOF
  fi
  clone_once "https://github.com/zsh-users/zsh-completions.git" "${HOME}/.zsh-plugins/zsh-completions" "fpath+=~/.zsh-plugins/zsh-completions"
  clone_once "https://github.com/Aloxaf/fzf-tab.git" "${HOME}/.zsh-plugins/fzf-tab" "source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh"
  if ! grep -q "fzf-tab" "${HOME}/.zshrc"; then
    cat >> "${HOME}/.zshrc" <<'ZEOF'
zstyle ':completion:*' menu-select yes
zstyle ':fzf-tab:*' switch-word yes
ZEOF
  fi
  clone_once "https://github.com/MichaelAquilina/zsh-you-should-use.git" "${HOME}/.zsh-plugins/zsh-you-should-use" "source ~/.zsh-plugins/zsh-you-should-use/you-should-use.plugin.zsh"
  clone_once "https://github.com/hlissner/zsh-autopair.git" "${HOME}/.zsh-plugins/zsh-autopair" "source ~/.zsh-plugins/zsh-autopair/autopair.zsh"
  clone_once "https://github.com/lukechilds/zsh-better-npm-completion.git" "${HOME}/.zsh-plugins/zsh-better-npm-completion" "source ~/.zsh-plugins/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh"
  clone_once "https://github.com/marlonrichert/zsh-autocomplete.git" "${HOME}/.zsh-plugins/zsh-autocomplete" "source ~/.zsh-plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

  # core alias + update hook (idempotent)
  if ! grep -q "^core=" "${HOME}/.zshrc"; then
    echo "core='${ROOT_DIR}'" >> "${HOME}/.zshrc"
  fi
  grep -q 'alias ls="lsd"' "${HOME}/.zshrc" || echo 'alias ls="lsd"' >> "${HOME}/.zshrc"
  grep -q 'alias cat="bat --theme=Dracula --style=plain --paging=never"' "${HOME}/.zshrc" || echo 'alias cat="bat --theme=Dracula --style=plain --paging=never"' >> "${HOME}/.zshrc"
  grep -q 'source ${core}/update.sh' "${HOME}/.zshrc" || echo 'source ${core}/update.sh > >(tee /dev/tty) 2>&1' >> "${HOME}/.zshrc"
fi

# custom termux-keys and cursor
mkdir -p "${HOME}/.termux"
TERMUX_PROPS="${HOME}/.termux/termux.properties"
TERMUX_COLORS="${HOME}/.termux/colors.properties"
new_line="extra-keys = [['ESC','</>','-','HOME',{key: 'UP', display: '▲'},'END','PGUP'], ['TAB','CTRL','ALT',{key: 'LEFT', display: '◀'},{key: 'DOWN', display: '▼'},{key: 'RIGHT', display: '▶'},'PGDN']]"

if [[ -f "${TERMUX_PROPS}" ]]; then
  grep -q '^terminal-cursor-blink-rate' "${TERMUX_PROPS}" || echo "terminal-cursor-blink-rate=500" >> "${TERMUX_PROPS}"
  if grep -q '^extra-keys' "${TERMUX_PROPS}"; then
    sed -i "s|^extra-keys =.*|${new_line}|" "${TERMUX_PROPS}"
  else
    echo "${new_line}" >> "${TERMUX_PROPS}"
  fi
else
  printf "terminal-cursor-blink-rate=500\n\n%s\n" "${new_line}" > "${TERMUX_PROPS}"
fi
grep -q '^cursor=' "${TERMUX_COLORS}" 2>/dev/null || echo "cursor=#00FF00" >> "${TERMUX_COLORS}"

# add Meslo Nerd Font
if [[ -f "${ROOT_DIR}/assets/fonts/font.ttf" ]]; then
  cp -f "${ROOT_DIR}/assets/fonts/font.ttf" "${HOME}/.termux/font.ttf"
fi

# apply settings if available
command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings || true

# nvchad setup
if [[ "${INSTALL_NVCHAD}" -eq 1 ]]; then
  echo -e "${D_CYAN}Installing NvChad setup...${WHITE}"

  rm -rf "${HOME}/.config/nvim" "${HOME}/.local/state/nvim" "${HOME}/.local/share/nvim" || true
  git clone https://github.com/DevCoreXOfficial/nvchad-termux.git "${HOME}/.core-termux/nvchad-termux"
  cd "${HOME}/.core-termux/nvchad-termux"
  exec bash nvchad.sh
fi

echo -e "${YELLOW}Setup finished. Restart Termux (or run: exec zsh).${WHITE}"
