> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** SuperFile
- **Tags:** file-manager, tui
- **Proyecto:** https://superfile.dev
- **Código fuente:** https://github.com/yorukot/superfile
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Gestor de archivos TUI moderno y visual.

## Binario y referencia CLI

**Binario:** `spf`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: spf [COMMAND] [OPTIONS] [PATH]...

Pretty fancy and modern terminal file manager

Commands:
  path-list, pl        Print the path to the configuration and directory
  help, h              Shows a list of commands or help for one command

Options:
  --debug-info, --di             Print debug information
  --fix-hotkeys, --fh            Adds any missing hotkeys to the hotkey config file
  --fix-config-file, --fch       Adds any missing fields to the config file
  --print-last-dir, --pld        Print the last dir to stdout on exit (to use for cd)
  --config-file, -c <value>      Specify the path to a different config file
  --hotkey-file, --hf <value>    Specify the path to a different hotkey file
  --chooser-file, --cf <value>   On trying to open any file, superfile will write to its path to this file, and exit
  --help, -h                     show help
  --version, -v                  print the version

Version: v1.6.0

Use "spf [COMMAND] --help" for more information about a command.
```

## ¿Cómo usarlo?

```bash
core install superfile        # instalar
core update superfile         # actualizar
core uninstall superfile      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://superfile.dev/install.ps1'))"
```

Full documentation: https://superfile.dev

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show superfile`.
