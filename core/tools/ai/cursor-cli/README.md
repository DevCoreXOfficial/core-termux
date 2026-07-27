# Cursor CLI

AI-powered coding agent that runs in your terminal

**Package:** cursor-cli  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://cursor.com  
**Type:** AI coding agent (Binary + glibc bootstrapper)  
**License:** Proprietary

## Description

Cursor CLI (cursor-agent) is an AI-powered coding agent from Cursor that operates directly in your terminal. It provides intelligent code generation, editing, and debugging assistance. Since Cursor is not open source, the binary is downloaded directly from Cursor's CDN. The package is a Node.js application bundled with its own Node.js runtime. Core-Termux offers two installation methods: native with glibc support for best performance, or via proot-distro Ubuntu container for maximum compatibility.

## Dependencies

- **Native mode:** glibc-repo, glibc, git, ripgrep, jq, nodejs-lts, curl, tar
- **Proot mode:** proot-distro, curl, ca-certificates, tar

## Install

```bash
core install ai --cursor-cli
```

You will be prompted to choose:

1. **Native (recommended)** — Downloads the latest Cursor CLI package and creates a launcher wrapper that runs the bundled Node.js via the glibc dynamic linker
2. **Proot-distro (alternative)** — Runs Cursor CLI inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --cursor-cli
```

## Update

```bash
core update ai --cursor-cli
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, and other dependencies (installed automatically)
- The package is stored in `~/.local/share/core-termux-data/cursor/`
- `cursor-agent` is a **bash script** (not an ELF binary); it runs a bundled `node` (ELF glibc binary) with `index.js`
- A bash wrapper at `$PREFIX/bin/cursor` runs the bundled `node` via the glibc dynamic linker (`ld-linux-aarch64.so.1`)
- `cursor` is the primary command, with `cursor-agent` as a symlink
- **Proot mode** uses `proot-distro ubuntu` and downloads the full package into `/opt/cursor/` with a symlink at `/usr/local/bin/cursor-agent`
- Version is detected dynamically from the official Cursor install script at `https://cursor.com/install`
- Download URL pattern: `https://downloads.cursor.com/lab/{version}/linux/arm64/agent-cli-package.tar.gz`
- The tarball contains a full Node.js app with bundled runtime, native addons, and dependencies under `dist-package/`

## OAuth Authentication

Cursor CLI uses OAuth for authentication. On Android/Termux, the browser callback to `localhost` may not work due to Android's app sandboxing.

**If OAuth gets stuck after opening the browser:**

1. **Manual token entry** — The OAuth page usually shows a code or redirect URL. Copy it and paste it back into the terminal when prompted.
2. **Set `BROWSER` env var** — Try setting `export BROWSER='echo'` before running `cursor` to print the auth URL instead of opening it. You can then open it manually.
3. **Termux:API** — If you have Termux:API installed, the `termux-open-url` command is used automatically for URL opening.
4. **Proot mode** — The OAuth callback might work better in proot-distro mode since the bundled Node.js runs in a full Ubuntu environment with proper glibc networking. Try switching install methods.

If issues persist, you may need to complete authentication on a desktop and copy the session token manually.
