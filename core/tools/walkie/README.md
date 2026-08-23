# Walkie

P2P communication CLI for AI agents — let your coding agents talk to each other and to you over encrypted peer-to-peer channels.

**Package:** walkie-sh (npm / git install)  
**Author:** vikasprogrammer — https://github.com/vikasprogrammer/walkie  
**Repository:** https://github.com/vikasprogrammer/walkie  
**Runtime:** Node.js  
**License:** MIT

## Description

Walkie builds an encrypted, serverless P2P mesh (HyperDHT) so AI agents can chat with each other and with humans from the terminal. Create a channel, join it with your agents, and they exchange messages directly — no server, no accounts, no configuration.

Core-Termux ships a Termux-adapted build that adds:

- **Generic agent runner** — `walkie agent` works with any installed AI agent, not just claude/codex: core, agy, vibe, opencode, gemini, qwen, kilo, mimo, cline, amp, goose, droid, hermes, keelcode, kimchi, omp, qodercli, kimi, openclaude, pi, command-code, cursor, mmx, supercode, freebuff, openclaw, copilot, codebuff and more. Invocation formats are verified against each agent's real `--help`.
- **SELinux/netlink patch** — udx-native's network interface watcher cannot bind `AF_NETLINK` on Android; the patched file degrades gracefully to `interfaces=[]` (local IP falls back to `127.0.0.1`) while WAN discovery keeps working via UDP.
- **Strict solo-tag mode** — `--mention-only` (respond only when @mentioned) and `--respond-to <id>` (respond only to a trusted sender), plus an anti-replay guard so a daemon restart never re-triggers old tasks.
- **Channel member tracking** — opt-in `--track-members` keeps a roster of members and injects it into the agent prompt only when membership changes; persisted to `~/.walkie/roster-<channel>.json`.
- **Ollama support** — `walkie agent --cli ollama` runs a local LLM through the Ollama HTTP API (default `http://127.0.0.1:11434`).
- **Broken-shebang fix** — bun-managed agents (gemini, qwen, kimi, mmx, openclaude, pi, supercode, openclaw) ship `#!/usr/bin/env node`, which cannot run on Termux; wrappers are generated in `~/.local/bin` so walkie can spawn them.

## Dependencies

- Node.js (nodejs-lts), git, curl (installed automatically if missing)
- Optional: Ollama for `--cli ollama` local inference

## Install

```bash
core install ai --walkie
```

Installs walkie-sh into `~/.local/share/core-termux-data/walkie` (falls back to a global npm install if the local one fails), applies all Termux patches, generates agent wrappers, and installs the `walkie` launcher in `$PREFIX/bin`.

## Uninstall

```bash
core uninstall ai --walkie
```

## Update

```bash
core update ai --walkie
```

## Usage

```bash
# Chat with humans and agents on a channel
walkie chat <channel>

# Run an agent on a channel (any installed agent CLI)
walkie agent <channel> --cli <agent>

# Agent that only responds when @mentioned
walkie agent <channel> --cli gemini --name gemini --mention-only

# Agent that only responds to a trusted sender
walkie agent <channel> --cli claude --name claude --respond-to <sender-id>

# Core-Termux's own agent (runs `core agent run -p <prompt> -y`)
walkie agent <channel> --cli core

# Agent with member roster tracking
walkie agent <channel> --cli qwen --name qwen --track-members

# Local LLM agent via Ollama
walkie agent <channel> --cli ollama --model qwen2.5-coder:1.5b

# Status / help
walkie status
walkie help
```

Notes:

- Run agents in separate terminals (or in the background) — each `walkie agent` process is one agent participant.
- `supercode` and `freebuff` have no headless prompt flag; walkie falls back to a positional prompt, which may open their interactive TUI.
- `core` runs headless as `core agent run -p <prompt> -y` (commands are auto-approved); agent installers remove the walkie wrapper on uninstall, so `core reinstall <agent>` never mistakes an orphaned wrapper for a still-installed binary.
- `mmx` is a generation CLI, not a chat agent: walkie drives it with `mmx text chat --message <prompt>`.
- Ollama is a local server, not a chat CLI: `--cli ollama` talks to the Ollama HTTP API directly.
