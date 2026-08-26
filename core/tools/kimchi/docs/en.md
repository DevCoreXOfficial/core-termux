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

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show kimchi:es`.
