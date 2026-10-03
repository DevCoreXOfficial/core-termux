## Package Information

- **Name:** herdr
- **Tags:** terminal, multiplexer, sessions, agents, ai
- **Project:** https://herdr.dev
- **Source:** https://github.com/herdrdev/herdr
- **Dependencies:** curl, coreutils (installed automatically by Core)

## What is it?

Terminal workspace manager for AI coding agents.

Herdr is a terminal multiplexer and workspace manager built around AI coding
agents. It follows the tmux/zellij model — prefix is `ctrl+b`, panes persist,
detach and reattach work as expected — but adds agent-aware features: it
detects coding agents running in panes, reports their live state (idle,
working, waiting for approval), keeps a sidebar of connected agents, and can
restore native agent conversations after a restart.

It is also mouse-first: you can click panes, drag borders, and split or switch
from right-click menus without learning shortcuts.

## How to use it?

Launch or attach to the persistent session:

```bash
herdr
```

Check the client and server state:

```bash
herdr status
```

Full command list:

```bash
herdr --help
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

## Binary & CLI Reference

- **Binary:** `herdr`

### `--help` output

```text
herdr — terminal workspace manager for AI coding agents

Usage: herdr [options]
       herdr --session <name> [options]
       herdr --machine <label-or-id> <command>
       herdr --remote <ssh-target> [--session <name>]
       herdr session attach <name>
       herdr completion zsh
       herdr update [--handoff]
       herdr channel set <stable|preview>
       herdr machine <subcommand> ...
       herdr server stop
       herdr server reload-config
       herdr api <subcommand> ...
       herdr completion <shell>
       herdr config <subcommand> ...
       herdr channel <subcommand> ...
       herdr workspace <subcommand> ...
       herdr worktree <subcommand> ...
       herdr tab <subcommand> ...
       herdr notification <subcommand> ...
       herdr agent <subcommand> ...
       herdr pane <subcommand> ...
       herdr session <subcommand> ...
       herdr integration <subcommand> ...

Common commands:
  herdr                            Launch or attach to the persistent session
  herdr status [server|client]     Show local client and running server status
  herdr update                     Download and install the latest version
```

## Configuration

- `~/.config/herdr/config.toml` — main configuration
- `~/.herdr/` — data directory (override with `HERDR_HOME`)

Reference: https://herdr.dev/docs/configuration/

## Notes

### Termux support

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
to `~/.local/bin/herdr`.

You are running an unofficial configuration on Android. If upstream adds
first-class Android support later, prefer their installer again.
