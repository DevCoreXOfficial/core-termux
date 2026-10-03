> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** herdr
- **Tags:** terminal, multiplexer, sessions, agents, ai
- **Proyecto:** https://herdr.dev
- **Código fuente:** https://github.com/herdrdev/herdr
- **Dependencias:** curl, coreutils (instaladas automáticamente por Core)

## ¿Qué es?

Gestor de espacio de trabajo de terminal para agentes de programación con IA.

Herdr es un multiplexor y gestor de espacio de trabajo de terminal construido
alrededor de agentes de programación con IA. Sigue el modelo de tmux/zellij —el
prefijo es `ctrl+b`, los paneles persisten, y desvincular y volver a conectar
funcionan como se espera— pero añade funciones relacionadas con agentes:

- Detecta agentes de programación que se ejecutan en los paneles.
- Informa de su estado en vivo (inactivo, trabajando, esperando aprobación).
- Mantiene una barra lateral con los agentes conectados.
- Puede restaurar las conversaciones nativas de los agentes tras reiniciar.

Además es *mouse-first*: puedes hacer clic en los paneles, arrastrar los bordes
y dividir o cambiar de panel desde menús contextuales, sin aprender atajos.

## Binario y referencia CLI

**Binario:** `herdr`

Salida real de `--help` y comandos comunes:

### `--help` output

```text
herdr — terminal workspace manager for AI coding agents

Usage: herdr [options]
       herdr --session <name> [options]
       herdr --machine <label-or-id> <command>
       herdr --remote <ssh-target> [--session <name>]
       herdr session attach <name>
       herdr completion zsh
       herdr update [--handoff]
       herdr channel set <stable|preview>
       herdr machine <subcommand> ...
       herdr server stop
       herdr server reload-config
       herdr api <subcommand> ...
       herdr completion <shell>
       herdr config <subcommand> ...
       herdr channel <subcommand> ...
       herdr workspace <subcommand> ...
       herdr worktree <subcommand> ...
       herdr tab <subcommand> ...
       herdr notification <subcommand> ...
       herdr agent <subcommand> ...
       herdr pane <subcommand> ...
       herdr session <subcommand> ...
       herdr integration <subcommand> ...

Common commands:
  herdr                            Launch or attach to the persistent session
  herdr status [server|client]     Show local client and running server status
  herdr update                     Download and install the latest version
```

## ¿Cómo usarlo?

```bash
herdr                  # lanzar o conectar a la sesión persistente
herdr status           # estado del cliente local y del servidor
herdr --help           # lista completa de comandos
```

Subcomandos habituales:

| Comando | Descripción |
|---------|-------------|
| `herdr session <cmd>` | Crear, listar, conectar y detener sesiones |
| `herdr workspace <cmd>` | Gestionar espacios de trabajo |
| `herdr pane <cmd>` | Gestionar paneles |
| `herdr tab <cmd>` | Gestionar pestañas |
| `herdr agent <cmd>` | Inspeccionar y controlar los agentes detectados |
| `herdr machine <cmd>` | Añadir y gestionar máquinas SSH guardadas |
| `herdr worktree <cmd>` | Gestionar espacios de trabajo de git worktree |
| `herdr api <cmd>` | API de socket local |
| `herdr server stop` | Detener el servidor en ejecución |
| `herdr update` | Actualizar Herdr |
| `herdr channel set <stable\|preview>` | Cambiar de canal de actualizaciones |

```bash
core install herdr        # instalar
core update herdr         # actualizar
core uninstall herdr      # eliminar
```

## Configuración

- `~/.config/herdr/config.toml` — configuración principal
- `~/.herdr/` — directorio de datos (se puede cambiar con `HERDR_HOME`)

Referencia: https://herdr.dev/docs/configuration/

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux el binario se instala en `$PREFIX/bin/herdr`; en Ubuntu/WSL se instala en `~/.local/bin/herdr`.
- **Soporte en Termux:** Herdr oficialmente **no** soporta Android/Termux. Su instalador oficial aborta cuando `uname -o` devuelve `Android`. Sin embargo, los binarios `linux-aarch64` y `linux-x86_64` son ELF completamente estáticos, así que sí funcionan en Termux sin necesidad de glibc ni musl. Este instalador reimplanta el oficial quitando únicamente esa restricción, manteniendo el mismo manifiesto de versiones (`https://herdr.dev/latest.json`) y la misma verificación SHA-256.
- Es una configuración no oficial. Si upstream añade soporte nativo para Android en el futuro, conviene usar su instalador oficial.
- Documentación completa en inglés: `core show herdr`.
