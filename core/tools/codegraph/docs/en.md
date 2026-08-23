## Package Information

- **Name:** CodeGraph
- **Tags:** ai, code-analysis, graph
- **Dependencies:** nodejs

## What is it?

Analyzes your codebase structure and dependencies to improve navigation

**Package:** codegraph  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/colbymchenry/codegraph  
**Type:** Code analysis tool (Binary)  
**License:** MIT

### Description

CodeGraph analyzes your codebase structure and dependencies to improve navigation. It generates interactive graphs showing relationships between files, functions, classes, and modules, making it easier to navigate and refactor large projects.

### Dependencies

- nodejs-lts, ripgrep, sqlite, git, clang, make, curl

### Install

```bash
core install codegraph
```

### Uninstall

```bash
core uninstall codegraph
```

### Update

```bash
core update codegraph
```

### Notes

- Downloads the latest ARM64 binary from GitHub releases
- Wrapper script installed to `$PREFIX/bin/codegraph`
- Data stored in `$CORE_DATA/codegraph-linux-arm64/`

## How to use it?

```bash
core install codegraph      # install
core update codegraph       # update
core uninstall codegraph    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show codegraph:es`.
