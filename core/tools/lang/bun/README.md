# Bun

JavaScript runtime, bundler, test runner, and package manager (all-in-one toolkit)

**Package:** bun (binary)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://bun.com
**Type:** Language runtime (binary)  
**License:** MIT

## Description

Bun is a fast all-in-one JavaScript runtime built with the Zig programming language. It provides a native implementation of JavaScriptCore, a bundler, a transpiler, a task runner, an npm-compatible package manager, and a test runner. The Android build runs natively on Termux.

## Dependencies

- Native: `unzip` (recommended): Android native
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

- Commands: `bun`
- The native build uses `bun-linux-aarch64-android.zip` from the official releases
- A Proot-distro Ubuntu method is available as an alternative installation path
