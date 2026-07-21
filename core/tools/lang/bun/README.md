# Bun

JavaScript runtime, bundler, test runner, and package manager (all-in-one toolkit)

**Package:** bun (binary)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://bun.com
**Type:** Language runtime (binary)  
**License:** MIT

## Description

Bun is a fast all-in-one JavaScript runtime built with the Zig programming language. It provides a native implementation of JavaScriptCore, a bundler, a transpiler, a task runner, an npm-compatible package manager, and a test runner. The native build uses Bun's official Android binary (`bun-linux-aarch64-android`) with a C wrapper that resolves relative paths and an LD_PRELOAD shim that enables `bun build` by intercepting directory traversal at Termux's sandbox boundary.

## Dependencies

- Native: `clang`, `unzip`, `curl`
- Proot-distro (alternative): Ubuntu container, `curl`, `ca-certificates`, `unzip`

## Install

```bash
core install lang --bun
```

## Uninstall

```bash
core uninstall lang --bun
```

## Update

```bash
core update lang --bun
```

## Notes

- Commands: `bun`, `bun-bundle`
- The native build uses `bun-linux-aarch64-android.zip` (Android NDK build, runs via `/system/bin/linker64`)
- Three components work together for full functionality:
  - **C wrapper** (`bun_wrapper.c`): resolves relative file paths to absolute via `realpath()`, working around the Android `CouldntReadCurrentDirectory` bug in Bun
  - **LD_PRELOAD shim** (`bun-android-shim.c`): provides two fixes:
    1. Intercepts `opendir`/`openat64` for `/data/` and `/data/data/`, returning ENOENT so Bun's project-root discovery stops at the Termux sandbox boundary instead of crashing with "Cannot read directory /data/" — this enables `bun build` on Termux
    2. At process start, maps the `.bun` section at its ELF virtual address via `MAP_FIXED`, fixing the SEGFAULT in compiled standalone binaries where Bun's embedded runtime has hardcoded absolute pointers that the Android dynamic linker does not relocate
  - **bun-bundle post-processor** (`bun-bundle.c`): after `bun build --compile`, wraps the output binary in a shell script that sets `LD_PRELOAD` to the shim, making compiled binaries runnable on Termux
- C wrapper compiled to `$PREFIX/bin/bun`, shim installed to `$PREFIX/lib/bun-android-shim.so`, bundler to `$PREFIX/bin/bun-bundle`
- Proot-distro installation still uses the Linux glibc binary (`bun-linux-aarch64.zip`) and does not need the shim since Ubuntu's filesystem has no `/data/` restriction
- A Proot-distro Ubuntu method is available as an alternative installation path

## Workflow: compiled standalone binaries

`bun build --compile` produces ELF standalone binaries that crash on Android Termux due to non-relocated absolute pointers in the embedded Bun runtime. Use `bun-bundle` to make them runnable:

```bash
# Compile your TypeScript/JS file
bun build --compile hello.ts

# Bundle: creates a shell wrapper that auto-sets LD_PRELOAD
bun-bundle hello

# Run it — works!
./hello

# The original binary is renamed to hello.bun, and hello becomes a shell wrapper.
# You can also run the binary directly with LD_PRELOAD:
LD_PRELOAD=$PREFIX/lib/bun-android-shim.so ./hello.bun
```

Note: `bun build --compile` standalone binaries produced on Android Termux are **Android ELF binaries** (interpreter `/system/bin/linker64`, bionic libc). They cannot run on standard Linux systems (Ubuntu, Debian, etc.). To produce Linux-compatible standalone binaries, use the proot-distro installation instead.
