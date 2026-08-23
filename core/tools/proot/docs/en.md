## Package Information

- **Name:** proot
- **Tags:** container, chroot, termux
- **Project:** https://proot-me.github.io
- **Dependencies:** None required by Core

## What is it?

Chroot alternative for user-space sandboxing

**Package:** proot  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://proot-me.github.io  
**Type:** System tool (pkg)  
**License:** GPL-2.0

### Description

PRoot is a user-space implementation of chroot, mount --bind, and binfmt_misc. It allows users to run arbitrary programs in a sandboxed environment without root privileges, essential for running Linux distributions in Termux.

### Dependencies

- Installed via pkg

### Install

```bash
core install proot
```

### Uninstall

```bash
core uninstall proot
```

### Update

```bash
core update proot
```

### Notes

- Command: `proot`
- Used by proot-distro for running Linux distributions
- Required by some AI tool installation methods

## How to use it?

```bash
core install proot      # install
core update proot       # update
core uninstall proot    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show proot:es`.
