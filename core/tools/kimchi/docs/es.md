> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Kimchi
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/getkimchi/kimchi
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Agente de programación en terminal con orquestación multi-modelo.

## Binario y referencia CLI

**Binario:** `kimchi`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
kimchi — code with powerful open-source LLMs

Usage: kimchi [subcommand] [options] [@files…] [messages…]

Subcommands:
  kimchi setup          Run the interactive setup wizard
  kimchi login          Log in via browser and update your API key
  kimchi setup-tools    Configure coding tools in one pass
  kimchi claude         Configure Claude Code to use Kimchi (and launch it)
  kimchi opencode       Configure OpenCode to use Kimchi (and launch it)
  kimchi cursor         Configure Cursor to use Kimchi
  kimchi openclaw       Configure OpenClaw to use Kimchi
  kimchi gsd2           Install / configure GSD2 with Kimchi
  kimchi update         Check for and install Kimchi/package updates
  kimchi config         Inspect or change kimchi config (e.g. telemetry)
  kimchi resources      Enable or disable Kimchi hooks, tools, extensions, and plugins
  kimchi mcp            MCP server utilities (probe, ...)
  kimchi version        Print the kimchi version
  kimchi                (no subcommand) Launch the coding harness

Harness flags (no subcommand):
  --provider <name>            Provider (default: kimchi-dev)
  --model <pattern>            Model id or pattern, optionally `provider/id` and/or `:<thinking>`
  --thinking <level>           Thinking level: off, minimal, low, medium, high, xhigh, max
  --mode <mode>                Output mode: text (default), json, rpc, acp
  --print, -p                  Non-interactive mode: process prompt and exit
  --continue, -c               Resume the most recent session
  --resume, -r [id]            Resume by id, or pick a previous session interactively when omitted
  --session <path>             Resume a specific session file (full path or partial UUID)
  --no-session                 Run ephemerally — don't write a session file
  --export <file>              Export a session to HTML and exit
  --list-models [search]       Print available models (optionally fuzzy-filtered)
  --allow-tool <rule>          Add session permission allow rules (comma-separated)
  --deny-tool <rule>           Add session permission deny rules (comma-separated)
  --plan                       Start in plan mode (read-only)
  --auto                       Start in auto mode (run freely, classifier guards)
  --yolo                       Start in yolo mode (run freely, no classifier - DANGER)
  --permissions-config <path>  Replace the merged permissions config with this file
  --verbose                    Force verbose startup (overrides quietStartup)
  --help, -h                   Show this help
  --version, -v                Show the kimchi version

Environment variables:
  KIMCHI_API_KEY            Kimchi API key (overrides config.json apiKey)
  KIMCHI_PERMISSIONS        Initial permissions mode: default | plan | auto | yolo
  KIMCHI_TELEMETRY_ENABLED  Override telemetry (1/true to enable, 0/false to disable). On by default.
  KIMCHI_TAGS               Comma-separated `key:value` tags applied to every LLM request
  KIMCHI_NO_UPDATE_CHECK    Disable the background self-update probe

Examples:
  kimchi setup                                # first-time interactive setup
  kimchi setup-tools                          # configure coding tools
  kimchi                                      # launch the interactive harness
  kimchi -p "explain src/cli.ts"              # one-shot prompt, no session
  kimchi --continue                           # resume the most recent session
```


### Common commands

```bash
Then configure your API key and launch:
Run `kimchi --help` to see all available subcommands and flags.
Kimchi operates in one of two modes:
| Mode | Status line indicator | Behavior |
|------|-----------------|----------|
| **Single-model** | model name | All work runs on the selected model directly |
| Role | Default | Description |
|------|---------|-------------|
```

## ¿Cómo usarlo?

```bash
core install kimchi        # instalar
core update kimchi         # actualizar
core uninstall kimchi      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick start

Install the latest release:

**Homebrew (macOS / Linux):**

```bash
brew install getkimchi/tap/kimchi
```

**Install script (macOS / Linux):**

```bash
curl -fsSL https://github.com/getkimchi/kimchi/releases/latest/download/install.sh | bash
```

**PowerShell (Windows):**

```powershell
irm https://github.com/getkimchi/kimchi/releases/latest/download/install.ps1 | iex
```

Then configure your API key and launch:

```bash
kimchi setup   # one-time interactive setup
kimchi         # launch the coding agent
```

Run `kimchi --help` to see all available subcommands and flags.


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show kimchi`.
