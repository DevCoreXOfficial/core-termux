> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Oh My Zsh + Plugins
- **Tags:** shell, prompt, plugins, oh-my-zsh

- **Dependencias:** git, fzf

## ¿Qué es?

ZSH + Oh My Zsh + powerlevel10k + 9 plugins, fully configured in one command

## Binario y referencia CLI

**Binario:** `zsh`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: zsh [<options>] [<argument> ...]

Special options:
  --help     show this message, then exit
  --version  show zsh version number, then exit
  -b         end option processing, like --
  -c         take first argument as a command to execute
  -o OPTION  set an option by name (see below)

Normal options are named.  An option may be turned on by
`-o OPTION', `--OPTION', `+o no_OPTION' or `+-no-OPTION'.  An
option may be turned off by `-o no_OPTION', `--no-OPTION',
`+o OPTION' or `+-OPTION'.  Options are listed below only in
`--OPTION' or `--no-OPTION' form.

Named options:
  --aliases
  --aliasfuncdef
  --allexport
  --alwayslastprompt
  --alwaystoend
  --appendcreate
  --appendhistory
  --autocd
  --autocontinue
  --autolist
  --automenu
  --autonamedirs
  --autoparamkeys
  --autoparamslash
  --autopushd
  --autoremoveslash
  --autoresume
  --badpattern
  --banghist
  --bareglobqual
  --bashautolist
  --bashrematch
  --beep
  --bgnice
  --braceccl
  --bsdecho
  --caseglob
  --casematch
  --casepaths
  --cbases
  --cdablevars
  --cdsilent
  --chasedots
  --chaselinks
  --checkjobs
  --checkrunningjobs
  --clobber
  --clobberempty
  --combiningchars
```

## ¿Cómo usarlo?

```bash
core install oh-my-zsh        # instalar
core update oh-my-zsh         # actualizar
core uninstall oh-my-zsh      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
```bash
core install oh-my-zsh        # everything at once
core update zsh         # pull latest plugin versions
core uninstall zsh      # remove plugins + Oh My Zsh
```

Then restart your shell or run `exec zsh`.

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show oh-my-zsh`.
