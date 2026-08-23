# Core — Multiplatform Dev Environment

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

**CORE** is a _multiplatform dev environment_ that turns your terminal into a complete development workstation — on Termux/Android, Ubuntu Linux and Ubuntu on WSL. Through a single `core` CLI it covers the full developer stack: programming languages, databases, AI agents, code editors, shell configuration and automation — all manageable with simple, consistent commands like `core install`, `core update` and `core uninstall`.

Every tool installs individually and is found by name:

```bash
core install opencode
```

Core detects your platform automatically and runs the right installer: the Termux-specific one on Android (with its glibc/proot workarounds), or official upstream methods on Ubuntu and WSL.

> [!IMPORTANT]
> Core is the evolution of Core-Termux (v4.x). Since v5.0.0 it officially supports **Termux/Android**, **Ubuntu Linux**, and **Ubuntu on WSL (Windows)**.

---

## Supported Platforms

| Platform | Environment | Package Manager | Install Methods |
|----------|-------------|-----------------|-----------------|
| Termux / Android | `termux` | `pkg` | Termux-specific installers (glibc bootstrappers, proot modes, interactive method selection) |
| Ubuntu Linux | `ubuntu` | `apt` | Official upstream installers |
| Ubuntu (WSL) | `wsl` | `apt` | Official upstream installers |

