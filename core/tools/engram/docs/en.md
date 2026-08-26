## Package Information

- **Name:** Engram
- **Tags:** ai, memory, agents
- **Source:** https://github.com/Gentleman-Programming/engram
- **Dependencies:** None required by Core

## What is it?

Persistent memory system for AI coding agents. Agent-agnostic Go binary with SQLite + FTS5, MCP server, HTTP API, CLI, and TUI.

## How to use it?

### CLI Reference

| Command                                    | Description                                                     |
| ------------------------------------------ | --------------------------------------------------------------- |
| `engram setup [agent]`                     | Install agent integration                                       |
| `engram serve [port]`                      | Start HTTP API (default: 7437)                                  |
| `engram mcp [--tools=PROFILE] [--project NAME]` | Start MCP server (stdio transport)                         |
| `engram tui`                               | Launch terminal UI                                              |
| `engram search <query>`                    | Search memories                                                 |
| `engram save <title> <msg>`                | Save a memory                                                   |
| `engram delete <obs_id>`                   | Delete an observation (soft by default; `--hard` removes permanently) |
| `engram delete session <id>`               | Delete a session by ID (must have no observations)                    |
| `engram delete prompt <id>`                | Delete a prompt by ID (permanent)                                     |
| `engram delete project <name> [--hard]`    | Cascade-delete a project: soft-deletes observations by default (`--hard` removes permanently and also removes sessions) |
| `engram timeline <obs_id>`                 | Chronological context                                           |
| `engram context [project]`                 | Recent session context                                          |
| `engram stats`                             | Memory statistics                                               |
| `engram export [file]`                     | Export to JSON                                                  |
| `engram import <file>`                     | Import from JSON                                                |
| `engram sync`                              | Git sync export/import                                          |
| `engram conflicts <sub>`                   | Inspect and manage memory conflict relations                    |
| `engram doctor`                            | Run read-only operational diagnostics                           |
| `engram cloud <subcommand>`                | Opt-in cloud config/status/enrollment + cloud runtime (`serve`) |
| `engram projects list\|consolidate\|prune` | Manage project names                                            |
| `engram obsidian-export`                   | Export to Obsidian vault (beta)                                 |
| `engram version`                           | Show version                                                    |

Full CLI with all flags → [docs/ARCHITECTURE.md#cli-reference](docs/ARCHITECTURE.md#cli-reference)

### Key Environment Variables

| Variable                        | Description                                                                                                            | Default        |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------------- |
| `ENGRAM_DATA_DIR`               | Override data directory                                                                                                | `~/.engram`    |
| `ENGRAM_PORT`                   | Override HTTP server port                                                                                              | `7437`         |
| `ENGRAM_URL`                    | Point the **Pi plugin** at an existing `engram serve` instance instead of auto-starting one. Not an MCP endpoint — used by the HTTP event-capture path only. (The OpenCode plugin honors `ENGRAM_PORT`/`ENGRAM_BIN`, not `ENGRAM_URL`.) | (unset, defaults to `http://127.0.0.1:<ENGRAM_PORT>`) |
| `ENGRAM_HTTP_TOKEN`             | Optional Bearer auth for local HTTP server. When set, destructive and export routes require `Authorization: Bearer <token>`. Unset = open (zero-config default). | (unset) |
| `ENGRAM_TIMEZONE`               | Timezone for timestamp display in TUI and cloud dashboard (e.g. `America/New_York`). Falls back to system local when unset or invalid. | system local |
| `ENGRAM_CLOUD_AUTOSYNC`         | Set to `1` to enable background autosync (also requires `ENGRAM_CLOUD_TOKEN` + `ENGRAM_CLOUD_SERVER`).                 | (unset)        |
| `ENGRAM_CLOUD_ALLOWED_PROJECTS` | Comma-separated project allowlist for `engram cloud serve`. Use `*` to allow all projects.                             | (unset)        |
| `ENGRAM_CLOUD_TOKEN_PEPPER`     | Dedicated secret used to hash managed tokens. Required to issue tokens via `engram cloud bootstrap admin --issue-token` AND to enable managed-token authentication on `engram cloud serve`; must differ from `ENGRAM_JWT_SECRET`. Without it, `engram cloud serve` still starts and authenticates via legacy `ENGRAM_CLOUD_TOKEN`/`ENGRAM_CLOUD_ADMIN` only. | (unset)        |

Full environment variable reference → [DOCS.md#environment-variables](DOCS.md#environment-variables)

## Documentation

| Doc                                           | Description                                                            |
| --------------------------------------------- | ---------------------------------------------------------------------- |
| [Installation](docs/INSTALLATION.md)          | All install methods + platform support                                 |
| [Engram Cloud](docs/engram-cloud/README.md)   | Cloud landing page, quickstart, branding, and deep links               |
| [Agent Setup](docs/AGENT-SETUP.md)            | Per-agent configuration + Memory Protocol                              |
| [Codebase Guide](docs/CODEBASE-GUIDE.md)      | Guide to the repository structure, flows, and implementation landmarks |
| [Architecture](docs/ARCHITECTURE.md)          | How it works + MCP tools + project structure                           |
| [Plugins](docs/PLUGINS.md)                    | OpenCode & Claude Code plugin details                                  |
| [Comparison](docs/COMPARISON.md)              | Why Engram vs claude-mem                                               |
| [Intended Usage](docs/intended-usage.md)      | Mental model — how Engram is meant to be used                          |
| [Obsidian Brain](docs/beta/obsidian-brain.md) | Export memories as Obsidian knowledge graph (beta)                     |
| [Contributing](CONTRIBUTING.md)               | Contribution workflow + standards                                      |
| [Full Docs](DOCS.md)                          | Complete technical reference                                           |

> **Dashboard contributors**: if you modify `.templ` files in `internal/cloud/dashboard/`, run `make templ` to regenerate before committing. See [DOCS.md — Dashboard templ regeneration](DOCS.md#dashboard-templ-regeneration).

## License

MIT

---

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `engram`
