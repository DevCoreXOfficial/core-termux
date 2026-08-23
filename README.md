# Core — Modular Multiplatform Dev Environment

<p align="center">
  <img src="https://raw.githubusercontent.com/DevCoreXOfficial/core/main/assets/images/logo.svg" alt="Core Logo" width="600">
</p>

<p align="center">
  <strong>One CLI — Your environment. Everywhere.</strong>
</p>

<p align="center">
  <a href="https://github.com/DevCoreXOfficial/core">
    <img src="https://img.shields.io/badge/version-5.0.0-0078D4?style=for-the-badge&logo=appveyor" alt="Version">
  </a>
  <a href="https://github.com/DevCoreXOfficial/core/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-0078D4?style=for-the-badge&logo=bookstack" alt="License">
  </a>
  <img src="https://img.shields.io/badge/platform-Termux%20%7C%20Ubuntu%20%7C%20WSL-0078D4?style=for-the-badge&logo=linux" alt="Platform">
</p>

<p align="center">
  <a href="https://devcorex-web.vercel.app/core">
    <img src="https://img.shields.io/badge/%F0%9F%9A%80_Get%20Started-0078D4?style=for-the-badge" alt="Get Started">
  </a>
</p>

<br>

**CORE** is a _modular dev environment_ that turns your terminal into a complete development workstation — on Termux, Ubuntu, and WSL. Through a single `core` CLI, it provides a modular system covering the full developer stack: programming languages, databases, AI agents, code editors, shell configuration, and automation — all manageable with simple, consistent commands like `core install`, `core update`, and `core uninstall`.

> [!IMPORTANT]
> Core is the evolution of Core-Termux (v4.x). Since v5.0.0 it officially supports **Termux/Android**, **Ubuntu Linux**, and **Ubuntu on WSL (Windows)**.

---

## Supported Platforms

| Platform | Environment | Package Manager | Install Methods |
|----------|-------------|-----------------|-----------------|
| Termux / Android | `termux` | `pkg` | Termux-specific installers (glibc, proot workarounds kept where needed) |
| Ubuntu Linux | `ubuntu` | `apt` | Official upstream installers |
| Ubuntu (WSL) | `wsl` | `apt` | Official upstream installers |

Core detects your environment automatically at startup. The same command produces the right behavior on every platform:

```bash
core install opencode
```

Internally this resolves to the Termux installer on Android, or to OpenCode's official install script on Ubuntu and WSL. You never specify the platform.

> Other distributions (Debian, Fedora, Arch...) are not supported yet, but the architecture is prepared for them: detection is generic and tools declare their installers per platform.

---

## Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core/main/install.sh | bash
```

Then run:

```bash
core
```

Requirements: `bash`, `git`, `curl`. The installer bootstraps everything else (`jq`, `glow`, `bat`) using your platform's package manager.

---

## Migrating from Core-Termux 4.x

Core installs to its own directory (`~/.core/core`) and replaces the `core` command on your PATH. Nothing else is touched:

| What | Migration behavior |
|------|--------------------|
| Tools installed via `pkg`/`apt`/`npm` | Keep working as-is — no reinstalls needed |
| Tool data (`core-termux-data`) | Moved automatically to `~/.local/share/core-data` on first run; a symlink keeps old paths valid for compiled wrappers |
| Cache & config (`cache/core-termux`, `config/core-termux`) | Same automatic migration |
| Old repository clone (`~/.local/share/core-termux`) | Left untouched — delete it manually once you're happy |

**Rollback** (return to Core-Termux 4.x at any time):

```bash
ln -sf ~/.local/share/core-termux/core/bin/core "$PREFIX/bin/core"   # Termux
# or: ln -sf ~/.local/share/core-termux/core/bin/core ~/.local/bin/core  # Ubuntu/WSL
rm -rf ~/.core                                                       # optional cleanup
```

---

## Main Commands

| Command | Description |
|---------|-------------|
| [`core --version`](#core---version) | Show current version |
| [`core agent`](#core-agent) | Local AI assistant & task agent |
| [`core brain`](#core-brain) | Second brain — save and search memories |
| [`core env`](#core-env) | Manage environment variables |
| [`core install`](#core-install) | Install tools |
| [`core show` / `core about`](#core-show--core-about) | Show tool documentation (English/Spanish) |
| [`core update`](#core-update) | Update tools or framework |
| [`core uninstall`](#core-uninstall) | Remove tools, with orphan dependency cleanup |
| [`core reinstall`](#core-reinstall) | Uninstall + reinstall tools |
| [`core voice`](#core-voice) | Speech-to-agent via microphone (Termux) |
| [`core open`](#core-open) | Open documentation in browser |
| [`core search`](#core-list) | List available tools |
| [`core pg`](#core-pg) | PostgreSQL database manager |
| [`core init`](#core-init) | Configure existing projects |

### Individual tool commands

Tools are resolved **by name** and installed **individually**:

```bash
core install opencode
core install postgresql
core install neovim          # editor + NvChad configured in one shot
core install zsh             # shell + Oh My Zsh + 10 plugins in one shot
core show fzf                # documentation by tool name
core uninstall gh
```

Categories exist for **browsing**, not bulk installing:

```bash
core search                    # all tools with install status
core search cloud              # filtered by keyword
```

---

## Browsing & Searching Tools

Tools live flat — nothing to memorize:

| Command | Description |
|---------|-------------|
| `core search` | Help for this command |
| `core search --all` | Every tool with colored install status |
| `core search <text>` | Filter by name, description or tags (`core search tunnel`, `core search js`) |
| `core show <tool>` | Documentation for one tool |
| `core show <tool>:es` | Spanish documentation when available |

---

## Documentation: `core show` and `core about`

`about` is an alias of `show` — both render a tool's documentation.

```bash
core show opencode           # English (default)
core about opencode          # same as above
core show opencode:es        # Spanish
core about postgresql:es     # Spanish
```

Every tool's documentation follows a mandatory structure:

- **Package Information** — name, original author(s), official project, links, dependencies
- **What is it?** — what the tool actually is
- **How to use it?** — practical usage
- **Notes** — warnings, compatibility, platform details

Documentation quality comes first: docs are written from official sources before translations are added. When Spanish is not available yet, Core falls back to English automatically.

---

## Architecture

```
~/.core/core/
├── install.sh                 # multiplatform bootstrap installer
└── core/
    ├── bin/core               # entrypoint (#!/usr/bin/env bash)
    ├── cli/
    │   ├── core.sh            # dispatcher
    │   └── commands/          # one file per command
    ├── lib/
    │   ├── platform.sh        # environment / distro / package-manager detection
    │   ├── manifest.sh        # manifest.json reader + discovery
    │   ├── registry.sh        # installed-tools registry + orphan deps logic
    │   └── engine.sh          # install / update / uninstall orchestration
    ├── utils/                 # log, colors, banner, version, agent...
    └── tools/
        └── <tool>/             # flat — no categories
            ├── manifest.json  # metadata, platforms, tags
            ├── docs/
            │   ├── en.md      # default language
            │   └── es.md      # optional translation
            ├── termux/        # Termux/Android: installer + its assets
            │   └── install.sh
            └── ubuntu/        # Ubuntu Linux + WSL: installer + its assets
                └── install.sh
