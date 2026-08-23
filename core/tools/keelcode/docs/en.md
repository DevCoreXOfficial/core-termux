## Package Information

- **Name:** KeelCode
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

The hosted coding agent for your terminal — inspect a project, edit files, run commands, search the web, use MCP servers, and verify its work

**Package:** keelcode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://keelcode.ai  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** Proprietary (not open source)

### Description

KeelCode is a hosted coding agent for your terminal. It can inspect a project, edit files, run commands, search the web, use MCP servers, and verify its work. It is distributed via npm as a small launcher plus platform-suffixed native binaries (`@keelcode-ai/keelcode`), and since the native packages only target linux/darwin/win32 there is no Android variant — Core downloads the `linux-arm64` native binary straight from the npm registry instead of using `bun i -g`.

### Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates, tar, jq

### Install

```bash
core install keelcode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest KeelCode `linux-arm64` native binary + bundled ripgrep from the npm registry
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs KeelCode inside an Ubuntu proot-distro container

### Uninstall

```bash
core uninstall keelcode
```

### Update

```bash
core update keelcode
```

### Usage

```bash
keelcode            # Start in the current project
keelcode login      # Sign in (device approval)
keelcode -p "fix the failing test"   # One prompt without opening the TUI
keelcode whoami     # Show account
```

Aliases are installed: `kc`, `kcode`, `keel`.

### Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary and bundled `rg` sidecar are stored in `~/.local/share/core-data/keelcode/`
- A small C bootstrapper (`keelcode_helper.c`) handles ELF loading via the glibc dynamic linker and sets `KEELCODE_RG_PATH` for the bundled ripgrep
- **Proot mode** uses `proot-distro ubuntu` and installs the binary at `/usr/local/bin/keelcode`
- Version is checked against the npm registry dist-tag `native-linux-arm64`
- Data directory: `~/.local/share/core-data/keelcode/`

## How to use it?

```bash
core install keelcode      # install
core update keelcode       # update
core uninstall keelcode    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show keelcode:es`.
