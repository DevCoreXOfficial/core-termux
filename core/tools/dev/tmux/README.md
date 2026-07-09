# Tmux

Terminal multiplexer for managing multiple sessions

**Package:** tmux  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/tmux/tmux  
**Type:** Development tool (pkg)  
**License:** ISC

## Description

Tmux is a terminal multiplexer that allows you to run multiple terminal sessions in a single window, detach and reattach sessions, split panes, and manage windows. Essential for remote development and persistent workflows.

## Dependencies

- Installed via pkg

## Install

```bash
core install dev --tmux
```

## Uninstall

```bash
core uninstall dev --tmux
```

## Update

```bash
core update dev --tmux
```

## Notes

- Command: `tmux`
- Config file: `~/.tmux.conf`
- Supports sessions, windows, and panes
- Detach with `Ctrl+b d`, reattach with `tmux attach`
