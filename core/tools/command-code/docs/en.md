## Package Information

- **Name:** Command Code
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

The coding agent that learns your coding taste.

**Package:** command-code  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/CommandCodeAI/command-code
**Type:** AI coding assistant (npm local package with wrapper)  
**License:** MIT

### Description

The first frontier coding agent that both builds software and continuously learns your coding taste. Ships full-stack projects, features, fixes bugs, writes tests, and refactors, all while learning how you write code.

### Why Local Install?

On Termux, the global `npm install -g command-code` creates a binary named `cmd` which conflicts with the existing Termux `cmd` binary. Core solves this by:

1. Installing `command-code` locally in `~/.local/share/core-data/command-code/`
2. Creating a wrapper script at `$PREFIX/bin/command-code`
3. Adding an alias `cmdc` via symlink

### Dependencies

- Node.js LTS (nodejs-lts)
- npm
- git
- ripgrep

### Install

```bash
core install ai --command-code
```

### Uninstall

```bash
core uninstall ai --command-code
```

### Update

```bash
core update ai --command-code
```

### Commands

| Command | Description |
|---------|-------------|
| `command-code` | Run Command Code |
| `cmdc` | Alias for command-code |

### Notes

- Installed as a local npm package (avoids `cmd` binary conflict)
- Wrapper script created at `$PREFIX/bin/command-code`
- Alias `cmdc` created via symlink
- Data directory: `~/.local/share/core-data/command-code/`
- Requires Node.js LTS (installed automatically if missing)

## How to use it?

```bash
core install command-code      # install
core update command-code       # update
core uninstall command-code    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show command-code:es`.
