> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** tmux
- **Tags:** terminal, multiplexer, sessions
- **Proyecto:** https://github.com/tmux/tmux
- **Código fuente:** https://github.com/tmux/tmux
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Multiplexor de terminal: sesiones persistentes, ventanas y paneles.

## Binario y referencia CLI

**Binario:** `tmux`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
tmux: unknown option -- -
usage: tmux [-2CDhlNuVv] [-c shell-command] [-f file] [-L socket-name]
            [-S socket-path] [-T features] [command [flags]]
```

## ¿Cómo usarlo?

```bash
core install tmux        # instalar
core update tmux         # actualizar
core uninstall tmux      # eliminar
```

See https://github.com/tmux/tmux for full usage.

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show tmux`.
