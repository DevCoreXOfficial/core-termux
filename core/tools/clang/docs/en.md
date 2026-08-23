## Package Information

- **Name:** Clang
- **Tags:** language, compiler, c, c++
- **Project:** https://clang.llvm.org
- **Dependencies:** None required by Core

## What is it?

LLVM C/C++ compiler for systems programming

**Package:** clang  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://clang.llvm.org  
**Type:** Language compiler (pkg)  
**License:** Apache 2.0 with LLVM Exceptions

### Description

Clang is a C, C++, and Objective-C compiler which aims to deliver amazingly fast compiles, extremely useful error and warning messages, and to provide a platform for building great source level tools. It is part of the LLVM compiler infrastructure project.

### Dependencies

- Installed via pkg

### Install

```bash
core install lang --clang
```

### Uninstall

```bash
core uninstall lang --clang
```

### Update

```bash
core update lang --clang
```

### Notes

- Commands: `clang`, `clang++`, `clang-format`
- Includes LLVM tools
- Required for compiling many native extensions

## How to use it?

```bash
core install clang      # install
core update clang       # update
core uninstall clang    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show clang:es`.
