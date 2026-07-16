# Qoder

A terminal-native AI coding partner—and an agent engine you can build on.

**Package:** qodercli
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://qoder.com  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** Proprietary

## Description

Work with Qoder around your codebase from the terminal.Turn ideas into working software - from building and debugging to shipping. Core-Termux offers two installation methods: native with glibc support for best performance, or via proot-distro Ubuntu container for maximum compatibility.

## Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Proot mode:** proot-distro, curl, ca-certificates

## Install

```bash
core install ai --qoder
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest Qoder binary
2. **Proot-distro (alternative)** — Runs Qoder inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --qoder
```

## Update

```bash
core update ai --qoder
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-termux-data/qoder/` and accessible as `qodercli`
- A small C bootstrapper (`qoder_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and installs via the official qoder.com installer
- Data directory: `~/.local/share/core-termux-data/qoder/`
