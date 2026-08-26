> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** ncurses-utils
- **Tags:** tput, terminal

- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Terminal UI manipulation utilities

## Binario y referencia CLI

**Binario:** `tput`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
tput: invalid option -- -
Usage: tput [options] [command]

Options:
  -S <<       read commands from standard input
  -T TERM     use this instead of $TERM
  -V          print curses-version
  -v          verbose, show warnings
  -x          do not try to clear scrollback

Commands:
  clear       clear the screen
  init        initialize the terminal
  reset       reinitialize the terminal
  capname     unlike clear/init/reset, print value for capability "capname"
```

## ¿Cómo usarlo?

```bash
core install ncurses        # instalar
core update ncurses         # actualizar
core uninstall ncurses      # eliminar
```



## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show ncurses`.
