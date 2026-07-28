# Oh-My-Pi (omp)

Enhanced AI coding agent — improved version of Pi, built as a standalone binary with `bun build --compile`.

**Repository:** https://github.com/can1357/oh-my-pi  
**Author:** Can Boluk  
**Type:** AI coding agent (standalone binary + native Rust addons)  
**License:** MIT

## Description

Oh-My-Pi is an enhanced version of the Pi coding agent. It provides a full-featured terminal AI assistant with:

- **Native Rust addons**: AST grep, diff, syntax highlighting, fuzzy find, shell execution, and more
- **Session management**: Resume, continue, and session history
- **Multi-model support**: Works with various LLM providers
- **Tool system**: Edit, read, bash, LSP, PTY, and web tools
- **MCP support**: Model Context Protocol for extensibility

## Installation Methods

### Native (recommended)

The standalone binary is compiled against **glibc**. Installation uses:
1. `glibc-repo` + `glibc` packages from Termux (provides glibc libraries)
2. Downloads `omp-linux-arm64` from GitHub releases
3. Compiles a small helper that runs omp through glibc's `ld-linux` loader

This gives native performance with no overhead.

### Proot-distro (alternative)

Installs omp inside an Ubuntu 24.04 container via proot-distro, with a thin wrapper on the host.

## Dependencies

- **Pi Coding Agent** (installed automatically as dependency)
- glibc (native mode) or proot-distro (proot mode)
- clang, curl, jq, tar

## Commands

```bash
core install ai --oh-my-pi
core uninstall ai --oh-my-pi
core update ai --oh-my-pi
core reinstall ai --oh-my-pi
```

## Usage

```bash
omp --help
omp --version
# Interactive session:
omp
# One-shot prompt:
omp -p "Explain this codebase"
# Continue a session:
omp -c
```
