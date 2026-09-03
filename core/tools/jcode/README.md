# Jcode

The most RAM efficient and intelligent coding agent harness, written in Rust.

**Package:** jcode
**Author:** 1jehuang
**Repository:** https://github.com/1jehuang/jcode
**Type:** AI coding agent (standalone Rust binary)
**License:** MIT

## Description

Jcode is a coding agent harness built for massive parallelism and resource efficiency. It features swarm collaboration, semantic memory, browser automation, and a self-dev mode where the agent can modify its own source code.

## Dependencies

- None (standalone binary)
- On Termux: `glibc` and `patchelf` (installed by the installer)

## Install

```bash
core install jcode
```

## Uninstall

```bash
core uninstall jcode
```

## Update

```bash
core update jcode
```

## Notes

- Binary installed to `~/.local/bin/jcode`
- Config at `~/.jcode/config.toml`
- Supports Claude, OpenAI, Gemini, Copilot, Ollama, LM Studio, and many more providers
