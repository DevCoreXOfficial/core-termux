# Core-Termux — Modular Dev Environment

<p align="center">
  <img src="https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/assets/images/logo.svg" alt="Core-Termux Logo" width="600">
</p>

<p align="center">
  <strong>BUILD. CODE. AUTOMATE.</strong>
</p>

<p align="center">
  <a href="https://github.com/DevCoreXOfficial/core-termux">
    <img src="https://img.shields.io/badge/version-4.4.0-0078D4?style=for-the-badge&logo=appveyor" alt="Version">
  </a>
  <a href="https://github.com/DevCoreXOfficial/core-termux/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-0078D4?style=for-the-badge&logo=bookstack" alt="License">
  </a>
  <a href="https://termux.dev/">
    <img src="https://img.shields.io/badge/platform-Termux%20%7C%20Android-0078D4?style=for-the-badge&logo=android" alt="Platform">
  </a>
</p>

<p align="center">
  <a href="https://github.com/DevCoreXOfficial/core-termux/stargazers">
    <img src="https://img.shields.io/github/stars/DevCoreXOfficial/core-termux?style=for-the-badge&logo=github&color=f5c542" alt="Stars">
  </a>
  <a href="https://github.com/DevCoreXOfficial/core-termux/network/members">
    <img src="https://img.shields.io/github/forks/DevCoreXOfficial/core-termux?style=for-the-badge&logo=github&color=94a3b8" alt="Forks">
  </a>
  <a href="https://github.com/DevCoreXOfficial/core-termux/issues">
    <img src="https://img.shields.io/github/issues/DevCoreXOfficial/core-termux?style=for-the-badge&logo=github&color=ef4444" alt="Issues">
  </a>
  <a href="https://github.com/DevCoreXOfficial/core-termux/pulls">
    <img src="https://img.shields.io/github/issues-pr/DevCoreXOfficial/core-termux?style=for-the-badge&logo=github&color=22c55e" alt="Pull Requests">
  </a>
</p>

<p align="center">
  <a href="https://devcorex-web.vercel.app/core-termux">
    <img src="https://img.shields.io/badge/%F0%9F%9A%80_Get%20Started-0078D4?style=for-the-badge" alt="Get Started">
  </a>
</p>

<br>

**CORE-TERMUX** is a _modular dev environment_ that turns Termux into a complete development workstation. Through a single core CLI, it provides a modular system that covers the full developer stack: programming languages, databases, AI agents, code editors, shell configuration, and automation — all manageable with simple, consistent commands like `core install`, `core update`, and `core uninstall`.

> [!IMPORTANT]
> This project is designed exclusively for **Termux on Android** and is not supported on other platforms.

---

## Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash
```

Then run:

```bash
core
```

---

## Main Commands

| Command | Description |
|---------|-------------|
| [`core --version`](#core---version) | Show current version |
| [`core brain`](#core-brain) | Second brain — save and search memories |
| [`core env`](#core-env) | Manage environment variables |
| [`core install`](#core-install) | Install specific modules |
| [`core show`](#core-show) | Show tool documentation |
| [`core update`](#core-update) | Update modules or framework |
| [`core uninstall`](#core-uninstall) | Remove installed modules |
| [`core reinstall`](#core-reinstall) | Uninstall + reinstall modules |
| [`core voice`](#core-voice) | Speech-to-agent via microphone |
| [`core open`](#core-open) | Open documentation in browser |
| [`core list`](#core-list) | List available tools in modules |
| [`core pg`](#core-pg) | PostgreSQL database manager |
| [`core init`](#core-init) | Configure existing projects |

---

## Common Modules

These modules are available across most commands (`core list`, `core install`, `core update`, `core reinstall`, `core uninstall`, `core show`, and `core open`):

| Module | Description |
|--------|-------------|
| `lang` | Language packages (Node.js, Python, Perl, PHP, Rust, C/C++, Go) |
| `db` | Databases (PostgreSQL, MariaDB, SQLite, MongoDB) |
| `ai` | AI agents and coding assistants — see [AI Agents](#ai-agents) |
| `editor` | Code editor components (Neovim, NvChad) |
| `dev` | Development tools (gh, wget, curl, fzf, lsd, bat, etc.) |
| `npm` | Node.js global npm packages |
| `shell` | ZSH plugins |
| `ui` | Termux UI components |
| `auto` | Automation tools (n8n) |

---

## AI Agents

The `ai` module installs AI-powered coding agents and assistants. Install all agents or pick specific ones with `--flag`:

```bash
core install ai                    # Install all agents
core install ai --opencode --ollama  # Install only OpenCode and Ollama
```

| Agent | Flag | Description |
|-------|------|-------------|
| **Qwen Code** | `--qwen-code` | Alibaba's AI coding assistant |
| **Gemini CLI** | `--gemini-cli` | Google's AI assistant with Gemini |
| **Claude Code** | `--claude-code` | Anthropic's CLI tool with Claude AI |
| **Mistral Vibe** | `--mistral-vibe` | Command-line coding assistant powered by Mistral's models |
| **OpenClaude** | `--openclaude` | Open source Claude Code alternative |
| **OpenClaw** | `--openclaw` | Personal AI Assistant |
| **Ollama** | `--ollama` | Run open-source LLMs locally on Termux |
| **Codex CLI** | `--codex` | Coding agent from OpenAI that runs locally on your computer |
| **OpenCode** | `--opencode` | Open-source agent that helps you write code in your terminal |
| **MiMoCode** | `--mimocode` | Xiaomi's AI coding agent — fast, local, and open-source |
| **Engram** | `--engram` | Persistent memory system for coding agents |
| **CodeGraph** | `--codegraph` | Analyzes your codebase structure and dependencies |
| **Pi** | `--pi` | Minimal terminal coding harness — adapt Pi to your workflows |
| **Antigravity CLI** | `--antigravity-cli` | Lightweight, terminal-first surface for Antigravity agents |
| **MiniMax CLI** | `--minimax-cli` | Generate text, images, video, speech, and music from the terminal |
| **Gentle AI** | `--gentle-ai` | Ecosystem, Frameworks, Workflows for AI coding agents |
| **GGA** | `--gga` | Provider-agnostic AI code review for every commit |
| **Hermes Agent** | `--hermes-agent` | The self-improving AI agent built by Nous Research |
| **Kimi Code** | `--kimi-code` | Kimi Code CLI — The Starting Point for Next-Gen Agents |
| **Command Code** | `--command-code` | The coding agent that learns your coding taste |
| **Freebuff** | `--freebuff` | A 100% free coding agent, right from your terminal |

---

## Detailed Commands

### `core --version`

Display the installed version of Core-Termux.

```bash
core --version
```

**Output:**
```
4.4.0
```

---

### `core env`

Manage environment variables in your shell rc file (`.zshrc` or `.bashrc`). All operations are interactive.

```bash
core env                     # Show help
core env set                 # Add or update a variable (value is hidden while typing)
core env unset               # Remove a variable (shows list to choose from)
core env ls                  # List all user-defined variables
```

**Features:**

- Values are hidden with ● when typing (safe for API keys and tokens)
- Detects existing variables and warns before replacing
- Removes all definitions of the same variable name
- Writes to `.zshrc` if it exists, otherwise `.bashrc`

**Example session:**

```bash
$ core env set

    ┌─────────────────────────────────────────┐
    │         Set Environment Variable        │
    └─────────────────────────────────────────┘

    ┌─ Variable name
    └─▶ OPENAI_API_KEY

    ┌─ Value for OPENAI_API_KEY
    │  (input will be hidden)
    └─▶ ●●●●●●●●●●●●●●

    ✔ Variable OPENAI_API_KEY set in .zshrc
    • Run: source .zshrc to apply

$ core env ls

    ─────── Environment Variables ───────

    File: .zshrc

    OPENAI_API_KEY              = sk-...
    DATABASE_URL                = postgresql://...

    ──────────────────────────────────────
    2 variable(s) in .zshrc
```

---

### `core brain`

Save and search personal learnings and memories — your second brain in markdown files. All operations are local, synced optionally to a private GitHub repo.

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

- Categorized folders (`frontend/`, `devops/`, `linux/`, etc.) with tags for cross-relations
- Auto-suggests relations based on shared tags when saving
- Values hidden with ● when typing for API keys and tokens
- Syncs to a private GitHub repo via `gh` for backup across devices
- Markdown frontmatter consumable by AI agents

**Example session:**

```bash
$ core brain save

    ┌─────────────────────────────────────────┐
    │            Save a New Memory            │
    └─────────────────────────────────────────┘

    ┌─ Title
    └─▶ React Hook Form + Zod patterns

    Existing categories:
    • frontend
    • devops

    ┌─ Category
    └─▶ frontend

    ┌─ Tags (comma separated)
    └─▶ react, forms, zod, typescript

    Write your content below (Ctrl+D to finish, Ctrl+C to cancel):

    After hours testing, la combinación definitiva...
    [Ctrl+D]

    ✔ Memory saved to frontend/2026-06-23_react-hook-form-zod-patterns.md
