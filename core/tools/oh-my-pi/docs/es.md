> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Oh-My-Pi
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/can1357/oh-my-pi
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Superficie agéntica completa: más de 60 proveedores y decenas de herramientas integradas.

## Binario y referencia CLI

**Binario:** `omp`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
omp v18.0.0

USAGE
  $ omp [COMMAND]

ARGUMENTS
  MESSAGES   Messages to send (prefix files with @)

FLAGS
      --model=<value>                 Model to use (fuzzy match: "opus", "gpt-5.2", or "openai/gpt-5.2")
      --smol=<value>                  Smol/fast model for lightweight tasks (or PI_SMOL_MODEL env)
      --slow=<value>                  Slow/reasoning model for thorough analysis (or PI_SLOW_MODEL env)
      --plan=<value>                  Plan model for architectural planning (or PI_PLAN_MODEL env)
      --prewalk                       Switch from the active model to a fast/cheap model at the first edit/write after the plan's todo list exists (default off; see prewalk.enabled)
      --no-prewalk                    Disable prewalk even if prewalk.enabled is set
      --prewalk-into=<value>          Target model for prewalk (default the "smol" role)
      --plan-yolo                     Force read-only plan mode at start, auto-approve the plan on the model's first resolve call, then switch to --plan-yolo-into to implement it
      --plan-yolo-into=<value>        Target model for plan-yolo execution (default the "smol" role)
      --provider=<value>              Provider to use (legacy; prefer --model)
      --api-key=<value>               API key (defaults to env vars)
      --system-prompt=<value>         System prompt (default: coding assistant prompt)
      --append-system-prompt=<value>  Append text or file contents to the system prompt
      --allow-home                    Allow starting in ~ without auto-switching to a temp dir
      --profile=<value>               Use an isolated profile for auth, sessions, settings, and caches
      --alias=<value>                 Create a shell shortcut for the selected profile and exit
      --cwd=<value>                   Directory to start in (overrides the launch cwd)
      --mode=<value>                  Output mode: text (default), json, rpc, or rpc-ui
      --config=<value>                Load an extra config.yml-style overlay for this run (repeatable)
      --add-dir=<value>               Add a workspace directory beyond the working directory (repeatable)
  -p, --print                         Non-interactive mode: process prompt and exit
  -c, --continue                      Continue previous session
  -r, --resume=<value>                Resume a session (by ID prefix, path, or picker if omitted)
      --from-claude                   Import a Claude Code session into OMP
      --from-codex                    Import a Codex session into OMP
      --session-dir=<value>           Directory for session storage and lookup
      --no-session                    Don't save session (ephemeral)
      --models=<value>                Comma-separated model patterns for Ctrl+P cycling
      --no-tools                      Disable all built-in tools
      --no-lsp                        Disable LSP tools, formatting, and diagnostics
      --no-pty                        Disable PTY-based interactive bash execution
      --tools=<value>                 Comma-separated list of tools to enable (default: all)
      --thinking=<value>              Set thinking level: off, minimal, low, medium, high, xhigh, max, auto
      --service-tier=<value>          OpenAI service tier for this session (none omits service_tier)
      --hide-thinking                 Hide thinking blocks in TUI output (display only, does not disable model thinking)
      --advisor                       Enable the advisor runtime (passively reviews each turn and injects notes)
      --external-thinking             Use a private scratchpad while disabling supported GPT, Claude, and Gemini reasoning (at your own risk: providers have flagged this request shape as abuse)
      --hook=<value>                  Load a hook/extension file (can be used multiple times)
  -e, --extension=<value>             Load an extension file (can be used multiple times)
      --no-extensions                 Disable extension discovery (explicit -e paths still work)
      --no-skills                     Disable skills discovery and loading
      --skills=<value>                Comma-separated glob patterns to filter skills (e.g., git-*,docker)
      --no-rules                      Disable rules discovery and loading
      --export=<value>                Export session file to HTML and exit
      --no-title                      Disable title auto-generation
      --print-thoughts                Include thinking blocks in print mode text output
```


### Common commands

```bash
{
inputs.omp.url = "github:can1357/oh-my-pi";
imports = [ inputs.omp.homeManagerModules.default ];
programs.omp = {
enable = true;
settings.startup.quiet = true;
};
}
```

## ¿Cómo usarlo?

```bash
core install oh-my-pi        # instalar
core update oh-my-pi         # actualizar
core uninstall oh-my-pi      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
{
  inputs.omp.url = "github:can1357/oh-my-pi";

  # In your Home Manager module:
  imports = [ inputs.omp.homeManagerModules.default ];
  programs.omp = {
    enable = true;
    settings.startup.quiet = true;
  };
}
```

Full documentation: https://github.com/can1357/oh-my-pi

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show oh-my-pi`.
