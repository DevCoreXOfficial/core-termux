> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** CodeGraph
- **Tags:** ai, code-analysis, graph

- **Dependencias:** nodejs

## ¿Qué es?

Analiza la estructura y dependencias de tu codebase para agentes de IA.

## Binario y referencia CLI

**Binario:** `codegraph`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: codegraph [options] [command]

Code intelligence and knowledge graph for any codebase

Options:
  -V, --version                  output the version number
  --color                        force ANSI colors even when stdout is not a TTY
  --no-color                     disable ANSI colors (NO_COLOR env is also
                                 honored)
  -h, --help                     display help for command

Commands:
  init [options] [path]          Initialize CodeGraph in a project directory and
                                 build the initial index
  uninit [options] [path]        Remove CodeGraph from a project (deletes
                                 .codegraph/ directory)
  index [options] [path]         Rebuild the full index from scratch (same
                                 result as a fresh init)
  sync [options] [path]          Sync changes since last index
  status [options] [path]        Show index status and statistics
  query [options] <search>       Search for symbols in the codebase
  explore [options] <query...>   Explore an area: relevant symbols' source +
                                 call paths in one shot (same output as the
                                 codegraph_explore MCP tool)
  node [options] [name]          One symbol's source + caller/callee trail, or
                                 read a file with line numbers + dependents
                                 (same output as the codegraph_node MCP tool)
  files [options]                Show project file structure from the index
  daemon|daemons                 Manage running CodeGraph background daemons —
                                 pick one and press enter to stop it
  unlock [path]                  Remove a stale lock file that is blocking
                                 indexing
  callers [options] <symbol>     Find all functions/methods that call a specific
                                 symbol
  callees [options] <symbol>     Find all functions/methods that a specific
                                 symbol calls
  impact [options] <symbol>      Analyze what code is affected by changing a
                                 symbol
  affected [options] [files...]  Find test files affected by changed source
                                 files
  install [options]              Install codegraph MCP server into one or more
                                 agents (Claude Code, Cursor, Codex CLI,
                                 opencode, Hermes Agent)
  uninstall [options]            Remove codegraph from your agents (Claude Code,
                                 Cursor, Codex CLI, opencode, Hermes Agent)
  telemetry [action]             Show or change anonymous usage telemetry
                                 (status, on, off)
  upgrade [options] [version]    Update CodeGraph to the latest release (or a
                                 specific version)
  version                        Print the installed CodeGraph version (also:
                                 -v, --version)
  help [command]                 display help for command
```


### Common commands

```bash
codegraph install --yes                              # auto-detect agents, install global
codegraph install --target=cursor,claude --yes       # explicit target list
codegraph install --target=auto --location=local     # detected agents, project-local
codegraph install --target=copilot-vscode,copilot-cli,copilot-jetbrains --yes  # GitHub Copilot everywhere
codegraph install --print-config codex               # print snippet, no file writes
codegraph install --print-config copilot-vscode      # same, for Copilot in VS Code
cd your-project
codegraph init
```

## ¿Cómo usarlo?

```bash
core install codegraph        # instalar
core update codegraph         # actualizar
core uninstall codegraph      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick Start

### 1. Run the Installer

```bash
npx @colbymchenry/codegraph
```

The installer will:
- Ask which agent(s) to configure — auto-detects installed ones from: **Claude Code**, **Cursor**, **Codex CLI**, **opencode**, **Hermes Agent**, **Gemini CLI**, **Antigravity IDE**, **Kiro**, **GitHub Copilot** (VS Code, Copilot CLI, JetBrains IDEs)
- Prompt to install `codegraph` on your PATH (so agents can launch the MCP server)
- Ask whether configs apply to all your projects or just this one
- Write each chosen agent's MCP server config, plus a small marker-fenced CodeGraph section in the agent's instructions file (`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`) — that's how subagents and non-MCP agents learn the `codegraph explore` command, since the MCP server's own guidance only reaches the main agent. Removed cleanly by `codegraph uninstall`.
- Set up auto-allow permissions when Claude Code is one of the targets

The installer **wires up your agents only — it does not index your code.** After it finishes, build each project's graph yourself with `codegraph init` (step 3). One global `codegraph install` covers every project; you run `codegraph init` once per project.

**Non-interactive (scripting / CI):**

```bash
codegraph install --yes                              # auto-detect agents, install global
codegraph install --target=cursor,claude --yes       # explicit target list
codegraph install --target=auto --location=local     # detected agents, project-local
codegraph install --target=copilot-vscode,copilot-cli,copilot-jetbrains --yes  # GitHub Copilot everywhere
codegraph install --print-config codex               # print snippet, no file writes
codegraph install --print-config copilot-vscode      # same, for Copilot in VS Code
```

| Flag | Values | Default |
|---|---|---|
| `--target` | `auto`, `all`, `none`, or csv (`claude,cursor,...`) | prompt |
| `--location` | `global`, `local` | prompt |
| `--yes` | (boolean) | prompt every step |
| `--no-permissions` | (boolean) skip Claude auto-allow list | permissions on |
| `--print-config <id>` | dump snippet for one agent and exit | — |

### 2. Restart Your Agent

Restart your agent (Claude Code / Cursor / Codex CLI / opencode / Hermes Agent / Gemini CLI / Antigravity IDE / Kiro / VS Code, the Copilot CLI, or your JetBrains IDE for GitHub Copilot) for the MCP server to load.

### 3. Initialize Projects

```bash
cd your-project
codegraph init
```

Builds the per-project knowledge graph index, which then auto-syncs on every file change. A single global `codegraph install` works in every project you open — no need to re-run the installer per project.

That's it — your agent will use CodeGraph tools automatically when a `.codegraph/` directory exists.

<details>
<summary><strong>Manual Setup (Alternative)</strong></summary>

**Install globally:**
```bash
npm install -g @colbymchenry/codegraph
```

**Add to `~/.claude.json`:**
```json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "codegraph",
      "args": ["serve", "--mcp"]

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show codegraph`.
