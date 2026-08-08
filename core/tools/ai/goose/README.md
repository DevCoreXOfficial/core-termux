# Goose

An open source AI agent that supercharges your workflow with one tool: plan, build, test, and iterate on tasks in a local environment

**Package:** goose  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/block/goose  
**Fork:** https://github.com/aaif-goose/goose  
**Type:** AI agent (Binary + glibc bootstrapper)  
**License:** Apache-2.0

## Description

Goose is an open-source AI agent (originally built by Block) that automates complex engineering tasks — code changes, debugging, research, data analysis, and workflow automation — directly from the terminal, desktop, or API. It supports a wide range of LLM providers (Anthropic, OpenAI, Google, Ollama local models, and more), an extension system, and reusable "recipes". This Termux adaptation installs the fork release `aaif-goose/goose` via the 3-method installer.

## Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar, bzip2
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates, tar, bzip2

## Install

```bash
core install ai --goose
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest Goose binary from GitHub releases
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs Goose inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --goose
```

## Update

```bash
core update ai --goose
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-termux-data/goose/`
- A small C bootstrapper (`goose_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu`
- Configuration lives in `~/.config/goose/` (config.yaml, sessions, permissions), logs in `~/.local/share/goose/logs`, cache in `~/.cache/goose`, legacy data in `~/.goose`
- Run `goose configure` after install to set up providers
