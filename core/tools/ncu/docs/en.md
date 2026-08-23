## Package Information

- **Name:** npm-check-updates
- **Tags:** updates, npm, dependencies
- **Project:** https://github.com/raineorshine/npm-check-updates
- **Dependencies:** nodejs

## What is it?

Find and update outdated npm dependencies

**Package:** npm-check-updates  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/raineorshine/npm-check-updates  
**Type:** Node.js global module (npm)  
**License:** Apache 2.0

### Description

npm-check-updates (ncu) upgrades your package.json dependencies to the latest versions, ignoring specified versions. It provides interactive mode for selective updates and supports filtering, targeting, and more.

### Dependencies

- Node.js LTS (nodejs-lts)

### Install

```bash
core install npm --ncu
```

### Uninstall

```bash
core uninstall npm --ncu
```

### Update

```bash
core update npm --ncu
```

### Notes

- Command: `ncu`
- Supports interactive mode with `--interactive`
- Can upgrade global packages with `-g` flag

## How to use it?

```bash
core install ncu      # install
core update ncu       # update
core uninstall ncu    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show ncu:es`.
