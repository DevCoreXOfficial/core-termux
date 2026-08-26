> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Engram
- **Tags:** ai, memory, agents
- **Código fuente:** https://github.com/Gentleman-Programming/engram
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Sistema de memoria persistente para agentes de programación.

## Binario y referencia CLI

**Binario:** `engram`

Salida real de `--help` y comandos comunes:

- **Binary:** `engram`

## ¿Cómo usarlo?

```bash
core install engram        # instalar
core update engram         # actualizar
core uninstall engram      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
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


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show engram`.
