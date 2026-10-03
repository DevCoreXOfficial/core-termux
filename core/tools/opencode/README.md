# OpenCode

Open-source agent that helps you write code in your terminal

**Package:** opencode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/anomalyco/opencode  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

## Description

OpenCode is an AI-powered coding agent developed by anomalyco that operates directly in your terminal. It provides intelligent code completion, refactoring suggestions, and natural language code generation. Core-Termux offers three installation methods: native with glibc support for best performance, native + proot to bypass "bad system call" errors, or via proot-distro Ubuntu container for maximum compatibility.

## Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

## Install

```bash
core install ai --opencode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest OpenCode binary from GitHub releases
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs OpenCode inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --opencode
```

## Update

```bash
core update ai --opencode
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-termux-data/opencode-v2/`
- Updates track the **v2** release channel (npm `@opencode/cli-*`); updates never downgrade v2 to v1
- The launcher (`bin/opencode.v2`) runs the binary through the glibc dynamic linker and keeps the v2 background service alive
- A C bootstrapper (`opencode_helper.c`) is retained as a fallback and also targets v2
- **Proot mode** uses `proot-distro ubuntu` and installs via the official opencode.ai installer
- Data directory: `~/.local/share/core-termux-data/opencode-v2/`
- The legacy v1 directory (`~/.local/share/core-termux-data/opencode/`) is removed on uninstall if present

