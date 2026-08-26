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

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show openclaw:es`.
