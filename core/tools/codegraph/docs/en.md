## Package Information

- **Name:** CodeGraph
- **Tags:** ai, code-analysis, graph
- **Project:** https://github.com/colbymchenry/codegraph
- **Dependencies:** nodejs

## What is it?

Analyzes your codebase structure and dependencies to improve navigation

## How to use it?

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

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show codegraph:es`.
