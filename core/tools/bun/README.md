# Bun

JavaScript runtime, bundler, test runner, and package manager (all-in-one toolkit)

**Package:** bun (binary)
**Author:** DevCoreX
**Repository:** https://github.com/DevCoreXOfficial/core-termux
**Official:** https://bun.com
**Type:** Language runtime (binary)
**License:** MIT

## Description

Bun is a fast all-in-one JavaScript runtime built with the Zig programming language. It provides a native implementation of JavaScriptCore, a bundler, a transpiler, a task runner, an npm-compatible package manager, and a test runner.

Two installation methods are available depending on your use case.

## Installation Methods

### Native (recommended)

Uses Bun's official Android NDK binary with C wrappers and an LD_PRELOAD shim for full Termux compatibility.

**Best for:** Running and developing JavaScript/TypeScript projects directly on Termux/Android.

**Pros:**
- Fastest execution (native ARM64, no container overhead)
- Full `bun build --compile` support with `bun-bundle`
- Small footprint (~35MB installed)

**Cons:**
- Compiled standalone binaries are **Android ELFs** (interpreter `/system/bin/linker64`, bionic libc)
- Cannot run on standard Linux systems (Ubuntu, Debian, etc.)

### Proot-distro (alternative)

Installs Bun's official Linux glibc binary (`bun-linux-aarch64.zip`) inside an Ubuntu container via `proot-distro`.

**Best for:** Compiling standalone binaries that need to run on standard Linux systems (servers, Docker, CI/CD).

**Pros:**
- Produces **Linux-compatible** standalone binaries (`bun build --compile` outputs glibc ELF)
- Full Linux environment for testing and deployment workflows
- No shim needed — Ubuntu has no `/data/` sandbox restriction

**Cons:**
- Slower execution (container overhead)
- Requires ~500MB for Ubuntu rootfs
- `bun-bundle` not needed (no LD_PRELOAD fix required)

## Install

```bash
core install lang --bun
```

The installer will prompt you to choose between Native and Proot-distro. Both methods always install the latest available version.

## Uninstall

```bash
core uninstall lang --bun
```

## Update

```bash
core update lang --bun
```

Compares installed version against the latest release on GitHub. If an update is available, prompts for confirmation before proceeding.

## Reinstall

```bash
core reinstall lang --bun
```

## Dependencies

- **Native:** `clang`, `unzip`, `curl`
- **Proot-distro:** `proot-distro`, Ubuntu container, `unzip`

## Commands

| Command | Description |
|---------|-------------|
| `bun` | JavaScript runtime, package manager, bundler, test runner |
| `bunx` | Run npm packages without installing (like `npx`) |
| `bun-bundle` | Post-process compiled standalone binaries for Termux (native only) |

## Native: How It Works

Three components work together for full functionality on Termux:

1. **C wrapper** (`bun_wrapper.c`): resolves relative file paths to absolute via `realpath()`, working around the Android `CouldntReadCurrentDirectory` bug in Bun
2. **LD_PRELOAD shim** (`bun-android-shim.c`): provides two fixes:
   - Intercepts `opendir`/`openat64` for `/data/` and `/data/data/`, returning ENOENT so Bun's project-root discovery stops at the Termux sandbox boundary instead of crashing with "Cannot read directory /data/"
   - At process start, maps the `.bun` section at its ELF virtual address via `MAP_FIXED`, fixing the SEGFAULT in compiled standalone binaries where Bun's embedded runtime has hardcoded absolute pointers
3. **bun-bundle post-processor** (`bun-bundle.c`): after `bun build --compile`, wraps the output binary in a shell script that sets `LD_PRELOAD` to the shim, making compiled binaries runnable on Termux

## Workflow: Compiled Standalone Binaries

### On Termux (native installation)

`bun build --compile` produces Android ELF standalone binaries. Use `bun-bundle` to make them runnable:

```bash
# Compile your TypeScript/JS file
bun build --compile hello.ts

# Bundle: creates a shell wrapper that auto-sets LD_PRELOAD
bun-bundle hello

# Run it — works!
./hello
```

The original binary is renamed to `hello.bun`, and `hello` becomes a shell wrapper. You can also run the binary directly:

```bash
LD_PRELOAD=$PREFIX/lib/bun-android-shim.so ./hello.bun
```

### On Linux (proot-distro installation)

Compiled binaries are standard Linux glibc ELFs — no wrapper needed:

```bash
# Compile inside proot
bun build --compile hello.ts

# Run directly
./hello
```

To copy the binary out of proot to your Termux filesystem:

```bash
cp /root/hello ~/hello
```

## Notes

- Both methods download the latest version from GitHub at install/update time
- Native uses `bun-linux-aarch64-android.zip` (Android NDK build, runs via `/system/bin/linker64`)
- Proot-distro uses `bun-linux-aarch64.zip` (Linux glibc build, runs via `ld-linux-aarch64.so.1`)
- C wrapper compiled to `$PREFIX/bin/bun`, shim installed to `$PREFIX/lib/bun-android-shim.so`, bundler to `$PREFIX/bin/bun-bundle`
- Proot-distro creates wrapper scripts at `$PREFIX/bin/bun` and `$PREFIX/bin/bunx` that route into the Ubuntu container
