## Package Information

- **Name:** Engram
- **Tags:** ai, memory, agents
- **Dependencies:** None required by Core

## What is it?

Persistent memory system for AI coding agents

**Package:** engram  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/Gentleman-Programming/engram  
**Type:** AI memory system (Go binary)  
**License:** MIT

### Description

Engram is a persistent memory system designed for AI coding agents. It provides long-term memory storage and retrieval, allowing AI assistants to maintain context across sessions. Built with Go for performance and reliability.

### Dependencies

- golang, git, sqlite

### Install

```bash
core install ai --engram
```

### Uninstall

```bash
core uninstall ai --engram
```

### Update

```bash
core update ai --engram
```

### Notes

- Built from source using Go
- Source cloned to `$CORE_DATA/engram/`
- Binary installed to `$PREFIX/bin/engram`
- Requires Go toolchain (installed automatically)

## How to use it?

```bash
core install engram      # install
core update engram       # update
core uninstall engram    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show engram:es`.
