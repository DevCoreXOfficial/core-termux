## Package Information

- **Name:** MiMoCode
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

Xiaomi's AI coding agent — fast, local, and open-source

**Package:** mimocode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/XiaomiMiMo/MiMo-Code  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** MIT

### Description

MiMo Code is Xiaomi's AI coding agent — fast, local, and open-source. It provides intelligent code completion, refactoring suggestions, and natural language code generation directly in your terminal.

### Dependencies

- glibc-repo, glibc, clang, curl, tar

### Install

```bash
core install ai --mimocode
```

### Uninstall

```bash
core uninstall ai --mimocode
```

### Update

```bash
core update ai --mimocode
```

### Notes

- Native installation requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The real binary is stored in `~/.local/share/core-data/mimocode/`
- A small C bootstrapper (`mimocode_helper.c`) handles ELF loading via the glibc dynamic linker
- Data directory: `~/.local/share/core-data/mimocode/`

## How to use it?

```bash
core install mimocode      # install
core update mimocode       # update
core uninstall mimocode    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show mimocode:es`.
