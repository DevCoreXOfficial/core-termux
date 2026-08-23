## Package Information

- **Name:** ZSH Shell Environment
- **Tags:** shell, prompt, plugins, oh-my-zsh
- **Project:** https://www.zsh.org / https://ohmyz.sh
- **Dependencies:** git, fzf

## What is it?

A complete, preconfigured ZSH environment: Oh My Zsh, powerlevel10k theme, and 9 productivity plugins installed and wired into your `.zshrc` in a single command.

### Included plugins

powerlevel10k (theme), zsh-defer, zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search, zsh-completions, fzf-tab, zsh-you-should-use, zsh-autopair, zsh-better-npm-completion.

### Extras

- `lsd`/`bat` aliases and `zoxide` init
- Go environment variables
- Persistent session: new terminals restore your last directory

## How to use it?

```bash
core install zsh        # everything at once
core update zsh         # pull latest plugin versions
core uninstall zsh      # remove plugins + Oh My Zsh
```

Then restart your shell or run `exec zsh`.

## Notes

- On Ubuntu/WSL run `chsh -s $(which zsh)` to make ZSH your default shell.
- Uninstall keeps your `.zshrc` (only the cloned plugin directories are removed).
- The persistent-session feature stores state under `~/.cache/core/`.
