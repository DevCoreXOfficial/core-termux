## Package Information

- **Name:** Turbopack (glibc)
- **Tags:** bundler, nextjs, termux
- **Project:** https://nextjs.org
- **Dependencies:** None required by Core

## What is it?

Run Next.js with Turbopack on Termux (Android aarch64).

### Install

```bash
core install turbopack
```

Installs:
- **Node.js** linux-arm64 (glibc) — v22.14.0
- **node-glibc** — run any script with the glibc Node
- **next-turbopack** — Next.js dev/build with Turbopack

### Usage

```bash
cd my-next-app
next-turbopack dev     # Start dev server with Turbopack
next-turbopack build   # Production build with Turbopack
```

### How it works

Official Node.js linux-arm64 binaries are compiled against glibc. Android/Termux
uses bionic libc. The toolchain:
1. Downloads Node.js linux-arm64 official binary
2. Strips debug symbols (prevents patchelf from corrupting large ELFs)
3. Patches the ELF interpreter to use Termux's glibc loader
4. Installs CLI wrappers that resolve missing native bindings (SWC,
   lightningcss, etc.) for the linux-arm64 platform

### Init a new project

```bash
core init next
```

Adds `pnpm.supportedArchitectures` for multi-platform native bindings, installs
common dependencies, and sets up a modular folder structure.

### Uninstall

```bash
core uninstall turbopack
```

## How to use it?

```bash
core install turbopack      # install
core update turbopack       # update
core uninstall turbopack    # remove
```

## Notes

- Supported platforms: **termux**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show turbopack:es`.
