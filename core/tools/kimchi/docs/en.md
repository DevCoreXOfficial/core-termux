## Package Information

- **Name:** Kimchi
- **Tags:** ai, agent, coding
- **Source:** https://github.com/getkimchi/kimchi
- **Dependencies:** None required by Core

## What is it?

Terminal coding agent powered by Kimchi's multi-model orchestration 

## How to use it?

### Quick start

Install the latest release:

**Homebrew (macOS / Linux):**

```bash
brew install getkimchi/tap/kimchi
```

**Install script (macOS / Linux):**

```bash
curl -fsSL https://github.com/getkimchi/kimchi/releases/latest/download/install.sh | bash
```

**PowerShell (Windows):**

```powershell
irm https://github.com/getkimchi/kimchi/releases/latest/download/install.ps1 | iex
```

Then configure your API key and launch:

```bash
kimchi setup   # one-time interactive setup
kimchi         # launch the coding agent
```

Run `kimchi --help` to see all available subcommands and flags.

## Models

### Model selection

The supported model list is fetched at startup from the kimchi metadata service. Use `/model` or `ctrl+p` in the interactive CLI to switch between available models.

Kimchi operates in one of two modes:

| Mode | Status line indicator | Behavior |
|------|-----------------|----------|
| **Multi-model** | `multi-model (orchestrator-id)` | The orchestrator delegates each task to the model assigned for that role |
| **Single-model** | model name | All work runs on the selected model directly |

Use `ctrl+p` to cycle through models. The last entry in the cycle is `multi-model`. You can also open the `/model` picker and select a specific model or `multi-model` from the list.

In single-model mode the orchestration system prompt (environment, tools, research rules, guidelines, phase tagging) stays active, but task classification and delegation are disabled. The subagent tool remains available if you explicitly ask the agent to delegate.

### Model roles

In multi-model mode, each task type is handled by a specific role. Each role can have one model or a **pool of candidates** — the orchestrator reads model tier and description and picks the best fit for each task.

Use `/multi-model` in the interactive CLI to toggle models on/off per role, or edit `~/.config/kimchi/harness/settings.json` directly:

```json
{
  "modelRoles": {
    "orchestrator": "kimchi-dev/kimi-k2.6",
    "builder": ["kimchi-dev/minimax-m2.7", "anthropic/claude-sonnet-4-5"],
    "reviewer": "anthropic/claude-sonnet-4-5",
    "explorer": "kimchi-dev/nemotron-3-ultra-fp4"
  }
}
```

| Role | Default | Description |
|------|---------|-------------|

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `kimchi`

### `--help` output

```text
kimchi — code with powerful open-source LLMs

Usage: kimchi [subcommand] [options] [@files…] [messages…]

Subcommands:
  kimchi setup          Run the interactive setup wizard
  kimchi login          Log in via browser and update your API key
  kimchi setup-tools    Configure coding tools in one pass
  kimchi claude         Configure Claude Code to use Kimchi (and launch it)
  kimchi opencode       Configure OpenCode to use Kimchi (and launch it)
  kimchi cursor         Configure Cursor to use Kimchi
  kimchi openclaw       Configure OpenClaw to use Kimchi
  kimchi gsd2           Install / configure GSD2 with Kimchi
  kimchi update         Check for and install Kimchi/package updates
  kimchi config         Inspect or change kimchi config (e.g. telemetry)
  kimchi resources      Enable or disable Kimchi hooks, tools, extensions, and plugins
  kimchi mcp            MCP server utilities (probe, ...)
  kimchi version        Print the kimchi version
  kimchi                (no subcommand) Launch the coding harness

Harness flags (no subcommand):
  --provider <name>            Provider (default: kimchi-dev)
  --model <pattern>            Model id or pattern, optionally `provider/id` and/or `:<thinking>`
  --thinking <level>           Thinking level: off, minimal, low, medium, high, xhigh, max
  --mode <mode>                Output mode: text (default), json, rpc, acp
  --print, -p                  Non-interactive mode: process prompt and exit
  --continue, -c               Resume the most recent session
  --resume, -r [id]            Resume by id, or pick a previous session interactively when omitted
  --session <path>             Resume a specific session file (full path or partial UUID)
  --no-session                 Run ephemerally — don't write a session file
  --export <file>              Export a session to HTML and exit
  --list-models [search]       Print available models (optionally fuzzy-filtered)
  --allow-tool <rule>          Add session permission allow rules (comma-separated)
  --deny-tool <rule>           Add session permission deny rules (comma-separated)
  --plan                       Start in plan mode (read-only)
  --auto                       Start in auto mode (run freely, classifier guards)
  --yolo                       Start in yolo mode (run freely, no classifier - DANGER)
  --permissions-config <path>  Replace the merged permissions config with this file
  --verbose                    Force verbose startup (overrides quietStartup)
  --help, -h                   Show this help
  --version, -v                Show the kimchi version

Environment variables:
  KIMCHI_API_KEY            Kimchi API key (overrides config.json apiKey)
  KIMCHI_PERMISSIONS        Initial permissions mode: default | plan | auto | yolo
  KIMCHI_TELEMETRY_ENABLED  Override telemetry (1/true to enable, 0/false to disable). On by default.
  KIMCHI_TAGS               Comma-separated `key:value` tags applied to every LLM request
  KIMCHI_NO_UPDATE_CHECK    Disable the background self-update probe

Examples:
  kimchi setup                                # first-time interactive setup
  kimchi setup-tools                          # configure coding tools
  kimchi                                      # launch the interactive harness
  kimchi -p "explain src/cli.ts"              # one-shot prompt, no session
  kimchi --continue                           # resume the most recent session
```


### Common commands

```bash
Then configure your API key and launch:
Run `kimchi --help` to see all available subcommands and flags.
Kimchi operates in one of two modes:
| Mode | Status line indicator | Behavior |
|------|-----------------|----------|
| **Single-model** | model name | All work runs on the selected model directly |
| Role | Default | Description |
|------|---------|-------------|
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show kimchi:es`.
