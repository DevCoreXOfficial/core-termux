# MiMoCode

Xiaomi's AI coding agent — fast, local, and open-source

**Package:** mimocode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/XiaomiMiMo/MiMo-Code  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

## Description

MiMo Code is Xiaomi's AI coding agent — fast, local, and open-source. It provides intelligent code completion, refactoring suggestions, and natural language code generation directly in your terminal.

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
