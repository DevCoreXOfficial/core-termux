## Package Information

- **Name:** Jcode
- **Tags:** ai, agent, coding
- **Project:** https://jcode.sh
- **Source:** https://github.com/1jehuang/jcode
- **Dependencies:** none (standalone Rust binary)

## What is it?

The most RAM efficient and intelligent coding agent harness, written in Rust. Jcode focuses on parallelism, resource efficiency, and open-source customizability. It runs dozens of agents in parallel with ~10 MB extra RAM per session.

## How to use it?

### Quickstart

```shell
# Launch the TUI
jcode

# Run a single prompt non-interactively
jcode run "say hello"

# Resume a previous session
jcode --resume fox

# Run as a persistent background server
jcode serve
jcode connect
```

### First run

1. Launch `jcode` in a terminal
2. Connect a provider with `jcode login` (supports Claude, OpenAI, Gemini, Copilot, Ollama, and many more)
3. Start coding

### Install via Core

```bash
core install jcode        # install
core update jcode         # update
core uninstall jcode      # uninstall
```

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `jcode`

### Common commands

```bash
jcode                          # launch TUI
jcode run "prompt"             # non-interactive single prompt
jcode --resume <name>          # resume session by name
jcode serve                    # start background server
jcode connect                  # attach client to server
jcode login                    # configure provider auth
jcode login --provider claude  # login with Claude
jcode login --provider openai  # login with OpenAI
jcode auth-test --all          # verify all configured providers
jcode browser setup            # setup browser automation
```

### Key features

- **Swarm**: Spawn multiple agents in parallel with automatic conflict resolution
- **Memory**: Semantic vector-based automatic memory recall
- **Browser**: Built-in Firefox Agent Bridge for web automation
- **Skills**: Markdown instruction packs loaded on-demand via semantic matching
- **Self-dev mode**: Agent can modify its own source code

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- On Termux, requires `glibc` and `patchelf` (installed automatically).
- Config lives at `~/.jcode/config.toml`.
- Spanish (when available): `core show jcode:es`.
