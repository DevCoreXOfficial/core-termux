# KeelCode

The hosted coding agent for your terminal — inspect a project, edit files, run commands, search the web, use MCP servers, and verify its work

**Package:** keelcode  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://keelcode.ai  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** Proprietary (not open source)

## Description

KeelCode is a hosted coding agent for your terminal. It can inspect a project, edit files, run commands, search the web, use MCP servers, and verify its work. It is distributed via npm as a small launcher plus platform-suffixed native binaries (`@keelcode-ai/keelcode`), and since the native packages only target linux/darwin/win32 there is no Android variant — Core-Termux downloads the `linux-arm64` native binary straight from the npm registry instead of using `bun i -g`.

## Dependencies

- **Native mode:** glibc-repo, glibc, clang, git, ripgrep, jq, nodejs-lts, curl, tar
- **Native + proot mode:** proot
- **Proot mode:** proot-distro, curl, ca-certificates, tar, jq

## Install

```bash
core install ai --keelcode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest KeelCode `linux-arm64` native binary + bundled ripgrep from the npm registry
2. **Native + proot (fix)** — Runs the same glibc-loaded binary under proot to bypass "bad system call" errors on some Android kernels
3. **Proot-distro (alternative)** — Runs KeelCode inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --keelcode
```

## Update

```bash
core update ai --keelcode
```

## Usage

```bash
keelcode            # Start in the current project
keelcode login      # Sign in (device approval)
keelcode -p "fix the failing test"   # One prompt without opening the TUI
keelcode whoami     # Show account
```

Aliases are installed: `kc`, `kcode`, `keel`.

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary and bundled `rg` sidecar are stored in `~/.local/share/core-termux-data/keelcode/`
- A small C bootstrapper (`keelcode_helper.c`) handles ELF loading via the glibc dynamic linker and sets `KEELCODE_RG_PATH` for the bundled ripgrep
- **Proot mode** uses `proot-distro ubuntu` and installs the binary at `/usr/local/bin/keelcode`
- Version is checked against the npm registry dist-tag `native-linux-arm64`
- Data directory: `~/.local/share/core-termux-data/keelcode/`
