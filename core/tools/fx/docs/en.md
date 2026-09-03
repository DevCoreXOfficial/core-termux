## Package Information

- **Name:** fx
- **Tags:** ai, agent, coding
- **Project:** https://fx.sh
- **Source:** https://github.com/vercel-labs/fx
- **Dependencies:** none (standalone Zig binary)

## What is it?

Tiny, open, native coding agent harness written in Zig. Optimized for research and embeddability with a ~6 MB binary, 10µs cold start, and minimal memory footprint. Model-agnostic and suitable for both local and cloud inference.

## How to use it?

### Quickstart

```shell
# Start an interactive session
fx

# Run a single prompt
fx run "summarize this codebase"
```

### Install via Core

```bash
core install fx          # install
core update fx           # update
core uninstall fx        # uninstall
```

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `fx`

### Key features

- **Tiny binary**: ~6 MB, designed for instant installation and embedding
- **Instant cold start**: 10µs time to prompt
- **Minimal memory**: Single-digit megabytes baseline
- **Shell-like UI**: Minimal output, scroll history preserved
- **Context efficient**: Minimal system prompt and tools for optimal TTFT
- **Embeddable**: Small core, extended via skills, plugins, MCPs
- **Model agnostic**: Works with local models, gateways, or provider APIs
- **Wasm support**: Can be compiled to WebAssembly

## Notes

- Supported platforms: **termux, ubuntu, wsl** (macOS and Linux on x86_64 and arm64).
- Apache-2.0 license.
- Spanish (when available): `core show fx:es`.
