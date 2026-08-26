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
core install oh-my-zsh        # everything at once
core update zsh         # pull latest plugin versions
core uninstall zsh      # remove plugins + Oh My Zsh
```

Then restart your shell or run `exec zsh`.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `zsh`

### `--help` output

```text
Usage: zsh [<options>] [<argument> ...]

Special options:
  --help     show this message, then exit
  --version  show zsh version number, then exit
  -b         end option processing, like --
  -c         take first argument as a command to execute
  -o OPTION  set an option by name (see below)

Normal options are named.  An option may be turned on by
`-o OPTION', `--OPTION', `+o no_OPTION' or `+-no-OPTION'.  An
option may be turned off by `-o no_OPTION', `--no-OPTION',
`+o OPTION' or `+-OPTION'.  Options are listed below only in
`--OPTION' or `--no-OPTION' form.

Named options:
  --aliases
  --aliasfuncdef
  --allexport
  --alwayslastprompt
  --alwaystoend
  --appendcreate
  --appendhistory
  --autocd
  --autocontinue
  --autolist
  --automenu
  --autonamedirs
  --autoparamkeys
  --autoparamslash
  --autopushd
  --autoremoveslash
  --autoresume
  --badpattern
  --banghist
  --bareglobqual
  --bashautolist
  --bashrematch
  --beep
  --bgnice
  --braceccl
  --bsdecho
  --caseglob
  --casematch
  --casepaths
  --cbases
  --cdablevars
  --cdsilent
  --chasedots
  --chaselinks
  --checkjobs
  --checkrunningjobs
  --clobber
  --clobberempty
  --combiningchars
```

