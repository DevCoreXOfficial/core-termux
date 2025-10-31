#!/bin/bash
source ~/.core-termux/config

echo -e "${D_CYAN}Updating Core-Termux...${WHITE}"

# node modules list
node_modules=(
  "@devcorex/dev.x"
  "typescript"
  "@nestjs/cli"
  "prettier"
  "live-server"
  "localtunnel"
  "vercel"
  "markserv"
  "psqlformat"
  "@google/gemini-cli"
  "@qwen-code/qwen-code"
  "npm-check-updates"
  "ngrok"
)

# exceptions with fixed version
declare -A fixed_versions
fixed_versions["@google/gemini-cli"]="0.1.14"
fixed_versions["@qwen-code/qwen-code"]="0.0.9"

# update termux repositories
echo -e "${D_CYAN}Updating termux repositories...${WHITE}"
yes | pkg update && yes | pkg upgrade

# new termux-packages
yes | pkg install perl

# new node modules
npm install -g psqlformat @google/gemini-cli@0.1.14 @qwen-code/qwen-code@0.0.9 npm-check-updates ngrok

# update node modules
echo -e "${D_CYAN}Updating node modules...${WHITE}"
for module in "${node_modules[@]}"; do
  if [[ -n "${fixed_versions[$module]}" ]]; then
    # if in exceptions → install fixed version
    fixed_version=${fixed_versions[$module]}
    current_version=$(npm list -g "$module" --depth=0 | grep "$module" | awk -F '@' '{print $NF}')
    
    if [[ "$current_version" != "$fixed_version" ]]; then
      echo -e "Installing fixed version for ${module} → ${fixed_version}"
      npm install -g "${module}@${fixed_version}"
    else
      echo -e "${module} is already at fixed version ${fixed_version}"
    fi
  else
    # otherwise → install the latest version
    if [[ "$module" == "@nestjs/cli" || "$module" == "@devcorex/dev.x" ]]; then
      version=$(npm list -g ${module} --depth=0 | grep ${module} | awk -F '@' '{print $3}')
    else
      version=$(npm list -g ${module} --depth=0 | grep ${module} | awk -F '@' '{print $2}')
    fi

    if [[ "${version}" != "$(npm show ${module} version)" ]]; then
      echo -e "Updating ${module}..."
      npm install -g ${module}@latest
    fi
  fi
done
