## Package Information

- **Name:** tmate
- **Tags:** remote, sharing, pairing
- **Project:** https://tmate.io
- **Dependencies:** None required by Core

## What is it?

Instant terminal sharing for pair programming

**Package:** tmate  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://tmate.io  
**Type:** Development tool (pkg)  
**License:** Apache 2.0 / BSD 2-Clause

### Description

Tmate is a fork of tmux that allows you to share your terminal session instantly with anyone. It creates a secure SSH connection that others can join to view or control your terminal, perfect for pair programming and remote debugging.

### Dependencies

- Installed via pkg

### Install

```bash
core install dev --tmate
```

### Uninstall

```bash
core uninstall dev --tmate
```

### Update

```bash
core update dev --tmate
```

### Notes

- Command: `tmate`
- Creates instant SSH session
- Supports read-only and read-write sharing
- No registration required

## How to use it?

```bash
core install tmate      # install
core update tmate       # update
core uninstall tmate    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show tmate:es`.
