# Antigravity CLI

AI-powered development workflow assistant

**Package:** antigravity-cli  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://antigravity-cli.com  
**Type:** AI workflow assistant (Binary + glibc bootstrapper)  
**License:** MIT

## Description

Antigravity CLI (agy) is an AI-powered development workflow assistant that helps automate common development tasks. It uses VA39 memory patches for Android ARM64 compatibility and runs via a glibc bootstrapper for native performance.

## Dependencies

- glibc-repo, glibc, clang, python, jq, curl, tar

## Install

```bash
core install ai --antigravity-cli
```

## Uninstall

```bash
core uninstall ai --antigravity-cli
```

## Update

```bash
core update ai --antigravity-cli
```

## Notes

- Binary downloaded from official Antigravity manifest
- VA39 memory patches applied automatically for Android ARM64 compatibility
- C bootstrapper compiles via clang for ELF loading
- Data directory: `~/.local/share/core-termux-data/antigravity-cli/`
- Command: `agy`

