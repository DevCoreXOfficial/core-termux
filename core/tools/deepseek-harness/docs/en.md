## Package Information

- **Name:** DeepSeek Harness
- **Tags:** ai, agent, coding, deepseek
- **Project:** https://deepseek.com/harness
- **Source:** https://github.com/deepseek-ai/deepseek-harness
- **Dependencies:** nodejs, clang, make, cmake

## What is it?

Open-source agent harness by DeepSeek AI with an everything-is-a-plugin architecture. Built on Cordis, it provides a full coding agent with file editing, shell access, web search, skills, planning, goals, subagents, and workflows.

## How to use it?

### Quickstart

```shell
# Start the Web UI (opens browser at http://127.0.0.1:3080)
dsh web

# Run a headless task
dsh --profile headless "summarize this repository"

# Start SDK server
dsh --profile sdk
```

### First launch

1. Run `dsh web` to start the Web UI
2. Open Settings → Models and enter a DeepSeek API key
3. Choose a workspace directory
4. Start a session and type your first instruction

### Install via Core

```bash
core install deepseek-harness    # install
core update deepseek-harness     # update
core uninstall deepseek-harness  # uninstall
```

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `dsh`

### Entry modes

| Command | Purpose |
|---------|---------|
| `dsh web` | Start the Web UI (alias for `--profile web`) |
| `dsh --profile headless "job"` | Run one task, print result, exit |
| `dsh --profile sdk` | Serve SDK clients over JSON-RPC |
| `dsh --profile sdk-minimal` | Minimal SDK agent |
| `dsh --profile acp` | Serve automation clients over ACP |
| `dsh plugin --profile <name> <pnpm args>` | Manage profile plugins |

### Common flags

```bash
dsh --profile web --port 8080     # custom port
dsh --profile web --no-open       # don't open browser
dsh --dump-default-config         # inspect default config
dsh --dump-config                 # inspect composed config
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Requires Node.js LTS (installed automatically if missing).
- Developer preview: compatibility-breaking changes may occur.
- Spanish (when available): `core show deepseek-harness:es`.
