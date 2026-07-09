#!/data/data/com.termux/files/usr/bin/bash

install_gemini_cli() {
  npm install -g @google/gemini-cli
}

uninstall_gemini_cli() {
  npm uninstall -g @google/gemini-cli
}

update_gemini_cli() {
  npm install -g @google/gemini-cli@latest
}

reinstall_gemini_cli() {
  uninstall_gemini_cli
  install_gemini_cli
}
