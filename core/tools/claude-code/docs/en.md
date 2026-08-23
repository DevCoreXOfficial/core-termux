## Package Information

- **Name:** Claude Code
- **Tags:** ai, agent, coding
- **Project:** https://claude.com/claude-code
- **Dependencies:** git, ripgrep, nodejs

## What is it?

Anthropic's CLI tool with Claude AI

**Package:** claude-code  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/anthropics/claude-code  
**Type:** AI coding assistant (Binary + glibc bootstrapper)  
**License:** MIT

### Description

Claude Code is Anthropic's AI-powered coding assistant that runs directly in your terminal. It leverages Claude's advanced language models to help with code generation, debugging, refactoring, and answering technical questions. Core provides three installation methods: native with glibc support for best performance, native + proot to bypass "bad system call" errors, or via proot-distro Ubuntu container.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

### Install

```bash
core install ai --claude-code
```

### Uninstall

```bash
core uninstall ai --claude-code
```

### Update

```bash
core update ai --claude-code
```

### Notes

- Native installation (recommended): runs directly with glibc support via a C bootstrapper
- Proot-distro (alternative): runs inside an Ubuntu container for compatibility
- The installer will prompt you to select which method to use
- Data directory: `~/.local/share/core-data/claude/`

## How to use it?

```bash
core install claude-code      # install
core update claude-code       # update
core uninstall claude-code    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show claude-code:es`.
