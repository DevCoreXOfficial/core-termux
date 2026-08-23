## Package Information

- **Name:** Droid Factory
- **Tags:** ai, agent, coding
- **Project:** https://factory.ai
- **Dependencies:** None required by Core

## What is it?

AI coding agent by Factory (Factory CLI)

**Package:** droid  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://app.factory.ai  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** Proprietary

### Description

Droid Factory (Factory CLI) is an AI coding agent from Factory that operates directly in your terminal. It is distributed as a single glibc-linked binary for linux/arm64, which is incompatible with Termux's bionic libc. Core offers three installation methods: native with glibc support for best performance, glibc + proot to bypass "bad system call" errors, or via proot-distro Ubuntu container for maximum compatibility.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, jq, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates

### Install

```bash
core install droid-factory
```

You will be prompted to choose:

1. **glibc (recommended)** — Compiles a glibc bootstrapper and downloads the latest droid binary from downloads.factory.ai
2. **glibc + proot (bad system call)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **proot-distro (ubuntu container)** — Runs droid inside an Ubuntu proot-distro container

### Uninstall

```bash
core uninstall droid-factory
```

### Update

```bash
core update droid-factory
```

### Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-data/droid-factory/`
- A small C bootstrapper (`droid_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and downloads the binary inside the container
- Binary URL pattern: `https://downloads.factory.ai/factory-cli/releases/<version>/linux/arm64/droid`
- Data directory: `~/.local/share/core-data/droid-factory/`

## How to use it?

```bash
core install droid-factory      # install
core update droid-factory       # update
core uninstall droid-factory    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show droid-factory:es`.
