# CodeGraph

Analyzes your codebase structure and dependencies to improve navigation

**Package:** codegraph  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/colbymchenry/codegraph  
**Type:** Code analysis tool (Binary)  
**License:** MIT

## Description

CodeGraph analyzes your codebase structure and dependencies to improve navigation. It generates interactive graphs showing relationships between files, functions, classes, and modules, making it easier to navigate and refactor large projects.

## Dependencies

- nodejs-lts, ripgrep, sqlite, git, python, clang, make, curl

## Install

```bash
core install ai --codegraph
```

## Uninstall

```bash
core uninstall ai --codegraph
```

## Update

```bash
core update ai --codegraph
```

## Notes

- Downloads the latest ARM64 binary from GitHub releases
- Wrapper script installed to `$PREFIX/bin/codegraph`
- Data stored in `$CORE_DATA/codegraph-linux-arm64/`