```

---

### `core voice`

Capture voice from the microphone, review it in nvim, and launch an AI agent.

```bash
core voice                    # Show help
core voice <agent>            # Capture → nvim → launch agent
core voice text               # Capture → nvim → print to stdout
core voice !                  # Alias for 'text'
```

**Requirements:**
- Termux:API package: `pkg install termux-api`
- Neovim for editing: `core install editor`
- Termux:API app: https://devcorex-web.vercel.app/termux/api

> **Note:** `core voice` automatically runs `termux-api-start` before capturing audio to ensure the Termux:API service is running.

**Supported agents:**

| Agent | Command |
|-------|---------|
| `opencode` | `opencode run "prompt"` |
| `claude-code` | `claude -p "prompt"` |
| `codex` | `codex "prompt"` |
| `gemini-cli` | `gemini -p "prompt"` |
| `hermes-agent` | `hermes chat -q "prompt"` |
| `kimi-code` | `kimi -p "prompt"` |
| `mimocode` | `mimo run "prompt"` |
| `mistral-vibe` | `vibe --prompt "prompt"` |
| `openclaude` | `openclaude --bg "prompt"` |
| `pi` | `pi -p "prompt"` |
| `qwen-code` | `qwen -p "prompt"` |
| `text` | Print prompt to stdout |

**Example session:**

```bash
$ core voice opencode

    ➜ Listening through the microphone...
    ➜ Review the prompt in nvim, fix mistakes, then save and quit
    ➜ Launching opencode with prompt…

    # opencode opens with the voice-transcribed prompt
