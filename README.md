<p align="center">
  <img src="https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/assets/images/logo.svg" alt="Core-Termux Logo" width="120" height="120">
</p>

<h1 align="center">Core-Termux</h1>

<p align="center">
  <strong>Modular framework for setting up and managing development environments on Termux (Android)</strong>
</p>

<p align="center">
  <a href="https://github.com/DevCoreXOfficial/core-termux">
    <img src="https://img.shields.io/badge/version-3.5.0-0078D4?style=for-the-badge&logo=appveyor" alt="Version">
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
  <a href="#-quick-installation">
    <img src="https://img.shields.io/badge/%F0%9F%9A%80_Get%20Started-0078D4?style=for-the-badge" alt="Get Started">
  </a>
</p>

<br>

---

## 🚀 Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash
```

Then run:

```bash
core setup
```

---

## 📋 Main Commands

| Command | Description |
|---------|-------------|
| [`core setup`](#core-setup) | Interactive installation wizard |
| [`core install`](#core-install) | Install specific modules |
| [`core update`](#core-update) | Update modules or framework |
| [`core uninstall`](#core-uninstall) | Remove installed modules |
| [`core list`](#core-list) | List available tools in modules |
| [`core pg`](#core-pg) | PostgreSQL database manager |
| [`core init`](#core-init) | Configure existing projects |

---

## 📦 Detailed Commands

### `core setup`

Interactive wizard with keyboard navigation.

```bash
core setup                    # Interactive menu
core setup full               # Automatic full installation
core setup base               # Base packages only
```

**Interactive menu options:**
- **Full installation** → Install all modules
- **Custom installation** → Select specific modules with ↑↓
- **Base installation** → Termux base packages only

---

### `core list`

List available tools in a module and their installation status.

```bash
core list                     # Show help
core list <module>            # List tools in specific module
```

**Available targets:**

| Target | Description |
|--------|-------------|
| `language` | Language packages (Node.js, Python, Perl, PHP, Rust, C/C++) |
| `db` | Databases (PostgreSQL, MariaDB, SQLite, MongoDB) |
| `ai` | AI tools (Qwen Code, Gemini CLI, Mistral Vibe, OpenClaude, Claude Code, OpenClaw, Ollama) |
| `editor` | Code editor components (Neovim, NvChad) |
| `tools` | Development tools (gh, wget, curl, fzf, lsd, bat, etc.) |
| `node` | Node.js global npm packages |
| `shell` | ZSH plugins |
| `ui` | Termux UI components |
| `automation` | Automation tools (n8n) |

**Example output:**

```bash
$ core list ai

┌─────────────────────────────────────────┐
│  AI Tools                               │
└─────────────────────────────────────────┘

    ➜ Available AI tools and install commands:

┌────────────────┬──────────────────┬──────────┬────────────────┐
│ Tool           │ Install Flag     │ Command  │ Status         │
├────────────────┼──────────────────┼──────────┼────────────────┤
│ Qwen Code      │ --qwen-code      │ qwen     │ not installed  │
│ Gemini CLI     │ --gemini-cli     │ gemini   │ not installed  │
│ Claude Code    │ --claude-code    │ claude   │ not installed  │
│ ...            │ ...              │ ...      │ ...            │
└────────────────┴──────────────────┴──────────┴────────────────┘

    ➜ Install specific: core install ai --qwen-code --ollama
    ➜ Install all: core install ai
