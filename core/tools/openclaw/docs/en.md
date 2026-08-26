## Package Information

- **Name:** OpenClaw
- **Tags:** ai, assistant
- **Source:** https://github.com/openclaw/openclaw
- **Dependencies:** None required by Core

## What is it?

Your own personal AI assistant. Any OS. Any Platform. The lobster way. 🦞 

## How to use it?

### Quick start

On a fresh install, the installer scripts start onboarding automatically.
Complete the wizard they open. If you installed the package directly with npm,
pnpm, or Bun, run:

```bash
openclaw onboard --install-daemon
```

After onboarding:

```bash
openclaw gateway status
openclaw dashboard
```

Onboarding verifies model access, creates the workspace, and configures the Gateway. The last command opens the Control UI; send a message there to confirm the assistant is working. See the [getting started guide](https://docs.openclaw.ai/start/getting-started) for channel setup and troubleshooting.

## How it fits together

- The [Gateway](https://docs.openclaw.ai/gateway) is the local control plane for sessions, tools, events, and channel connections.
- The [Control UI](https://docs.openclaw.ai/web/control-ui), CLI, and [TUI](https://docs.openclaw.ai/web/tui) connect to the Gateway.
- [Channels](https://docs.openclaw.ai/channels) bring the assistant to WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, and other messaging services.
- [Companion apps and nodes](https://docs.openclaw.ai/platforms) add voice, Canvas, camera, screen, and device-local actions on supported platforms.

OpenClaw works with hosted and local [model providers](https://docs.openclaw.ai/concepts/model-providers). Its [tools](https://docs.openclaw.ai/tools), [skills](https://docs.openclaw.ai/tools/skills), and [plugins](https://docs.openclaw.ai/plugins) extend what an assistant can do.

## Security

Treat inbound messages as untrusted input. DM-capable channels pair unknown senders by default; approve a pairing request with `openclaw pairing approve <channel> <code>`.

Tools run on the host for the main session unless you configure sandboxing. Read the [security guide](https://docs.openclaw.ai/gateway/security), [exposure runbook](https://docs.openclaw.ai/gateway/security/exposure-runbook), and [sandboxing guide](https://docs.openclaw.ai/gateway/sandboxing) before connecting other users or exposing the Gateway remotely.

## Documentation

| Goal                             | Start here                                                                                                                                                                                                                                                           |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Configure models and auth        | [Models](https://docs.openclaw.ai/concepts/models) · [Model providers](https://docs.openclaw.ai/concepts/model-providers)                                                                                                                                            |
| Connect a messaging service      | [Channels](https://docs.openclaw.ai/channels)                                                                                                                                                                                                                        |
| Add tools, skills, and plugins   | [Tools](https://docs.openclaw.ai/tools) · [Skills](https://docs.openclaw.ai/tools/skills) · [Plugins](https://docs.openclaw.ai/plugins) · [ClawHub](https://clawhub.ai)                                                                                              |
| Run apps and device nodes        | [Platforms](https://docs.openclaw.ai/platforms) · [Nodes](https://docs.openclaw.ai/nodes)                                                                                                                                                                            |
| Use the CLI and chat commands    | [CLI reference](https://docs.openclaw.ai/cli) · [Slash commands](https://docs.openclaw.ai/tools/slash-commands)                                                                                                                                                      |
| Configure or operate the Gateway | [Configuration](https://docs.openclaw.ai/gateway/configuration) · [Architecture](https://docs.openclaw.ai/concepts/architecture) · [Updating](https://docs.openclaw.ai/install/updating) · [Release channels](https://docs.openclaw.ai/install/development-channels) |

## Development

The repository is a pnpm workspace. Plain `npm install` at the repository root is not supported.

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build
pnpm ui:build
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow and the [source setup guide](https://docs.openclaw.ai/start/setup) for the development loop.

## Community

OpenClaw is developed in the open by the [OpenClaw Foundation](https://openclaw.org), a non-profit. See [CONTRIBUTING.md](CONTRIBUTING.md) for maintainers and contribution guidelines; AI-assisted PRs are welcome.

Use the [issue chooser](https://github.com/openclaw/openclaw/issues/new/choose) for bugs and feature requests, ask setup questions in [Discord](https://discord.gg/clawd), and report vulnerabilities through [SECURITY.md](SECURITY.md). New capabilities usually belong in plugins built on the [plugin SDK](https://docs.openclaw.ai/plugins/building-plugins) and shared through [ClawHub](https://clawhub.ai).

OpenClaw was built for **Molty**, a space lobster AI assistant, by Peter Steinberger and the community. Explore the [project lore](https://docs.openclaw.ai/start/lore), [soul.md](https://soul.md), [Peter's site](https://steipete.me), [Star History](https://www.star-history.com/#openclaw/openclaw&type=date&legend=top-left), and [@openclaw](https://x.com/openclaw).

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `openclaw`

### `--help` output

```text
OpenClaw 2026.7.1-2 (0790d9f) — All your chats, one OpenClaw.

Usage: openclaw [options] [command]

Options:
  --container <name>   Run the CLI inside a running Podman/Docker container
                       named <name> (default: env OPENCLAW_CONTAINER)
  --dev                Dev profile: isolate state under ~/.openclaw-dev, default
                       gateway port 19001, and shift derived ports
                       (browser/canvas)
  -h, --help           Display help for command
  --log-level <level>  Global log level override for file + console
                       (silent|fatal|error|warn|info|debug|trace)
  --no-color           Disable ANSI colors
  --profile <name>     Use a named profile (isolates
                       OPENCLAW_STATE_DIR/OPENCLAW_CONFIG_PATH under
                       ~/.openclaw-<name>)
  -V, --version        output the version number

Commands:
  Hint: commands suffixed with * have subcommands. Run <command> --help for details.
  acp *                Run an ACP bridge backed by the Gateway
  agent                Run an agent turn via the Gateway (use --local for
                       embedded)
  agents *             Manage isolated agents (workspaces + auth + routing)
  approvals *          Manage exec approvals (gateway or node host)
  attach               Attach Claude Code to a gateway session with scoped MCP
                       tools
  audit                Inspect metadata-only agent run and tool action records
  backup *             Create and verify local backup archives for OpenClaw
                       state
  capability *         Run provider capability commands (fallback alias: infer)
  channels *           Manage connected chat channels and accounts
  chat                 Open a local terminal UI (alias for tui --local)
  clawbot *            Legacy clawbot command aliases
  commitments *        List and manage inferred follow-up commitments
  completion           Generate shell completion script
  config *             Non-interactive config helpers
                       (get/set/patch/unset/file/schema/validate). Run without
                       subcommand for guided setup.
  configure            Interactive configuration for credentials, channels,
                       gateway, and agent defaults
  crestodian           Open the ring-zero setup and repair helper
  cron *               Manage cron jobs (via Gateway)
  daemon *             Manage the Gateway service (launchd/systemd/schtasks)
  dashboard            Open the Control UI with your current token
  devices *            Device pairing and auth tokens
  directory *          Lookup contact and group IDs (self, peers, groups) for
                       supported chat channels
  dns *                DNS helpers for wide-area discovery (Tailscale + CoreDNS)
  docs                 Search the live OpenClaw docs
  doctor               Health checks + quick fixes for the gateway and channels
  exec-approvals *     Manage exec approvals (alias for approvals)
  exec-policy *        Show or synchronize requested exec policy with host
                       approvals
```


### Common commands

```bash
openclaw onboard --install-daemon
openclaw gateway status
openclaw dashboard
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build
pnpm ui:build
```