```

### Separation of concepts

Platform detection separates **environment** (`termux | linux | wsl`), **distribution** (`ubuntu`, ...), **package manager** (`pkg | apt`, extensible), and **platform id** used to resolve scripts. Adding a future distribution means adding its id, its package manager mapping, and per-tool `install/<distro>.sh` files — without touching the engine.

### Manifests

Each tool declares itself via `manifest.json`:

```json
{
  "name": "sqlite",
  "display": "SQLite",
  "platforms": ["termux", "ubuntu", "wsl"],
  "check_cmd": "sqlite3",
  "homepage": "https://www.sqlite.org",
  "dependencies": [
    { "name": "curl", "check": "curl",
      "pkg": { "termux": "curl", "ubuntu": "curl" } }
  ]
}
```

Adding a new tool = create its directory + manifest + platform installers. No central case statements to modify.

### Installation engine

1. Resolve the tool by name (scan the flat tools/ directory).
2. Check platform support declared in the manifest.
3. Ensure dependencies (shared ones are installed once).
4. Execute the platform installer as an isolated process
   (`termux/install.sh` on Android, `ubuntu/install.sh` on Ubuntu/WSL).
5. Register the installation.

Uninstall mirrors the flow and then analyzes dependencies: a dependency is offered for removal **only when no other installed tool uses it**. Shared dependencies are never removed automatically.

### Update flow

```
local version → remote version → compare → different? → suggest update
```

The framework also self-checks once every 24 hours and notifies on `core` startup when a new version exists.

---

## Shebangs & Wrappers

- Cross-platform scripts use `#!/usr/bin/env bash`.
- Generated Termux wrappers use the mandatory `#!/data/data/com.termux/files/usr/bin/bash`.
- Ubuntu/WSL wrappers use `#!/bin/bash` / `#!/usr/bin/env bash`.

---

## Directories

| Directory | Description |
|-----------|-------------|
| `~/.local/share/core-data` | Persistent tool data (codegraph, engram, nvchad, ...) |
| `~/.cache/core` | Logs and cache |
| `~/.config/core` | User configuration |

Existing Core-Termux directories are migrated automatically on first run of v5.0.0.

---

## The Core Ecosystem

`core brain`, `core agent`, `core env`, `core pg`, and the rest of the ecosystem run identically on all three platforms. See [`core <command>`](#main-commands) help for full usage; detailed examples remain available in the v4 documentation and `core open`.

---

## Usage Examples

```bash
core                          # dashboard + help
core search                   # all tools + status
core search cloud             # filter by keyword
core install nodejs           # individual install
core install zsh              # full shell environment in one command
core show opencode            # docs (EN)
core show opencode:es         # docs (ES)
core update core              # update the framework
core uninstall sqlite         # remove + orphan analysis
```

---

## Important Notes

1. **Restart your shell** after installing `shell` or `ui` (Termux).
2. **Logs**: check `~/.cache/core/` if something fails.
3. **Termux-specific workarounds** (glibc, proot) stay isolated inside `install/termux.sh`; Ubuntu/WSL always use official methods.

---

## License

MIT License
