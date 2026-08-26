## Package Information

- **Name:** Gentle AI
- **Tags:** ai, agents, ecosystem
- **Source:** https://github.com/Gentleman-Programming/gentle-ai
- **Dependencies:** None required by Core

## What is it?

Ecosystem, Frameworks, Workflows for AI coding agents

## How to use it?

### Key Features You Should Know About

### OpenCode SDD Profiles

Assign different AI models to different SDD phases -- a powerful model for design, a fast one for implementation, a cheap one for exploration. OpenCode uses **`gentle-orchestrator`** as the base SDD conductor, and generated named profiles still appear as `sdd-orchestrator-{name}` entries.

```bash
# Via CLI
gentle-ai sync --profile cheap:openrouter/qwen/qwen3-30b-a3b:free
gentle-ai sync --profile-phase cheap:sdd-design:anthropic/claude-sonnet-4-20250514

# Or via TUI: gentle-ai → "OpenCode SDD Profiles" → Create
```

After creating a profile, open OpenCode and press **Tab** to switch between `gentle-orchestrator` (default) and your custom profiles.

| What you need         | Use this                                                        |
| --------------------- | --------------------------------------------------------------- |
| Default SDD conductor | `gentle-orchestrator`                                           |
| Legacy configs        | `sdd-orchestrator` is migrated to `gentle-orchestrator` on sync |
| Named model profiles  | `sdd-orchestrator-cheap`, `sdd-orchestrator-premium`, etc.      |

**Full guide**: [OpenCode SDD Profiles](docs/opencode-profiles.md)

### Engram (Persistent Memory)

Your AI agent automatically remembers decisions, bugs, and context across sessions. You don't need to do anything -- but when you do:

```bash
engram projects list          # See all projects with memory counts
engram projects consolidate   # Fix name drift ("my-app" vs "My-App")
engram search "auth bug"      # Find a past decision from the terminal
engram tui                    # Visual memory browser
```

**Full reference**: [Engram Commands](docs/engram.md)

---

## Documentation

| Your task | Start here |
| --- | --- |
| Understand the Gentle-AI mental model | [Intended Usage](docs/intended-usage.md) |
| Choose direct, delegated, or optional SDD routing | [Organic Implementation Routing](docs/trigger-rules.md) |
| Plan substantial work with SDD | [Intended Usage](docs/intended-usage.md) and [OpenSpec Config](docs/openspec-config.md) |
| Configure a supported agent | [Agents](docs/agents.md) for the feature matrix and per-agent notes |
| Use the Pi package harness | [Pi Agent](docs/pi.md) for packages, Pi-native commands, models, and troubleshooting |
| Configure OpenCode phase models | [OpenCode SDD Profiles](docs/opencode-profiles.md) |
| Review or deliver a change safely | [Review Integration Contract](docs/review-integration.md) for provider consumers; [Review Authority Threat Model](docs/review-authority-threat-model.md) for technical boundaries; [Chapter 21 — Verifiable Trust](https://the-amazing-gentleman-programming-book.vercel.app/en/book/Chapter21_Verifiable-Trust) for the mental model |
| Find or share persistent context | [Engram Commands](docs/engram.md) |
| Refresh or troubleshoot an installation | [Usage](docs/usage.md), [Backup & Rollback](docs/rollback.md), and [Platforms](docs/platforms.md) |
| Extend or contribute to Gentle AI | [Codebase Guide](docs/CODEBASE-GUIDE.md), [Components, Skills & Presets](docs/components.md), [Skill Registry](docs/skill-registry.md), and [Architecture & Development](docs/architecture.md) |
| Understand how agent behavior is tested | [Testing Agents Deterministically](docs/testing-agents-deterministically.md) for the real-agent E2E and its model fixture |

---

## Community Highlights

This project gets better when the community builds on top of it.

### Community Integrations

- [sub-agent-statusline](https://github.com/Joaquinvesapa/sub-agent-statusline) — optional OpenCode TUI plugin that shows sub-agent activity, status, elapsed time, and token/context usage when OpenCode exposes it.
- [sdd-engram-plugin](https://github.com/j0k3r-dev-rgl/sdd-engram-plugin) — optional OpenCode TUI plugin to manage SDD profiles and browse Engram memories directly from OpenCode, with runtime profile activation and no restart required.

When you select OpenCode in the installer, Gentle-AI asks whether to register each community plugin and offers a browser shortcut to review the repository first. Gentle-AI only ensures `~/.config/opencode/tui.json` exists and adds the plugin package names to its `plugin` array; OpenCode installs/loads those packages the next time it starts. Once OpenCode has materialized a plugin under `~/.config/opencode/node_modules/`, `gentle-ai update` can compare its local `package.json` version with the plugin's GitHub releases.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `gentle-ai`

### Common commands

```bash
gentle-ai sync --profile cheap:openrouter/qwen/qwen3-30b-a3b:free
gentle-ai sync --profile-phase cheap:sdd-design:anthropic/claude-sonnet-4-20250514
engram projects list          # See all projects with memory counts
engram projects consolidate   # Fix name drift ("my-app" vs "My-App")
engram search "auth bug"      # Find a past decision from the terminal
engram tui                    # Visual memory browser
gentle-ai sync --profile cheap:openrouter/qwen/qwen3-30b-a3b:free
gentle-ai sync --profile-phase cheap:sdd-design:anthropic/claude-sonnet-4-20250514
```