```

---

### `core show`

Display help documentation for any installed tool. Documentation is loaded from the tool's `README.md` file in its module directory.

```bash
core show                    # Show help
core show <module>           # List all tools in a module
core show <module> --<tool>  # Show specific tool documentation
```

**Examples:**

```bash
core show ai --opencode      # Show OpenCode documentation
core show db --postgresql    # Show PostgreSQL documentation
core show npm --typescript   # Show TypeScript documentation
```

**Colorized output:** If `bat` is installed, documentation is displayed with syntax highlighting. Otherwise, plain text is shown.

---

### `core list`

List available tools in a module and their installation status.

```bash
core list                     # Show help
core list <module>            # List tools in specific module
```

All modules from [Common Modules](#common-modules) are valid targets.

---

### `core install`

Install individual modules or specific tools within modules.

```bash
core install                  # Show help
core install <module>         # Install entire module
core install <module> --tool1 --tool2  # Install specific tools
```

All modules from [Common Modules](#common-modules) are valid targets.

**Install entire module:**

```bash
core install ai               # Install all AI tools
core install db               # Install all databases
core install dev              # Install all development tools
```

**Install specific tools:**

```bash
core install ai --qwen-code --ollama          # Install only Qwen Code and Ollama
core install db --postgresql --sqlite         # Install only PostgreSQL and SQLite
core install dev --gh --fzf --jq              # Install only gh, fzf, and jq
core install npm --typescript --prettier      # Install only TypeScript and Prettier
```

> **Tip:** Run `core list <module>` to see all available tools and their flags.

---

### `core update`

Update modules or the complete framework.

```bash
core update                   # Show help
core update <target>          # Update specific target
core update <target> --tool1 --tool2  # Update specific tools
core update core              # Update framework only
```

In addition to all [Common Modules](#common-modules), `core update` also supports:

| Target | Description |
|--------|-------------|
| `core` | Core-Termux framework only |

**Update entire module:**

```bash
core update ai               # Update all AI tools
core update db               # Update all databases
```

**Update specific tools:**

```bash
core update ai --qwen-code --ollama          # Update only Qwen Code and Ollama
core update db --postgresql --sqlite         # Update only PostgreSQL and SQLite
core update dev --gh --fzf --jq             # Update only gh, fzf, and jq
```

---

### `core uninstall`

Remove installed modules or specific tools.

```bash
core uninstall                # Show help
core uninstall <target>       # Uninstall specific target
core uninstall <target> --tool1 --tool2  # Uninstall specific tools
```

In addition to all [Common Modules](#common-modules), `core uninstall` supports per-module and per-tool removal. No "uninstall all" — desinstalá solo lo que necesitás.

**Uninstall specific tools:**

```bash
core uninstall ai --qwen-code --ollama        # Uninstall only Qwen Code and Ollama
core uninstall db --postgresql --sqlite       # Uninstall only PostgreSQL and SQLite
core uninstall dev --gh --fzf                 # Uninstall only gh and fzf
```

---

### `core reinstall`

Reinstall modules or specific tools — uninstalls then installs from scratch.

```bash
core reinstall                # Show help
core reinstall <target>       # Reinstall specific target
core reinstall <target> --tool1 --tool2  # Reinstall specific tools
```

In addition to all [Common Modules](#common-modules), `core reinstall` supports per-module and per-tool reinstallation. No "reinstall all".

**Reinstall specific tools:**

```bash
core reinstall ai --opencode --ollama       # Reinstall only OpenCode and Ollama
core reinstall db --postgresql --sqlite     # Reinstall only PostgreSQL and SQLite
core reinstall dev --gh --fzf               # Reinstall only gh and fzf
```

---

### `core open`

Open official documentation in browser

```bash
core open                     # Show help
core open <target>            # Open official documentation in browser
```

All [Common Modules](#common-modules) are valid targets, plus:

| Target | Description |
|--------|-------------|
| `core` | Core-Termux documentation |
| `devcorex` | DevCoreX official website |

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
- Logs in `~/.cache/core-termux/postgresql.log`

---

### `core init`

Configure existing projects with predefined dependencies and structure.

```bash
core init                     # Show help
core init <template>          # Configure with specific template
```

**Available templates:**

| Template | Description |
|----------|-------------|
| `next` | Next.js with preconfigured dependencies |
| `react` | React + Vite with modern structure |
| `nest` | NestJS with additional configuration |
| `express` | Express API with TypeScript + TypeORM |

**Usage:**

```bash
cd my-next-app && core init next
cd my-react-app && core init react
cd api && core init express
cd backend && core init nest
```

---

## Template Details

### Next.js (`core init next`)

**Installed dependencies:**
```json
{
  "dependencies": {
    "axios": "latest",
    "lucide-react": "latest",
    "framer-motion": "latest",
    "sonner": "latest",
    "zod": "latest",
    "react-hook-form": "latest",
    "@hookform/resolvers": "latest",
    "@tanstack/react-query": "latest",
    "zustand": "latest",
    "tailwindcss": "latest"
  },
  "devDependencies": {
    "prettier": "latest",
    "prettier-plugin-tailwindcss": "latest"
  }
}
```

**Configuration:**
- `.prettierrc` with Tailwind CSS plugin
- Scripts with `--webpack` flag
- DevCoreX landing page included
- Structure: `components/`, `lib/`, `hooks/`, `types/`, `config/`, `store/`

---

### React + Vite (`core init react`)

**Same dependencies as Next.js** (except Next.js-specific configs)

**Configuration:**
- `.prettierrc` with Tailwind CSS plugin
- Custom Button component
- DevCoreX landing page in `src/App.tsx`
- Structure: `components/`, `lib/`, `hooks/`, `types/`, `config/`, `store/`, `pages/`

---

### Express.js (`core init express`)

**Dependencies:**
```
express, pg, typeorm, reflect-metadata
jsonwebtoken, cookie-parser, morgan, cors
bcryptjs, helmet, cloudinary, multer
express-rate-limit, tsconfig-paths, zod
```

**devDependencies:**
```
typescript, ts-node-dev, tsconfig-paths, tsc-alias
@types/node, @types/multer, @types/morgan
@types/jsonwebtoken, @types/helmet
@types/express, @types/cors
@types/cookie-parser, @types/bcryptjs
```

**Scripts added:**
```json
{
  "dev": "ts-node-dev --require tsconfig-paths/register --env-file=.env --respawn src/index.ts",
  "build": "tsc && tsc-alias -p tsconfig.json",
  "start": "node dist/index.js",
  "typeorm": "ts-node-dev --require tsconfig-paths/register --env-file=.env ./node_modules/typeorm/cli.js",
  "mg:gen": "npm run typeorm -- migration:generate -d src/database/data-source.ts",
  "mg:create": "npm run typeorm -- migration:create",
  "mg:run": "npm run typeorm -- migration:run -d src/database/data-source.ts",
  "mg:revert": "npm run typeorm -- migration:revert -d src/database/data-source.ts",
  "mg:show": "npm run typeorm -- migration:show -d src/database/data-source.ts"
}
```

**Structure created:**
```
src/
├── app.ts                 # Express configuration
├── index.ts               # Entry point
├── config/
│   └── env.ts            # Environment variables
├── database/
│   ├── data-source.ts    # TypeORM DataSource
│   ├── migrations/
│   └── seeds/
├── entities/
├── controllers/
├── repositories/
├── services/
├── routes/
├── schemas/              # Zod schemas
├── middlewares/
├── types/
└── utils/
```

**Configured files:**
- `tsconfig.json` with paths (`@/*`)
- `.env.example`
- `src/config/env.ts`
- `src/database/data-source.ts` (TypeORM)
- `src/app.ts` (Express with CORS, helmet, rate-limit)
- `src/index.ts`

---

### NestJS (`core init nest`)

**Dependencies:**
```
@nestjs/typeorm, typeorm, pg
@nestjs/jwt, @nestjs/passport
class-validator, class-transformer
bcryptjs, helmet, cloudinary
```

---

## Language Packages

The `lang` module installs the following programming languages and runtimes via `pkg`:

```bash
core install lang
```

| Language/Runtime | Package | Description |
|------------------|---------|-------------|
| **Node.js LTS** | `nodejs-lts` | Long-term support release of Node.js |
| **Python** | `python` | Python 3 interpreter |
| **Perl** | `perl` | Perl scripting language |
| **PHP** | `php` | PHP interpreter |
| **Rust** | `rust` | Rust compiler and Cargo |
| **C/C++** | `clang` | LLVM C/C++ compiler |
| **Go** | `golang` | Go programming language |

---

## Development Tools

The `dev` module installs the following development utilities via `pkg`:

```bash
core install dev
```

| Tool | Package | Description |
|------|---------|-------------|
| **GitHub CLI** | `gh` | Official GitHub command-line tool |
| **Wget** | `wget` | File downloader |
| **Curl** | `curl` | HTTP client and transfer tool |
| **LSD** | `lsd` | Modern `ls` replacement with icons and colors |
| **Bat** | `bat` | Modern `cat` replacement with syntax highlighting |
| **Proot** | `proot` | Chroot alternative for user-space |
| **Ncurses Utils** | `ncurses-utils` | Terminal UI manipulation tools |
| **Tmate** | `tmate` | Instant terminal sharing |
| **Cloudflared** | `cloudflared` | Cloudflare Tunnel client |
| **Translate Shell** | `translate-shell` | Command-line translator |
| **html2text** | `html2text` | HTML to plain text converter |
| **jq** | `jq` | Lightweight JSON processor |
| **bc** | `bc` | Arbitrary precision calculator |
| **Tree** | `tree` | Recursive directory listing |
| **Fzf** | `fzf` | Command-line fuzzy finder |
| **ImageMagick** | `imagemagick` | Image manipulation suite |
| **Shfmt** | `shfmt` | Shell script formatter |
| **Make** | `make` | Build automation tool |
| **Udocker** | `udocker` | Run Docker containers without root |

---

## Node.js Global Modules

The `npm` module installs the following global npm packages:

```bash
core install npm
```

| Package | Command | Description |
|---------|---------|-------------|
| **TypeScript** | `tsc` | TypeScript compiler |
| **NestJS CLI** | `nest` | NestJS framework CLI |
| **Prettier** | `prettier` | Code formatter |
| **Live Server** | `live-server` | Development server with live reload |
| **Localtunnel** | `lt` | Expose localhost to the internet |
| **Vercel CLI** | `vercel` | Vercel deployment CLI |
| **Markserv** | `markserv` | Markdown live-preview server |
| **PSQL Format** | `psqlformat` | PostgreSQL query formatter |
| **NPM Check Updates** | `ncu` | Find outdated dependencies |
| **Ngrok** | `ngrok` | Secure tunnel to localhost |

---

## Code Editor

The `editor` module installs **Neovim** with a custom configuration based on [NvChad](https://github.com/DevCoreXOfficial/nvchad-termux).

**Installation:**
```bash
core install editor
```

**Features:**
- **Neovim** - Fast, extensible code editor
- **NvChad** - Modern Neovim configuration
- **GitHub Copilot** - AI-powered code completion
- **CodeCompanion** - AI chat assistant for code
- **Preconfigured plugins** - LSP, autocomplete, syntax highlighting, file explorer, etc.

**Included languages:**
- TypeScript/JavaScript
- Python
- PHP
- Perl
- Rust
- Lua
- And more...

**For detailed information about the editor configuration, plugins, and usage:**
→ Visit: [https://github.com/DevCoreXOfficial/nvchad-termux](https://github.com/DevCoreXOfficial/nvchad-termux)

---

## UI and Logs

The framework includes a professional logging system with colors, icons, and animations, plus a startup banner with random tips.

### Log Functions

```bash
log_info "Info message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"
log_debug "Debug message (requires CORE_DEBUG=1)"
```

### Loading Spinner

Hides shell output while running commands:

```bash
LOG_FILE="$CORE_CACHE/install.log"

loading "Installing packages" _install_function

_install_function() {
    pkg install packages -y &>"$LOG_FILE"
}
```

### Separators

```bash
separator              # Single line
separator_double       # Double line
separator_section "Title"  # Centered title with line
```

### Boxes

```bash
box "Title"
box_large "Large title"
box_with_subtitle "Title" "Subtitle"
```

### Interactive Inputs

```bash
# Text input
read_input "Name" VAR_NAME

# Confirmation (y/n)
read_confirm "Continue?" VAR_NAME

# Selection with arrow keys ↑↓
read_select "Environment" VAR_NAME "Dev" "Staging" "Production"

# Hidden input (API keys, tokens, passwords) ●●●
read_secret "Value" VAR_NAME

# Multi-line input (no editor needed)
file=$(read_multiline "# Title")
content=$(cat "$file")
rm -f "$file"
```

### Tables

```bash
table_start "Col1" "Col2" "Col3"
table_row "value1" "value2" "value3"
table_end
```

---

## Banner Tips

Every time you open a new Termux session (or run the banner), Core-Termux shows a random tip to help you discover features you might not know about. Tips cover all modules: installing tools, using `core brain`, managing databases, voice commands, project initialization, and more.

The tip system:
- Picks a random tip from a pool of 65+ tips on each session
- Never shows the same tip twice in a row
- Covers every module and command in the framework

To refresh the tips pool or customize them, edit `core/utils/banner.sh`.

---

## Project Structure

```
core-termux/
├── LICENSE
├── README.md
├── assets
│   ├── fonts
│   │   └── font.ttf
│   └── images
│       └── logo.svg
├── core
│   ├── bin
│   │   └── core
│   ├── cli
│   │   ├── commands
│   │   │   ├── --version.sh
│   │   │   ├── brain.sh
│   │   │   ├── env.sh
│   │   │   ├── init.sh
│   │   │   ├── install.sh
│   │   │   ├── list.sh
│   │   │   ├── pg.sh
│   │   │   ├── reinstall.sh
│   │   │   ├── show.sh
│   │   │   ├── uninstall.sh
│   │   │   ├── update.sh
│   │   │   └── voice.sh
│   │   └── core.sh
│   ├── modules
│   │   ├── ai.sh
│   │   ├── auto.sh
│   │   ├── db.sh
│   │   ├── dev.sh
│   │   ├── editor.sh
│   │   ├── lang.sh
│   │   ├── npm.sh
│   │   ├── shell.sh
│   │   └── ui.sh
│   ├── tools
│   │   ├── ai/
│   │   │   ├── all.sh
│   │   │   ├── qwen-code/
│   │   │   │   ├── install.sh
│   │   │   │   └── README.md
│   │   │   ├── claude-code/
│   │   │   │   ├── install.sh
│   │   │   │   ├── bin/claude
│   │   │   │   └── README.md
│   │   │   ├── opencode/
│   │   │   │   ├── install.sh
│   │   │   │   ├── bin/opencode
│   │   │   │   └── README.md
│   │   │   ├── freebuff/
│   │   │   │   ├── install.sh
│   │   │   │   ├── bin/freebuff
│   │   │   │   ├── helper/freebuff_helper.c
│   │   │   │   └── README.md
│   │   │   └── ... (13 tools, each with own directory)
│   │   ├── npm/
│   │   ├── lang/
│   │   ├── db/
│   │   ├── editor/
│   │   ├── dev/
│   │   ├── shell/
│   │   ├── ui/
│   │   └── auto/
│   └── utils
│       ├── bootstrap.sh
│       ├── banner.sh
│       ├── colors.sh
│       ├── env.sh
│       └── log.sh
└── install.sh
```

---

## Configuration

### Environment Variables

```bash
export CORE_DEBUG=1    # Enable debug logs
```

### Directories

| Directory | Description |
|-----------|-------------|
| `~/.local/share/core-termux-data` | Persistent tool data (codegraph, engram, nvchad) |
| `~/.cache/core-termux` | Logs and cache |
| `~/.config/core-termux` | User configuration |

### Log Files

All processes save logs to:

```
~/.cache/core-termux/
├── install_lang.log
├── install_db.log
├── install_ai.log
├── install_editor.log
├── install_dev.log
├── install_npm.log
├── install_shell.log
├── install_ui.log
├── install_auto.log
├── postgresql.log
├── last_version_check      # Last update check timestamp
└── new_version             # New version available (if exists)
```

---

## Automatic Updates

The framework checks for updates automatically:

- **Frequency:** Once every 24 hours
- **Impact:** None (runs in background)
- **Notification:** Shown when running `core` if new version exists

```bash
$ core

── Update Available ─────────────────────────────────

⚠ New version available: 4.4.1 (current: 4.4.0)

➜ Run: core update core to update
```

To update:

```bash
core update core
```

---

## ZSH Shell

When installing the `shell` module:

### Installed Plugins

| Plugin | Description |
|--------|-------------|
| powerlevel10k | Modern and fast theme |
| zsh-defer | Deferred plugin loading |
| zsh-autosuggestions | Smart autocompletion |
| zsh-syntax-highlighting | Syntax highlighting |
| zsh-history-substring-search | History search |
| zsh-completions | Additional completions |
| fzf-tab | Fuzzy navigation in completions |
| zsh-you-should-use | Command suggestions |
| zsh-autopair | Auto-close parentheses |
| zsh-better-npm-completion | Better npm completion |

### Persistent Session

The shell saves the current directory and restores it when opening a new session:

```bash
# Session 1
$ cd projects/my-app
$ exit

# Session 2
$ pwd
/data/data/com.termux/files/home/projects/my-app  ← Same directory
```

**Configuration:**
- Saves path to `~/.cache/core-termux/last_dir`
- Automatically restored on startup
- Falls back to `$HOME` if directory doesn't exist

## Usage Examples

### Install specific modules

```bash
core install db
core install shell
core install npm
```

### Install specific tools within a module

```bash
core list ai                                    # See available AI tools
core install ai --qwen-code --ollama            # Install only Qwen Code and Ollama
core install dev --gh --fzf --jq                # Install only gh, fzf, and jq
core install npm --typescript --prettier        # Install only TypeScript and Prettier
```

### Reinstall

```bash
core reinstall ai             # Reinstall all AI agents
core reinstall shell          # Reinstall ZSH + plugins
core reinstall ai --opencode --ollama  # Reinstall specific tools
```

### Configure Next.js project

```bash
npx create-next-app@latest my-app
cd my-app
core init next
```

### Manage PostgreSQL

```bash
core pg init              # First time
core pg start             # Start
core pg create mydb       # Create database
core pg shell             # Open psql
core pg stop              # Stop
```

### Update

```bash
core update core          # Framework only
core update shell         # ZSH plugins only
core update ai --qwen     # Specific AI tool only
```

### Uninstall

```bash
core uninstall npm        # Remove Node.js modules
core uninstall ai --ollama   # Remove only Ollama
```

### List available tools

```bash
core list ai              # List all AI tools and their status
core list dev             # List all development tools
core list db              # List all databases
```

---

## Important Notes

1. **Restart Termux:** After installing `shell` or `ui`, restart Termux to apply changes
2. **Permissions:** Ensure you have write permissions in the installation directory
3. **Connection:** Some installations require internet connection
4. **Logs:** Check `~/.cache/core-termux/` if something fails

---

## License

MIT License
