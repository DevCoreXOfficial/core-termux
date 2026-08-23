## Package Information

- **Name:** OpenCode
- **Tags:** ai, agent, coding
- **Project:** https://opencode.ai
- **Dependencies:** git, ripgrep, jq, nodejs

## What is it?

Open-source agent that helps you write code in your terminal

**Package:** opencode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/anomalyco/opencode  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

### Description

OpenCode is an AI-powered coding agent developed by anomalyco that operates directly in your terminal. It provides intelligent code completion, refactoring suggestions, and natural language code generation. Core offers three installation methods: native with glibc support for best performance, native + proot to bypass "bad system call" errors, or via proot-distro Ubuntu container for maximum compatibility.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

### Install

```bash
core install opencode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest OpenCode binary from GitHub releases
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs OpenCode inside an Ubuntu proot-distro container

### Uninstall

```bash
core uninstall opencode
```

### Update

```bash
core update opencode
```

### Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-data/opencode/`
- A small C bootstrapper (`opencode_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and installs via the official opencode.ai installer
- Data directory: `~/.local/share/core-data/opencode/`

## How to use it?

```bash
core install opencode      # install
core update opencode       # update
core uninstall opencode    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show opencode:es`.
