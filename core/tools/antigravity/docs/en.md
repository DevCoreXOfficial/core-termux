## Package Information

- **Name:** Antigravity CLI
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

Lightweight, terminal-first surface for Antigravity agents

**Package:** antigravity  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://antigravity.google  
**Type:** AI workflow assistant (Binary + glibc bootstrapper)  
**License:** MIT

### Description

Antigravity CLI is the lightweight, fast, terminal-first surface to work with Antigravity agents. It uses VA39 memory patches for Android ARM64 compatibility and runs via a glibc bootstrapper for native performance.

### Dependencies

- glibc-repo, glibc, clang, python, jq, curl, tar

### Install

```bash
core install ai --antigravity
```

### Uninstall

```bash
core uninstall ai --antigravity
```

### Update

```bash
core update ai --antigravity
```

### Notes

- Binary downloaded from official Antigravity manifest
- VA39 memory patches applied automatically for Android ARM64 compatibility
- C bootstrapper compiles via clang for ELF loading
- Data directory: `~/.local/share/core-data/antigravity/`
- Command: `agy`

## How to use it?

```bash
core install antigravity      # install
core update antigravity       # update
core uninstall antigravity    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show antigravity:es`.
