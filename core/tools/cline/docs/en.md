## Package Information

- **Name:** Cline CLI
- **Tags:** ai, agent, coding
- **Project:** https://cline.bot
- **Source:** https://github.com/cline/cline
- **Dependencies:** nodejs

## What is it?

Autonomous coding agent as an SDK, IDE extension, or CLI assistant.

## How to use it?

### CLI

Run Cline in your terminal.
Interactive chat or fully headless
for CI/CD and scripting.

```
npm i -g cline
```

<a href="./apps/cli/README.md">Learn more</a>
<br><br>

</td>
<td align="center" width="50%">

### Kanban

Run many agents in parallel from a
web-based task board. Each card gets its own
worktree, auto-commit, and dependency chains.

```
npm i -g kanban
```

<a href="https://github.com/cline/kanban">Learn more</a>
<br><br>

</td>
</tr>
<tr>
<td align="center" width="50%">

### VS Code Extension

AI coding assistant in your editor.
Create files, run commands, browse the web,
and use tools with human-in-the-loop approval.

<a href="https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev">Install from VS Marketplace</a>
<br><br>

</td>
<td align="center" width="50%">

### JetBrains Plugin

The same Cline experience in IntelliJ IDEA,
PyCharm, WebStorm, GoLand, and the rest of
the JetBrains family.

<a href="https://plugins.jetbrains.com/plugin/28247-cline">Install from JetBrains Marketplace</a>
<br><br>

</td>
</tr>
</table>
</div>

<div align="center">
<table>
<tr>
<td align="center">

### SDK

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `cline`

### `--help` output

```text
Usage: cline [options] [command] [prompt]

Cline CLI - AI coding assistant in your terminal

Arguments:
  prompt                        Your prompt. Default to start in act mode with
                                auto-approve enabled.

Options:
  -V, --version                 Output the version number
  -p, --plan                    Run in plan mode
  --json                        Output messages as JSON instead of styled text
  --auto-approve <boolean>      Set tool auto-approval for all tools (default:
                                true)
  -c, --cwd <path>              Working directory
  --thinking <level>            Set reasoning effort:
                                none|low|medium|high|xhigh. Bare --thinking uses
                                medium; omitted leaves provider default.
  --compaction <mode>           Context compaction mode: agentic|basic|off
                                (default: agentic)
  -i, --tui                     Open the terminal user interface (TUI) for
                                interactive sessions
  --id <session-id>             Resume an existing session by ID
  -P, --provider <id>           Provider id (default: cline)
  -k, --key <api-key>           API key override for this run
  -m, --model <model-id>        Model to use for the session with the selected
                                provider
  -s, --system <system-prompt>  Override the default system prompt
  -z, --zen                     Start a session that runs in the background hub
  --retries [value]             Number of maximum consecutive mistakes (retries)
                                before exiting (default: 6)
  -t, --timeout <seconds>       Optional timeout in seconds (default: 0 for no
                                timeout)
  --acp                         Run in Agent Client Protocol (ACP) mode for
                                editor integration
  --config <path>               Configuration directory (default: ~/.cline)
  --data-dir <path>             Use isolated local state at this directory path
                                (default: ~/.cline/data)
  --hooks-dir <path>            Directory path to additional hooks for runtime
                                hook injection (default: ~/.cline/hooks)
  --worktree                    Auto-create a detached git worktree under
                                ~/.cline/worktrees/ and run the task there
  --update                      Check for updates and install if available
  --kanban                      Run the kanban app
  -v, --verbose                 Show verbose output
  -h, --help                    display help for command

Commands:
  auth [options] [provider]     Authenticate a provider and configure what model
                                is used
  config [options]              Show current configuration
  plugin                        Manage Cline Plugins
  skill [args...]               Manage Cline Skills via the open skills CLI (npx
                                skills)
  connect [options] [channel]   Connect to an external channel
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show cline:es`.
