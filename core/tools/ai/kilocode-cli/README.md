# Kilo Code CLI

The open source coding agent for building with AI in VS Code, JetBrains, or the CLI

**Package:** kilocode-cli  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/Kilo-Org/kilocode  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

## Description

Kilo Code is an AI coding agent that meets you everywhere you work: VS Code, JetBrains, and the CLI. It's open source with open pricing. You pick from 500+ models, switch between them mid-task, and pay the model provider's rate with zero markup. No API keys required to start.

## Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Proot mode:** proot-distro, curl, ca-certificates

## Install

```bash
core install ai --kilocode-cli
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest Kilo Code CLI binary from GitHub releases
2. **Proot-distro (alternative)** — Runs Kilo Code CLI inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --kilocode-cli
```

## Update

```bash
core update ai --kilocode-cli
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-termux-data/kilocode/`
- A small C bootstrapper (`kilocode_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and installs via the official kilo.ai installer
- Data directory: `~/.local/share/core-termux-data/kilocode/`