Other distributions (Debian, Fedora, Arch...) are not supported yet, but the architecture is ready for them: detection is generic and each tool declares its installers per platform.

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
| [`core search`](#core-search) | Search tools by keyword |
| [`core install`](#core-install) | Install tools |
| [`core show` / `core about`](#core-show--core-about) | Show tool documentation (English/Spanish) |
| [`core update`](#core-update) | Update tools or framework |
| [`core uninstall`](#core-uninstall) | Remove tools, with orphan dependency cleanup |
| [`core reinstall`](#core-reinstall) | Uninstall + reinstall tools |
| [`core voice`](#core-voice) | Speech-to-agent via microphone (Termux) |
| [`core open`](#core-open) | Open documentation in browser |
| [`core pg`](#core-pg) | PostgreSQL database manager |
| [`core init`](#core-init) | Configure existing projects |

---

## Detailed Commands

### `core --version`

Display the installed version of Core.

```bash
core --version
```

**Output:**
```
5.0.0
```

---

### `core search`

Discover tools. There are no categories to memorize — every search matches tool **names**, **descriptions** and **tags**.

```bash
core search              # Help for this command
core search --all        # Every tool with colored install status
core search <text>       # Filter by keyword
```

**Output columns:**

| Column | Meaning |
|--------|---------|
| Name | Human-friendly name (e.g. `KiloCode CLI`) |
| Tool | The argument you pass to commands (e.g. `kilocode`) |
| Status | `installed` (green) / `not installed` (red) |

**Examples:**

```bash
core search tunnel       # ngrok, cloudflared, localtunnel...
core search js           # JavaScript/TypeScript ecosystem tools
core search db           # databases + SQL formatters
```

---

### `core install`

Install one or more tools. Each tool is resolved by name across the whole catalog — no prefixes, no categories.

```bash
core install <tool>
core install <tool1> <tool2> ...
```

**Examples:**

```bash
core install opencode            # single tool
core install gh jq fzf           # several at once
core install neovim              # Neovim + NvChad configured in one shot
core install zsh                 # ZSH + Oh My Zsh + 10 plugins in one shot
```

Some Termux installers offer **interactive installation methods** (e.g. OpenCode offers native glibc, glibc+proot, or proot-distro). The menu appears during installation — pick the one that suits your device.

**What happens under the hood:**

1. The engine locates the tool's manifest.
2. Declared dependencies are installed first (shared ones only once).
3. Your platform's installer runs as an isolated process.
4. The installation is registered for status tracking.

---

### `core uninstall`

Remove installed tools. Before removing, Core asks whether to keep or delete the tool's configuration files. After removal, it analyzes dependencies:

- A dependency is offered for removal **only if no other installed tool uses it** (orphan).
- Shared dependencies are **never** removed automatically.

```bash
core uninstall <tool>
core uninstall <tool1> <tool2> ...
```

**Example session:**

```bash
$ core uninstall opencode

    ┌─ Delete OpenCode config files? [y/N]
    └─▶ n
    ✔ Keeping OpenCode configuration files
    ✔ OpenCode uninstalled

    ┌─ Remove orphaned dependency 'jq'? (no other Core tool uses it) [y/N]
    └─▶ y
    ✔ jq removed
```

---

### `core update`

Update tools or the framework itself. Flow per tool:

```
local version → remote version → compare → different? → suggest update
```

The update is suggested **only when versions differ**.

```bash
core update <tool>       # update one tool
core update core         # update the framework (git pull)
```

The framework also self-checks once every 24 hours and notifies on startup when a new version exists:

```bash
$ core

── Update Available ─────────────────────────────────

⚠ New version available: 5.1.0 (current: 5.0.0)

➜ Run: core update core to update
```

---

### `core reinstall`

Uninstall + install from scratch.

```bash
core reinstall <tool>
```

---

### `core show` / `core about`

Display a tool's documentation. `about` is an alias of `show`. Documentation defaults to English; append `:es` for Spanish when available.

```bash
core show opencode           # English (default)
core about opencode          # same as above
core show opencode:es        # Spanish
```

Every tool's documentation follows a mandatory structure:

- **Package Information** — name, tags, project link, dependencies
- **What is it?** — what the tool actually is
- **How to use it?** — practical usage
- **Notes** — warnings, compatibility, platform details

If rendered with `glow` or `bat`, documentation gets syntax highlighting; otherwise plain text is shown.

---

### `core open`

Open official documentation in your browser.

```bash
core open                # Show help
core open                # Core documentation
core open devcorex       # DevCoreX website
```

---

### `core agent`

Local AI assistant and task agent backed by an OpenAI-compatible endpoint (default: `gemma-4-e2b-it-cq4` served by Cactus Engine on `http://127.0.0.1:8000/v1`). `ask` answers questions with colored markdown; `run` is a full agent that writes files and runs commands on your machine. If the model server is down, the agent starts `cactus` in the background (logs → `~/.cache/core/core-agent.log`) and stops it when you leave the interactive shell.

```bash
core agent ask -p "Explain rsync"                     # One-shot question
core agent run -p "create a backup script"            # One-shot task (files + commands)
core agent ask                                        # Interactive chat shell
core agent run                                        # Interactive agent shell
core agent status                                     # Endpoint/model status
core agent config                                     # Show or edit saved settings
```

**Options (ask & run):**

| Option | Description |
|--------|-------------|
| `-p, --prompt <text>` | Task/question (omit for the interactive shell) |
| `-m, --model <name>` | Model id (default: `gemma-4-e2b-it-cq4`) |
| `-u, --endpoint <url>` | OpenAI-compatible endpoint (default: `http://127.0.0.1:8000/v1`) |
| `-t, --temperature <n>` | Sampling temperature (default: `0.3`) |
| `--max-tokens <n>` | Max output tokens (default: `2048`) |
| `-w, --workspace <dir>` | Agent working dir (run mode, default: `$PWD`) |
| `-n, --max-iterations <n>` | Agent loop limit (default: `12`) |
| `-y, --yes` | Auto-approve commands (skip y/N prompt) |
| `--plan` | Plan mode (read-only): no file writes, write commands blocked |
| `--build` | Build mode (default): files and commands applied |

**Files & commands:**

- Type `@name` in a message to attach a file's contents (live fzf picker while typing)
- Start a message with `!` for shell mode (e.g. `!git status`) — the output is added to the agent's context
- Commands from the model run only after your `y/N` confirmation (`-y` auto-approves)
- Press `ESC ESC` at any prompt to cancel the agent
- The interactive REPL remembers the conversation and shows `[context % · elapsed]` after each answer/task
- Dictate your prompt with `/voice` (Termux:API)

**Interactive slash commands:** `/help`, `/model <name>`, `/endpoint <url>`, `/temp <n>`, `/max <n>`, `/workspace <dir>`, `/plan`, `/build`, `/voice`, `/clear`, `/history`, `/status`, `/exit`

**Plan vs Build mode:** in **Plan mode** (`--plan` or `/plan`) the agent is read-only — `## File:` blocks are ignored, write commands (rm, mv, mkdir, redirections, git commit, package installs...) are blocked, and only read-only commands run. Use it to explore and get a concrete plan before touching anything, then switch to **Build mode** (`/build`) to apply it.

**Example session:**

```bash
$ core agent ask

    you ▸ explain git rebase vs merge

    git rebase rewrites the history of your current branch...
```

> **Tip:** `core agent` also runs as a walkie agent — `walkie agent <channel> --cli core`.

---

### `core brain`

Save and search personal learnings and memories — your second brain in markdown files. All operations are local, optionally synced to a private GitHub repo.

```bash
core brain                    # Dashboard with stats
core brain init               # Initialize brain directory and GitHub repo
core brain save               # Interactive: save a new memory
core brain search <query>     # Search memories by keywords or tags
core brain ls [category]      # List memories by category
core brain edit               # Edit a memory in your $EDITOR
core brain edit <slug>        # Edit a memory by slug name
core brain delete             # Delete a memory permanently
core brain show <slug>        # View a memory with its relations
core brain reset              # Destroy the entire brain
core brain graph              # Visual map of all connections
core brain skill              # Create an AI skill from memories
core brain relate             # Link two memories interactively
core brain sync               # Push/pull to GitHub private repo
```

**Memory format (AI-consumable markdown):**

```markdown
---
title: React Hook Form + Zod validation
tags: [react, forms, typescript, zod]
created: 2026-06-23
category: frontend
related: [nextjs-server-actions]
---

# React Hook Form + Zod validation

After hours of testing, the combination that worked...
```

**Features:**

- Categorized folders with tags for cross-relations
- Auto-suggests relations based on shared tags when saving
- Values hidden with ● when typing for API keys and tokens
- Syncs to a private GitHub repo via `gh` for backup across devices
- Markdown frontmatter consumable by AI agents

---

### `core env`

Manage environment variables in your shell rc file (`.zshrc` or `.bashrc`). All operations are interactive.

```bash
core env                     # Show help
core env set                 # Add or update a variable (value hidden while typing)
core env unset               # Remove a variable (shows list to choose from)
core env ls                  # List all user-defined variables
```

**Features:**

- Values are hidden with ● when typing (safe for API keys and tokens)
- Detects existing variables and warns before replacing
- Removes all definitions of the same variable name
- Writes to `.zshrc` if it exists, otherwise `.bashrc`

---

### `core voice`

Capture voice from the microphone, review it in nvim, and launch an AI agent.

```bash
core voice                    # Show help
core voice <agent>            # Capture → nvim → launch agent
core voice text               # Capture → nvim → print to stdout
core voice !                  # Alias for 'text'
```

**Requirements (Termux):**
- Termux:API package: `pkg install termux-api`
- Termux:API app installed on Android
- Neovim for editing: `core install neovim`

**Supported agents:**

| Agent | Command |
|-------|---------|
| `opencode` | `opencode run "prompt"` |
| `qoder` | `qodercli -p "prompt"` |
| `claude-code` | `claude -p "prompt"` |
| `codex` | `codex "prompt"` |
| `gemini-cli` | `gemini -p "prompt"` |
| `hermes-agent` | `hermes chat -q "prompt"` |
| `kilocode` | `kilo run "prompt"` |
| `kimi-code` | `kimi -p "prompt"` |
| `mimocode` | `mimo run "prompt"` |
| `mistral-vibe` | `vibe --prompt "prompt"` |
| `openclaude` | `openclaude --bg "prompt"` |
| `pi` | `pi -p "prompt"` |
| `qwen-code` | `qwen -p "prompt"` |
| `text` | Print prompt to stdout |

> **Note:** `core voice` automatically runs `termux-api-start` before capturing audio to ensure the Termux:API service is running.

---

### `core pg`

PostgreSQL database manager.

```bash
core pg                       # Show help
core pg start                 # Start server
core pg stop                  # Stop server
core pg restart               # Restart server
core pg status                # Check status
core pg init                  # Initialize database
core pg create <name>         # Create database
core pg drop <name>           # Drop database
core pg list                  # List databases
core pg shell                 # Open psql console
```

**Features:**
- Automatic data directory detection
- Support for existing installations
- Logs in `~/.cache/core/postgresql.log`

---

### `core init`

Configure existing projects with predefined dependencies, folder structure, and tooling. Detects your package manager (npm, pnpm, yarn, or bun) and installs dependencies accordingly.

```bash
core init                     # Auto-detect project type and configure
core init <template>          # Configure with specific template
```

**What it does:**

1. **Detects package manager** — npm, pnpm, yarn or bun from lock files or binaries
2. **Installs dependencies** — optional packages based on your selections
3. **Creates folder structure** — modular architecture with `src/components/`, `src/services/`, etc.
4. **Generates config files** — `.prettierrc`, `.env.example`, `tsconfig.json` and more
5. **Preserves existing scripts** — your `dev`, `build`, `start` stay untouched

**Available templates:**

| Template | Description |
|----------|-------------|
| `next` | Next.js with optional Turbopack, TypeScript, Tailwind CSS |
| `react` | React + Vite with modern structure |
| `nest` | NestJS with TypeORM and authentication |
| `express` | Express API with TypeScript + TypeORM + migrations |

**Usage:**

```bash
cd my-next-app && core init next
cd my-react-app && core init react
cd api && core init express
cd backend && core init nest
```

On Termux, the Next.js template can also configure **Turbopack** via the glibc toolchain (`core install turbopack`).

---

## Tool Catalog Highlights

Run `core search --all` for the complete live catalog. Notable bundles:

### Languages & runtimes

`nodejs`, `python`, `rust`, `golang`, `bun`, `clang`, `php`, `perl`, `typescript` — installed from `pkg` on Termux and from apt/official channels on Ubuntu/WSL.

### Essentials

`gh`, `curl`, `wget`, `jq`, `fzf`, `bat`, `lsd`, `tree`, `make`, `tmux`, `tmate`, `openssh`, `proot`, `imagemagick`, `shfmt`, `translate`, `html2text`, `bc`, `ncurses`, `superfile`...

### Cloud & tunnels

`vercel`, `ngrok`, `localtunnel`, `cloudflared`, `udocker`, `tmate`, `n8n`.

### Node.js global CLIs

`nestjs`, `prettier`, `ncu`, `live-server`, `markserv` — installed globally through npm/bun with automatic fallback between them.

### AI agents (38)

OpenCode, Claude Code, Gemini CLI, Qwen Code, Codex, KiloCode CLI, Cursor CLI, Goose, Ollama, Engram, CodeGraph, Walkie, Context7, Hugging Face CLI and many more. On Termux, tools needing glibc offer interactive installation methods (native glibc / glibc+proot / proot-distro); on Ubuntu and WSL everything installs from official sources without workarounds.

### Editor bundle

`neovim` — installs Neovim plus the NvChad-based configuration in one shot: LSP, autocomplete, syntax highlighting, file explorer, GitHub Copilot and CodeCompanion preconfigured.

### Shell bundle

`zsh` — ZSH + Oh My Zsh + powerlevel10k + zsh-defer, zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search, zsh-completions, fzf-tab, zsh-you-should-use, zsh-autopair and zsh-better-npm-completion. Also sets `lsd`/`bat` aliases, zoxide, Go environment variables and persistent sessions (new terminals restore your last directory).

### Appearance

`font` (Meslo Nerd Font), `banner` (ASCII banner on new sessions) and `cursor-color` work on all three platforms. `extra-keys` is Termux-only.

---

## Framework Internals

### Log functions

```bash
log_info "Info message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"
log_debug "Debug message (requires CORE_DEBUG=1)"
```

### Loading spinner

Hides output while running commands (logs go to `$LOG_FILE`):

```bash
LOG_FILE="$CORE_CACHE/install.log"

loading "Installing packages" _install_function

_install_function() {
    pkg install packages -y &>"$LOG_FILE"
}
```

### Interactive inputs

```bash
read_input "Name" VAR_NAME            # Text input
read_confirm "Continue?" VAR_NAME     # Confirmation (y/n)
read_select "Pick one" VAR_NAME "A" "B"   # Arrow-key selection ↑↓
read_secret "Value" VAR_NAME          # Hidden input ●●●
```

### Tables & separators

```bash
table_start "Col1" "Col2" "Col3"
table_row "value1" "value2" "value3"
table_end

separator
separator_section "Title"
box "Title"
```

---

## Banner Tips

Every new session shows a random tip covering modules, commands and features. The tip pool lives in `core/utils/banner.sh` and never repeats the same tip twice in a row.

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
            ├── manifest.json  # metadata, platforms, tags, dependencies
            ├── docs/
            │   ├── en.md      # default language
            │   └── es.md      # optional translation
            ├── termux/        # Termux/Android installer + its assets
            │   ├── install.sh
            │   ├── helper/    # C helpers compiled on-device (when needed)
            │   └── bin/       # wrappers/bootstrappers (when needed)
            └── ubuntu/        # Ubuntu Linux + WSL installer + its assets
                └── install.sh
```

### Adding a new tool

Create one directory, three files — done. No central case statements to modify:

```
tools/mytool/
├── manifest.json
├── docs/en.md
├── termux/install.sh
└── ubuntu/install.sh
```

### Manifests

```json
{
  "name": "sqlite",
  "display": "SQLite",
  "description": "Self-contained, serverless SQL database engine",
  "platforms": ["termux", "ubuntu", "wsl"],
  "check_cmd": "sqlite3",
  "homepage": "https://www.sqlite.org",
  "tags": ["db", "sql", "embedded"],
  "dependencies": [
    { "name": "curl", "check": "curl",
      "pkg": { "termux": "curl", "ubuntu": "curl" } }
  ]
}
```

### Installation engine

1. Resolve the tool by name (flat `tools/` scan).
2. Check platform support declared in the manifest.
3. Ensure declared dependencies (shared ones installed once).
4. Execute `termux/install.sh` or `ubuntu/install.sh` as an isolated process.
5. Register the installation.

Uninstall mirrors the flow, asks about configs, then analyzes dependencies for orphans (see [`core uninstall`](#core-uninstall)).

---

## Shebangs & Wrappers

- Cross-platform scripts use `#!/usr/bin/env bash`.
- Generated Termux wrappers use the mandatory `#!/data/data/com.termux/files/usr/bin/bash`.
- Ubuntu/WSL wrappers use `#!/bin/bash` / `#!/usr/bin/env bash`.

---

## Configuration & Directories

```bash
export CORE_DEBUG=1    # Enable debug logs
```

| Directory | Description |
|-----------|-------------|
| `~/.local/share/core-data` | Persistent tool data (codegraph, engram, nvchad, ...) |
| `~/.cache/core` | Logs and cache |
| `~/.config/core` | User configuration |

All processes save logs to `~/.cache/core/install_<tool>.log`.

Existing Core-Termux directories migrate automatically on first run.

---

## Usage Examples

```bash
core                          # dashboard + help
core search                   # search help
core search --all             # all tools + colored status
core search tunnel            # filter by keyword
core install nodejs           # individual install
core install zsh              # full shell environment in one command
core show opencode            # docs (EN)
core show opencode:es         # docs (ES)
core update core              # update the framework
core update opencode          # compare versions, suggest update
core uninstall sqlite         # remove + orphan analysis
```

---

## Important Notes

1. **Restart your shell** after installing `zsh` or appearance tools.
2. **Logs**: check `~/.cache/core/` if something fails.
3. **Termux-specific workarounds** (glibc, proot) stay isolated inside each tool's `termux/` folder; Ubuntu/WSL always use official methods.

---

## License

MIT License