```

---

### `core install`

Install individual modules or specific tools within modules.

```bash
core install                  # Show help
core install <module>         # Install entire module
core install <module> --tool1 --tool2  # Install specific tools
core install full             # Install everything
```

**Available modules:**

| Module | Description |
|--------|-------------|
| `language` | Node.js, Python, Perl, PHP, Rust, C/C++ |
| `db` | PostgreSQL, MariaDB, SQLite, MongoDB |
| `ai` | Qwen Code, Gemini CLI, Mistral Vibe, OpenClaude, Claude Code, OpenClaw, Ollama |
| `editor` | Neovim + NvChad configuration |
| `tools` | GitHub CLI, wget, curl, fzf, lsd, bat, etc. |
| `node` | Node.js global npm packages |
| `shell` | ZSH + Oh My Zsh + 10 plugins |
| `ui` | Termux UI (font, cursor, extra-keys) |
| `automation` | Automation Tools (n8n) |

**Install entire module:**

```bash
core install ai               # Install all AI tools
core install db               # Install all databases
core install tools            # Install all development tools
```

**Install specific tools:**

```bash
core install ai --qwen-code --ollama          # Install only Qwen Code and Ollama
core install db --postgresql --sqlite         # Install only PostgreSQL and SQLite
core install tools --gh --fzf --jq            # Install only gh, fzf, and jq
core install node --typescript --prettier     # Install only TypeScript and Prettier
```

> **Tip:** Run `core list <module>` to see all available tools and their flags.

---

### `core update`

Update modules or the complete framework.

```bash
core update                   # Show help
core update <target>          # Update specific target
core update <target> --tool1 --tool2  # Update specific tools
core update all               # Update everything
core update core              # Update framework only
```

**Update targets:**

| Target | Description |
|--------|-------------|
| `all` | Framework + all installed packages |
| `core` | Core-Termux framework only |
| `language` | Language packages (pkg upgrade) |
| `db` | Databases |
| `ai` | AI tools (npm/pip) |
| `editor` | Code editor configuration |
| `tools` | Development tools |
| `node` | Node.js global modules |
| `shell` | ZSH plugins |
| `ui` | Termux UI |
| `automation` | Automation Tools |

**Update entire module:**

```bash
core update ai               # Update all AI tools
core update db               # Update all databases
```

**Update specific tools:**

```bash
core update ai --qwen-code --ollama          # Update only Qwen Code and Ollama
core update db --postgresql --sqlite         # Update only PostgreSQL and SQLite
core update tools --gh --fzf --jq            # Update only gh, fzf, and jq
```

---

### `core uninstall`

Remove installed modules or specific tools.

```bash
core uninstall                # Show help
core uninstall <target>       # Uninstall specific target
core uninstall <target> --tool1 --tool2  # Uninstall specific tools
core uninstall all            # Remove everything (restore default)
```

**Uninstall targets:**

| Target | Description |
|--------|-------------|
| `all` | Remove everything and restore Termux to default |
| `language` | Language packages |
| `db` | Databases |
| `ai` | AI tools |
| `editor` | Code editor |
| `tools` | Development tools |
| `node` | Node.js modules |
| `shell` | ZSH + Oh My Zsh |
| `ui` | Restore Termux UI to default |
| `automation` | Automation tools |

**Uninstall entire module:**

```bash
core uninstall ai            # Uninstall all AI tools
core uninstall db            # Uninstall all databases
```

**Uninstall specific tools:**

```bash
core uninstall ai --qwen-code --ollama        # Uninstall only Qwen Code and Ollama
core uninstall db --postgresql --sqlite       # Uninstall only PostgreSQL and SQLite
core uninstall tools --gh --fzf               # Uninstall only gh and fzf
```

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

## 🔧 Template Details

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
typescript, ts-node-dev, tsconfig-paths
@types/node, @types/multer, @types/morgan
@types/jsonwebtoken, @types/helmet
@types/express, @types/cors
@types/cookie-parser, @types/bcryptjs
```

**Scripts added:**
```json
{
  "dev": "ts-node-dev --require tsconfig-paths/register --env-file=.env --respawn src/index.ts",
  "build": "tsc",
  "start": "ts-node-dev --require tsconfig-paths/register --respawn dist/index.js",
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

## 🌐 Language Packages

The `language` module installs the following programming languages and runtimes via `pkg`:

```bash
core install language
```

| Language/Runtime | Package | Description |
|------------------|---------|-------------|
| **Node.js LTS** | `nodejs-lts` | Long-term support release of Node.js |
| **Python** | `python` | Python 3 interpreter |
| **Perl** | `perl` | Perl scripting language |
| **PHP** | `php` | PHP interpreter |
| **Rust** | `rust` | Rust compiler and Cargo |
| **C/C++** | `clang` | LLVM C/C++ compiler |

---

## 🛠️ Development Tools

The `tools` module installs the following development utilities via `pkg`:

```bash
core install tools
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

---

## 📦 Node.js Global Modules

The `node` module installs the following global npm packages:

```bash
core install node
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

> **Note:** The `node` module automatically applies a [fix for localtunnel on Android](#localtunnel-for-android) to replace `openurl` with `termux-open-url`.

---

## 💻 Code Editor

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

## 🎨 UI and Logs

The framework includes a professional logging system with colors, icons, and animations.

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
```

### Tables

```bash
table_start "Col1" "Col2" "Col3"
table_row "value1" "value2" "value3"
table_end
```

---

## 🗂️ Project Structure

