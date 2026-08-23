## Package Information

- **Name:** Gentle AI
- **Tags:** ai, agents, ecosystem
- **Dependencies:** None required by Core

## What is it?

Ecosystem, Frameworks, Workflows for AI coding agents

**Package:** gentle-ai  
**Author:** Gentleman-Programming  
**Repository:** https://github.com/Gentleman-Programming/gentle-ai  
**Type:** AI ecosystem configurator (Go source compile)  
**License:** MIT

### Description

Gentle-AI is an ecosystem configurator for AI coding agents. It provides persistent memory (Engram), Spec-Driven Development workflows, curated coding skills, MCP servers, an AI provider switcher, a teaching-oriented persona with security-first permissions, and per-phase model assignment for 15+ supported agents.

### Dependencies

- golang (1.25+), git, curl

### Install

```bash
core install ai --gentle-ai
```

### Uninstall

```bash
core uninstall ai --gentle-ai
```

### Update

```bash
core update ai --gentle-ai
```

### Notes

- Source cloned from GitHub and compiled natively with Go
- Termux-specific patches applied automatically for Android compatibility
- Data directory: `~/.local/share/core-data/gentle-ai/`
- Command: `gentle-ai`

## How to use it?

```bash
core install gentle-ai      # install
core update gentle-ai       # update
core uninstall gentle-ai    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show gentle-ai:es`.
