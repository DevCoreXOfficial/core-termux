## Package Information

- **Name:** Freebuff
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

A 100% free coding agent, right from your terminal

**Package:** freebuff  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://freebuff.com
**Releases:** https://github.com/CodebuffAI/codebuff
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

### Description

Freebuff is the free coding agent: a free CLI coding agent and Freebuff Web, the free way to build full-stack apps. No subscription, no setup, no lock-in. Core offers three installation methods: native with glibc support for best performance, native + proot to bypass "bad system call" errors, or via proot-distro Ubuntu container for maximum compatibility.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates, tar

### Install

```bash
core install ai --freebuff
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest Freebuff binary from GitHub releases
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs Freebuff inside an Ubuntu proot-distro container

### Uninstall

```bash
core uninstall ai --freebuff
```

### Update

```bash
core update ai --freebuff
```

### Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-data/freebuff/`
- A small C bootstrapper (`freebuff_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and downloads the binary directly inside the container
- Version is fetched automatically from GitHub releases (`CodebuffAI/codebuff-community`)
- Data directory: `~/.local/share/core-data/freebuff/`

## How to use it?

```bash
core install freebuff      # install
core update freebuff       # update
core uninstall freebuff    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show freebuff:es`.
