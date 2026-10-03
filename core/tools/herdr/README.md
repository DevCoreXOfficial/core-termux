# Herdr

Terminal workspace manager for AI coding agents

**Package:** herdr  
**Author:** Herdr  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/herdrdev/herdr  
**Type:** Development tool (prebuilt static binary)  
**License:** See upstream repository

## Description

Herdr is a terminal multiplexer and workspace manager built around AI coding
agents. It follows the tmux/zellij model — prefix is `ctrl+b`, panes persist,
detach and reattach work as expected — but adds agent-aware features: it
detects coding agents running in panes, reports their live state (idle,
working, waiting for approval), keeps a sidebar of connected agents, and can
restore native agent conversations after a restart.

It is also mouse-first: you can click panes, drag borders, and split or switch
from right-click menus without learning shortcuts.

## Termux note

Herdr upstream does **not** support Android/Termux. Its own installer exits with
an error when `uname -o` reports `Android`, and the docs list only Linux, macOS
and Windows.

The `linux-aarch64` and `linux-x86_64` release assets are fully static ELF
binaries, so they do run on Termux without a glibc or musl shim. This installer
reimplements the upstream installer with the Android gate removed, keeping the
same release manifest and the same SHA-256 verification:

- Manifest: `https://herdr.dev/latest.json`
- Target selected from `uname -m` (`aarch64` / `x86_64`)
- Downloaded asset verified against the manifest SHA-256 before install

On Termux the binary is installed to `$PREFIX/bin/herdr`; on Ubuntu/WSL it goes
to `~/.local/bin/herdr`. You are running an unofficial configuration on
Android. If upstream adds first-class Android support later, prefer their
installer again.

## Dependencies

- Installed automatically by Core (`curl`, `coreutils`)

## Install

```bash
core install herdr
```

## Usage

```bash
herdr                  # Launch or attach to the persistent session
herdr status           # Show local client and running server status
herdr --help           # Full command list
```

Common subcommands:

| Command | Description |
|---------|-------------|
| `herdr session <cmd>` | Create, list, attach, stop named sessions |
| `herdr workspace <cmd>` | Manage workspaces |
| `herdr pane <cmd>` | Manage panes |
| `herdr tab <cmd>` | Manage tabs |
| `herdr agent <cmd>` | Inspect and drive detected agents |
| `herdr machine <cmd>` | Add and manage saved SSH machines |
| `herdr worktree <cmd>` | Manage git worktree workspaces |
| `herdr api <cmd>` | Local socket API |
| `herdr server stop` | Stop the running server |
| `herdr update` | Update Herdr itself (installer-managed installs) |
| `herdr channel set <stable\|preview>` | Switch update channel |

Herdr integrates with many coding agents. Detection is automatic for agents on
your PATH; `herdr agent` lists what it currently sees.

## Configuration

- `~/.config/herdr/config.toml` — main configuration
- `~/.herdr/` — data directory (override with `HERDR_HOME`)

Reference: https://herdr.dev/docs/configuration/

## Update

```bash
core update herdr
```

Downloads the latest release from the manifest, re-verifies the SHA-256, and
replaces the installed binary.

## Uninstall

```bash
core uninstall herdr
```

Removes the binary. You will be asked whether to also delete `~/.config/herdr`
and `~/.herdr`; the default is to keep them.
