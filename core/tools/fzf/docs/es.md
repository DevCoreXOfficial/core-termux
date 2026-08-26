> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** fzf
- **Tags:** fuzzy, finder, search
- **Proyecto:** https://github.com/junegunn/fzf
- **Código fuente:** https://github.com/junegunn/fzf
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Buscador difuso interactivo para la línea de comandos.

## Binario y referencia CLI

**Binario:** `fzf`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
fzf is an interactive filter program for any kind of list.

It implements a "fuzzy" matching algorithm, so you can quickly type in patterns
with omitted characters and still get the results you want.

Project URL: https://github.com/junegunn/fzf
Author: Junegunn Choi <junegunn.c@gmail.com>

* See man page for more information: fzf --man

Usage: fzf [options]

  SEARCH
    -e, --exact              Enable exact-match
    +x, --no-extended        Disable extended-search mode
    -i, --ignore-case        Case-insensitive match
    +i, --no-ignore-case     Case-sensitive match
        --smart-case         Smart-case match (default)
    --scheme=SCHEME          Scoring scheme [default|path|history]
    -n, --nth=N[,..]         Comma-separated list of field index expressions
                             for limiting search scope. Each can be a non-zero
                             integer or a range expression ([BEGIN]..[END]).
    --with-nth=N[,..]        Transform the presentation of each line using
                             field index expressions
    --accept-nth=N[,..]      Define which fields to print on accept
    -d, --delimiter=STR      Field delimiter regex (default: AWK-style)
    +s, --no-sort            Do not sort the result
    --literal                Do not normalize latin script letters
    --tail=NUM               Maximum number of items to keep in memory
    --disabled               Do not perform search
    --tiebreak=CRI[,..]      Comma-separated list of sort criteria to apply
                             when the scores are tied
                             [length|chunk|pathname|begin|end|index] (default: length)

  INPUT/OUTPUT
    --read0                  Read input delimited by ASCII NUL characters
    --print0                 Print output delimited by ASCII NUL characters
    --ansi                   Enable processing of ANSI color codes
    --sync                   Synchronous search for multi-staged filtering

  GLOBAL STYLE
    --style=PRESET           Apply a style preset [default|minimal|full[:BORDER_STYLE]
    --color=COLSPEC          Base scheme (dark|light|base16|bw) and/or custom colors
    --no-color               Disable colors
    --no-bold                Do not use bold text

  DISPLAY MODE
    --height=[~][-]HEIGHT[%] Display fzf window below the cursor with the given
                             height instead of using fullscreen.
                             A negative value is calculated as the terminal height
                             minus the given value.
                             If prefixed with '~', fzf will determine the height
                             according to the input size.
    --min-height=HEIGHT[+]   Minimum height when --height is given as a percentage.
                             Add '+' to automatically increase the value
```


### Common commands

```bash
export FZF_CTRL_T_OPTS="
--walker-skip .git,node_modules,target
--preview 'bat -n --color=always {}'
--bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_CTRL_R_OPTS="
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard'"
```

## ¿Cómo usarlo?

```bash
core install fzf        # instalar
core update fzf         # actualizar
core uninstall fzf      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Options

See the man page (`fzf --man` or `man fzf`) for the full list of options.

### Demo
If you learn by watching videos, check out this screencast by [@samoshkin](https://github.com/samoshkin) to explore `fzf` features.

<a title="fzf - command-line fuzzy finder" href="https://www.youtube.com/watch?v=qgG5Jhi_Els">
  <img src="https://i.imgur.com/vtG8olE.png" width="640">
</a>

Examples
--------

* [Wiki page of examples](https://github.com/junegunn/fzf/wiki/examples)
    * *Disclaimer: The examples on this page are maintained by the community
      and are not thoroughly tested*
* [Advanced fzf examples](https://github.com/junegunn/fzf/blob/master/ADVANCED.md)

Key bindings for command-line
-----------------------------

By [setting up shell integration](#setting-up-shell-integration), you can use
the following key bindings in bash, zsh, fish, and Nushell.

- `CTRL-T` - Paste the selected files and directories onto the command-line
    - The list is generated using `--walker file,dir,follow,hidden` option
        - You can override the behavior by setting `FZF_CTRL_T_COMMAND` to a custom command that generates the desired list
        - Or you can set `--walker*` options in `FZF_CTRL_T_OPTS`
    - Set `FZF_CTRL_T_OPTS` to pass additional options to fzf
      ```sh
      # Preview file content using bat (https://github.com/sharkdp/bat)
      export FZF_CTRL_T_OPTS="
        --walker-skip .git,node_modules,target
        --preview 'bat -n --color=always {}'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'"
      ```
    - Can be disabled by setting `FZF_CTRL_T_COMMAND` to an empty string when
      sourcing the script
- `CTRL-R` - Paste the selected command from history onto the command-line.
    - Select multiple commands with `TAB`.
    - If you want to see the commands in chronological order, press `CTRL-R`
      again which toggles sorting by relevance
    - Press `ALT-R` to toggle "raw" mode where you can see the surrounding items
      of a match. In this mode, you can press `CTRL-N` and `CTRL-P` to move
      between the matching items only.
    - Press `CTRL-/` or `ALT-/` to toggle line wrapping
    - Press `SHIFT-DELETE` to delete the selected commands (bash and fish)
    - Fish shell only:
      - Press `ALT-ENTER` to reformat and insert the selected commands
      - Press `ALT-T` to cycle through command prefix (timestamp, date/time, none)
    - Set `FZF_CTRL_R_OPTS` to pass additional options to fzf
      ```sh
      # CTRL-Y to copy the command into clipboard using pbcopy
      export FZF_CTRL_R_OPTS="
        --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
        --color header:italic
        --header 'Press CTRL-Y to copy command into clipboard'"
      ```
      ```fish
      # Fish shell: Set date/time as default prefix
      set -gx FZF_CTRL_R_OPTS "--with-nth 1,3.. --bind 'alt-t:change-with-nth(2..|3..|1,3..)'"

      # Or display no prefix by default
      set -gx FZF_CTRL_R_OPTS "--with-nth 3.. --bind 'alt-t:change-with-nth(2..|1,3..|3..)'"
      ```
    - Can be disabled by setting `FZF_CTRL_R_COMMAND` to an empty string when

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show fzf`.
