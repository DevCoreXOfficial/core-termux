## Package Information

- **Name:** KiloCode CLI
- **Tags:** none
- **Project:** https://kilocode.ai
- **Dependencies:** nodejs

## What is it?

The open source coding agent for building with AI in VS Code, JetBrains, or the CLI

**Package:** kilocode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/Kilo-Org/kilocode  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

### Description

Kilo Code is an AI coding agent that meets you everywhere you work: VS Code, JetBrains, and the CLI. It's open source with open pricing. You pick from 500+ models, switch between them mid-task, and pay the model provider's rate with zero markup. No API keys required to start.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

### Install

```bash
core install ai --kilocode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest Kilo Code CLI binary from GitHub releases
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs Kilo Code CLI inside an Ubuntu proot-distro container

### Uninstall

```bash
core uninstall ai --kilocode
```

### Update

```bash
core update ai --kilocode
```

### Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-data/kilocode/`
- A small C bootstrapper (`kilocode_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and installs via the official kilo.ai installer
- Data directory: `~/.local/share/core-data/kilocode/`

## How to use it?

```bash
core install kilocode      # install
core update kilocode       # update
core uninstall kilocode    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show kilocode:es`.
