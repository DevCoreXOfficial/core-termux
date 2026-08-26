## Package Information

- **Name:** KeelCode
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

The hosted coding agent for your terminal — inspect a project, edit files, run commands, search the web, use MCP servers

Full documentation: project page

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `keelcode`

### `--help` output

```text
keelcode v0.2.0 — the hosted Keelcode coding agent

USAGE
  keelcode                       start the interactive TUI
  keelcode <prompt>              start with an opening prompt
  keelcode -p "<prompt>"         run one turn headlessly, print it, exit
  keelcode -c                    resume the newest session in this directory

  New here? Run keelcode login, then keelcode doctor to check the install.

ACCOUNT
  keelcode login [--no-browser]  sign in with a device code
  keelcode logout                revoke and remove the hosted session
  keelcode status [--json]       report local sign-in state
  keelcode whoami                show the active hosted account
  keelcode usage                 show remaining daily API credits

WORK
  keelcode sessions              list saved sessions
  keelcode models [--json]       list models available to your account
  keelcode mission               list, show, why, diff, review, merge
  keelcode worktree              create, inspect, or clean Git isolation
  keelcode proof                 list or show executable proof receipts

EXTEND
  keelcode mcp                   add, list, get, enable, disable, remove
  keelcode skills                list, enable, disable, marketplace
  keelcode import [list|all]     find extensions from other coding agents
  keelcode commands [--json]     list slash commands for desktop palettes

MAINTAIN
  keelcode doctor                installation, MCP, and skills health
  keelcode update [--check]      update keelcode to the latest release
  keelcode alias <action>        add, list, remove, or set up aliases
  keelcode setup                 guided Nerd Font + terminal setup
  keelcode install-font          install a Nerd Font (per-user) + how-to
  keelcode font-test             print the glyph self-test and exit
  keelcode telemetry <action>    status, enable, or disable analytics
  keelcode bench [--json]        measure local launcher startup latency

OPTIONS
  -m, --model <alias>      Keelcode model alias (env: KEELCODE_MODEL)
      --effort <level>     off | low | medium | high | xhigh | max
      --permission-mode <m>  default | plan | acceptEdits | bypassPermissions
      --yolo               shorthand for --permission-mode bypassPermissions
      --cwd <dir>          working directory (default: current)
      --icons <set>        auto | unicode | nerd | ascii
      --no-alt-screen      keep output in normal scrollback (default: alt screen)
  -h, --help               show this help
  -v, --version            show version

  RESUMING
  -c, --continue           resume the most recent session in this directory
      --resume [id|#]      resume a saved session, or list sessions if omitted

```

