## Package Information

- **Name:** udocker
- **Tags:** containers, docker, rootless
- **Project:** https://indigo-dc.github.io/udocker/
- **Dependencies:** None required by Core

## What is it?

Run Docker containers without root privileges

**Package:** udocker  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/indigo-dc/udocker  
**Type:** Container tool (pkg)  
**License:** Apache 2.0

### Description

Udocker is a tool that allows you to execute Docker containers in user space without requiring root privileges. It works by using chroot, proot, and other user-space mechanisms to provide container-like environments on systems where Docker is not available.

### Dependencies

- Installed via pkg

### Install

```bash
core install dev --udocker
```

### Uninstall

```bash
core uninstall dev --udocker
```

### Update

```bash
core update dev --udocker
```

### Notes

- Command: `udocker`
- No root required
- Supports pulling from Docker Hub
- Limited compared to full Docker

## How to use it?

```bash
core install udocker      # install
core update udocker       # update
core uninstall udocker    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show udocker:es`.
