## Package Information

- **Name:** Qwen Code
- **Tags:** ai, agent, coding
- **Project:** https://qwenlm.github.io/qwen-code-docs/
- **Source:** https://github.com/QwenLM/qwen-code
- **Dependencies:** git, ripgrep

## What is it?

An open-source AI coding agent that lives in your terminal.

## How to use it?

### Quick Start

```bash
qwen          # Launch interactive terminal UI
# Inside the session:
/auth         # Configure your provider and API key
```

See the [Authentication Guide](https://qwenlm.github.io/qwen-code-docs/en/users/configuration/auth/) and [Settings Reference](https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/) for detailed setup.

![Qwen Code](https://img.alicdn.com/imgextra/i2/O1CN01K0nwj41RM1Il8kB0t_!!6000000002096-2-tps-1544-1060.png)

## How to Use Qwen Code

| Mode            | Command         | Use Case                                                                                                                                                                                                                                        |
| --------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Interactive** | `qwen`          | Terminal UI with rich rendering, `@file` references, slash commands                                                                                                                                                                             |
| **Headless**    | `qwen -p "..."` | Scripts, CI/CD, batch processing — no UI                                                                                                                                                                                                        |
| **IDE**         | —               | [VS Code](https://qwenlm.github.io/qwen-code-docs/en/users/integration-vscode/), [Zed](https://qwenlm.github.io/qwen-code-docs/en/users/integration-zed/), [JetBrains](https://qwenlm.github.io/qwen-code-docs/en/users/integration-jetbrains/) |
| **Desktop**     | —               | [Qwen Code Desktop](https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest) — GUI for macOS, Windows, Linux                                                                                                                            |
| **Daemon**      | `qwen serve`    | Shared agent session over HTTP+SSE (ACP). Multiple clients, one agent. _(experimental)_ [Docs](https://qwenlm.github.io/qwen-code-docs/en/users/qwen-serve)                                                                                     |
| **SDK**         | —               | [TypeScript](./packages/sdk-typescript/README.md), [Python](./packages/sdk-python/README.md), [Java](./packages/sdk-java/qwencode/README.md)                                                                                                    |
| **IM Bot**      | `qwen channel`  | Connect to Telegram, DingTalk, WeChat, or Feishu                                                                                                                                                                                                |

<details>
<summary>SDK example (Python)</summary>

```python
import asyncio

from qwen_code_sdk import is_sdk_result_message, query


async def main() -> None:
    result = query(
        "Summarize the repository layout.",
        {
            "cwd": "/path/to/project",
            "path_to_qwen_executable": "qwen",
        },
    )

    async for message in result:
        if is_sdk_result_message(message):
            print(message["result"])


asyncio.run(main())
```

</details>

## Capabilities

If you know Claude Code, you already know Qwen Code — and then some. We've put significant effort into [bringing Qwen Code to feature parity with Claude Code](https://github.com/wenshao/codeagents/blob/main/docs/comparison/qwen-code-improvement-report.md), improving both breadth and reliability across the board.

| Feature                                                            | Qwen Code | Claude Code |
| ------------------------------------------------------------------ | :-------: | :---------: |
| SubAgents, Agent Teams, Dynamic Workflows                          |     ✓     |      ✓      |
| Auto-Memory, Auto-Skills, Hooks                                    |     ✓     |      ✓      |
| Built-in Skills (/review, /batch, /loop, /bugfix…)                 |     ✓     |      ✓      |
| MCP, Plan Mode, LSP Integration                                    |     ✓     |      ✓      |
| Auto Mode, Sandbox, Git Worktrees                                  |     ✓     |      ✓      |
| Computer Use (desktop automation)                                  |     ✓     |      ✓      |
| IDE Plugins (VS Code / JetBrains / Zed)                            |     ✓     |      ✓      |
| SDK                                                                |     ✓     |      ✓      |
| Headless Mode, Session Management                                  |     ✓     |      ✓      |

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `qwen`

### Common commands

```bash
qwen          # Launch interactive terminal UI
/auth         # Configure your provider and API key
</details>
| Feature                                                            | Qwen Code | Claude Code |
| ------------------------------------------------------------------ | :-------: | :---------: |
| SubAgents, Agent Teams, Dynamic Workflows                          |     ✓     |      ✓      |
| Auto-Memory, Auto-Skills, Hooks                                    |     ✓     |      ✓      |
| Built-in Skills (/review, /batch, /loop, /bugfix…)                 |     ✓     |      ✓      |
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show qwen-code:es`.