```
core-termux/
├── assets/
│   └── fonts/
│       └── font.ttf          # Meslo Nerd Font (downloaded)
├── core/
│   ├── bin/
│   │   └── core              # Entry point
│   ├── cli/
│   │   ├── core.sh           # CLI logic
│   │   └── commands/
│   │       ├── install.sh    # Install command
│   │       ├── setup.sh      # Setup command
│   │       ├── update.sh     # Update command
│   │       ├── uninstall.sh  # Uninstall command
│   │       ├── list.sh       # List command
│   │       ├── pg.sh         # PostgreSQL command
│   │       └── init.sh       # Init command
│   ├── modules/
│   │   ├── ai.sh             # AI tools
│   │   ├── db.sh             # Databases
│   │   ├── editor.sh         # Code editor
│   │   ├── language.sh       # Language packages
│   │   ├── node-modules.sh   # Node.js npm packages
│   │   ├── shell.sh          # ZSH + plugins
│   │   ├── tools.sh          # Tools
│   │   ├── ui.sh             # Termux UI
│   │   └── automation.sh     # Automation Tools
│   ├── tools/
│   │   ├── ai/
│   │   │   └── all.sh        # Individual AI tool installers
│   │   ├── db/
│   │   │   └── all.sh        # Individual DB installers
│   │   ├── tools/
│   │   │   └── all.sh        # Individual tool installers
│   │   ├── node/
│   │   │   └── all.sh        # Individual node module installers
│   │   ├── language/
│   │   │   └── all.sh        # Individual language installers
│   │   ├── shell/
│   │   │   └── all.sh        # Individual shell plugin installers
│   │   ├── editor/
│   │   │   └── all.sh        # Individual editor installers
│   │   ├── ui/
│   │   │   └── all.sh        # Individual UI component installers
│   │   └── automation/
│   │       └── all.sh        # Individual automation installers
│   ├── fix/
│   │   └── localtunnel.sh    # Android fix
│   └── utils/
│       ├── bootstrap.sh      # Framework bootstrap
│       ├── colors.sh         # ANSI colors
│       ├── env.sh            # Environment variables
│       └── log.sh            # Log functions
├── install.sh                # Auto-installer
└── README.md                 # This file
```

---

## ⚙️ Configuration

### Environment Variables

```bash
export CORE_DEBUG=1    # Enable debug logs
```

### Directories

| Directory | Description |
|-----------|-------------|
| `~/.cache/core-termux` | Logs and cache |
| `~/.config/core-termux` | User configuration |

### Log Files

All processes save logs to:

```
~/.cache/core-termux/
├── install_language.log
├── install_db.log
├── install_ai.log
├── install_editor.log
├── install_tools.log
├── install_node_modules.log
├── install_shell.log
├── install_ui.log
├── install_automation.log
├── fix_localtunnel.log
├── postgresql.log
├── last_version_check      # Last update check timestamp
└── new_version             # New version available (if exists)
```

---

## 🔄 Automatic Updates

The framework checks for updates automatically:

- **Frequency:** Once every 24 hours
- **Impact:** None (runs in background)
- **Notification:** Shown when running `core` if new version exists

```bash
$ core

── Update Available ─────────────────────────────────

⚠ New version available: 3.5.1 (current: 3.5.0)

➜ Run: core update core to update
```

To update:

```bash
core update core
```

---

## 🐚 ZSH Shell

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

---

## 🛠️ Included Fixes

### localtunnel for Android

The fix corrects the `openurl` error on Android by using `termux-open-url`.

**Automatic application:**
- Applied when installing the `node` module
- No user intervention required

**Fix location:**
```
$PREFIX/lib/node_modules/localtunnel/node_modules/openurl/openurl.js
```

---

## 📝 Usage Examples

### Full installation

```bash
core setup full
```

### Install specific modules

```bash
core install db
core install shell
core install node
```

### Install specific tools within a module

```bash
core list ai                                    # See available AI tools
core install ai --qwen-code --ollama            # Install only Qwen Code and Ollama
core install tools --gh --fzf --jq              # Install only gh, fzf, and jq
core install node --typescript --prettier       # Install only TypeScript and Prettier
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
core update all           # Update everything
core update core          # Framework only
core update shell         # ZSH plugins only
core update ai --qwen     # Specific AI tool only
```

### Uninstall

```bash
core uninstall node       # Remove Node.js modules
core uninstall ai --ollama   # Remove only Ollama
core uninstall all        # Restore everything to default
```

### List available tools

```bash
core list ai              # List all AI tools and their status
core list tools           # List all development tools
core list db              # List all databases
```

---

## ⚠️ Important Notes

1. **Restart Termux:** After installing `shell` or `ui`, restart Termux to apply changes
2. **Permissions:** Ensure you have write permissions in the installation directory
3. **Connection:** Some installations require internet connection
4. **Logs:** Check `~/.cache/core-termux/` if something fails

---

## 📄 License

MIT License
