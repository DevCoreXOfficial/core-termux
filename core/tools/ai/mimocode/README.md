# MiMoCode

AI coding agent that runs natively in Termux with glibc support

**Package:** mimocode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/XiaomiMiMo/MiMo-Code  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

## Description

MiMo Code is an AI-powered coding agent developed by XiaomiMiMo that operates directly in your terminal. It provides intelligent code completion, refactoring suggestions, and natural language code generation. Core-Termux installs it natively with glibc support for best performance.

## Dependencies

- glibc-repo, glibc, clang, curl, tar

## Install

```bash
core install ai --mimocode
```

## Uninstall

```bash
core uninstall ai --mimocode
```

## Update

```bash
core update ai --mimocode
```

## Notes

- Native installation requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The real binary is stored in `~/.local/share/core-termux-data/mimocode/`
- A small C bootstrapper (`mimocode_helper.c`) handles ELF loading via the glibc dynamic linker
- Data directory: `~/.local/share/core-termux-data/mimocode/`
