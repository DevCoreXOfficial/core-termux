## Package Information

- **Name:** tmux
- **Tags:** terminal, multiplexer, sessions
- **Project:** https://github.com/tmux/tmux
- **Dependencies:** None required by Core

## What is it?

Terminal multiplexer for managing multiple sessions

**Package:** tmux  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/tmux/tmux  
**Type:** Development tool (pkg)  
**License:** ISC

### Description

Tmux is a terminal multiplexer that allows you to run multiple terminal sessions in a single window, detach and reattach sessions, split panes, and manage windows. Essential for remote development and persistent workflows.

### Dependencies

- Installed via pkg

### Install

```bash
core install tmux
```

### Uninstall

```bash
core uninstall tmux
```

### Update

```bash
core update tmux
```

### Notes

- Command: `tmux`
- Config file: `~/.tmux.conf`
- Supports sessions, windows, and panes
- Detach with `Ctrl+b d`, reattach with `tmux attach`

## How to use it?

```bash
core install tmux      # install
core update tmux       # update
core uninstall tmux    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show tmux:es`.
